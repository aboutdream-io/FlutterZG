import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';

import 'request_config.dart';
import 'gowedo.dart';

class ApiClient{
  final HttpClient client = HttpClient();
  final Connectivity _connectivity = Connectivity();
  bool inAutoLogin = false;
  Future<Null> autoLoginFuture;

  Map<String, String> get getDefaultHeaders{
    final Map<String, String> defaultHeaders = <String, String>{};

    print('Is logged in: ${GoWeDo.localStorage.isLoggedIn}');
    if (GoWeDo.localStorage.isLoggedIn && !inAutoLogin) {
      defaultHeaders.addAll(<String, String>{'Authorization': 'JWT ${GoWeDo.localStorage.securityToken}'});
    }
    return defaultHeaders;
  }

  Future<ConnectivityResult> _checkConnectivity() async {
    ConnectivityResult connectivityResult;
    try {
      connectivityResult = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
      connectivityResult = ConnectivityResult.none;
    }
    return connectivityResult;
  }

  Future<bool> isConnectionAvailable() async {
    return await _checkConnectivity() != ConnectivityResult.none;
  }

  /// Use this instead of [getAction], [postAction] and [putAction]
  Future<T> request<T>(Config config, {bool autoLogin = false}) async {
    if (await isConnectionAvailable() != true) {
      return Future<T>.error(GoWeDoError(null, config, errorType: ErrorType.noConnection));
    }
    if(inAutoLogin && !autoLogin){
      if(autoLoginFuture != null)
        return autoLoginFuture;
    }

    print('[${config.method}] Sending request: ${config.uri.toString()}');

    final HttpClientRequest _request = await client.openUrl(config.method, config.uri)
      .then((HttpClientRequest request) => _addHeaders(request, config))
      .then((HttpClientRequest request) => _addCookies(request, config))
      .then((HttpClientRequest request) => _addBody(request, config));

    final HttpClientResponse _response = await _request.close();

    print('[${config.method}] Received: ${_response.reasonPhrase} [${_response.statusCode}] - ${config.uri.toString()}');

    if(_response.statusCode >= 200 && _response.statusCode < 300) {
      return config.hasResponse ? Future<T>.value(config.responseType.parse(_response)) : Future<HttpClientResponse>.value(_response);
    }
    return await _processError(_response, config, onAutoLoginSuccess: () => request<T>(config));
  }

  HttpClientRequest _addBody(HttpClientRequest request, Config config) {
    if (config.hasBody) {
      request.headers.contentType = config.body.getContentType();
      request.contentLength = const Utf8Encoder().convert(config.body.getBody()).length;
      request.write(config.body.getBody());
    }

    return request;
  }

  HttpClientRequest _addCookies(HttpClientRequest request, Config config) {
    config.cookies.forEach((String key, dynamic value) =>
    value is Cookie ? request.cookies.add(value) : request.cookies.add(Cookie(key, value)));

    return request;
  }

  HttpClientRequest _addHeaders(HttpClientRequest request, Config config) {
    // Add default headers
    getDefaultHeaders.forEach((String key, dynamic value) => request.headers.add(key, value));

    // Add config headers
    config.headers.forEach((String key, dynamic value)=> request.headers.add(key, value));

    return request;
  }

  Future<Null> autoLogin() async {
    inAutoLogin = true;

    final String deviceId = await GoWeDo.localStorage.getDeviceId();

    final Map<String, String> bodyMap = <String, String>{
      'device_id': deviceId,
    };

    final HttpClientResponse response = await request(Config(
      method: RequestMethod.post,
      uri: Uri.parse('${GoWeDo.server}/users/login/'),
      body: RequestBody.json(bodyMap),
    ), autoLogin: true);

    inAutoLogin = false;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> objects = json.decode(await response.transform(const Utf8Decoder()).join());
      GoWeDo.localStorage.setSecurityToken(objects['token']);
      print('Auto login success!');
      return null;
    }
    // Clear client data
    GoWeDo.localStorage.resetData();
    print('Auto login failed!');
    return Future<Null>.error('Auto login failed!');
  }

  Future<dynamic> _processError(HttpClientResponse response, Config config, {Future<dynamic> Function() onAutoLoginSuccess}) async {
    final GoWeDoError goWeDoError = await GoWeDoError.parseError(response, config);

    if(goWeDoError.errorType == ErrorType.tokenExpired){
      if(!inAutoLogin){
        autoLoginFuture = autoLogin();
      }

      await autoLoginFuture;
      return onAutoLoginSuccess();
    }

    return Future<dynamic>.error(goWeDoError);
  }
}

class GoWeDoError{
  final HttpClientResponse response;
  final Config config;

  bool shouldShow = true;
  ErrorType errorType;
  final StringBuffer _presentableError = StringBuffer();

  GoWeDoError(this.response, this.config, {this.errorType});

  String get errorString => _presentableError.isEmpty ? null : _presentableError.toString();

  @override
  String toString(){
    return 'GoWeDoError :: $errorString';
  }

  /// Get more info about Request error
  /// Will set up error type and string for specific error
  /// Toggles [shouldShow] flag to false if error dialog is not needed to pop up for this error
  Future<Null> _processError() async {
    print('Processing error : [${response.statusCode}] - ${response.reasonPhrase}');
    final String _responseData = await utf8.decodeStream(response);
    final Map<dynamic, dynamic> errorJson = jsonDecode(_responseData);

    switch(response.statusCode){
    /// Start auto-login procedure if we receive status code 498
    /// 498 Invalid Token (Esri)
    /// Returned by ArcGIS for Server. Code 498 indicates an expired or otherwise invalid token.
      case 498:
        if (GoWeDo.localStorage.isLoggedIn){
          List<dynamic> _errors = <dynamic>[];

          if(errorJson.containsKey('errors') &&
            errorJson['errors'].isNotEmpty){
            _errors = errorJson['errors'];
          }

          if(_errors.isNotEmpty &&
            _errors.any((dynamic item) => item.containsKey('description') && item['description'].toString().contains('disabled'))){
            errorType = ErrorType.accountDisabled;
          } else{
            errorType = ErrorType.unknown;
          }

          break;
        }

        continue unknown;

    /// Error 401 is thrown when user is unauthorized to access this endpoint.
    /// App should never call endpoint that will receive '401' if user is logged in
      case 401:
        errorType = ErrorType.tokenExpired;
        break;

    /// Bad gateway. Usually means there is server fix/deploy on the way.
      case 502:
        errorType = ErrorType.badGateway;
        break;

    /// Bad request. Get error code from response data JSON saved in field
    /// 'error_code'. This will give us detailed info about error defined by server for this app.
    ///
    /// Codes are defined here: https://docs.hot-soup.com/penkala-api/index.html#response-codes
      case 400:
        switch(errorJson['error_code'] ?? -1){
          default:
            errorType = ErrorType.badRequest;
            break;
        }
        break;
      unknown:
      default:
        errorType = ErrorType.unknown;

        print('UNKNOWN ERROR! ${response.statusCode} - [${response.reasonPhrase}]');
        print('URL: ${config.uri.toString()}');
        print('Headers: ${config.headers.toString()}');
        print('Body: ${config.body?.getBody()}');
        print('Data: ${_responseData ?? ''}');
        break;
    }

    if(errorType == ErrorType.badGateway && GoWeDo.isInDebugMode){
      _presentableError.writeln('502 - Bad Gateway (deploy is on the way?)');
    }else{
      try{
        if(errorJson.containsKey('errors')){
          final Map<String, dynamic> errors = errorJson['errors'];
          errors.forEach((String key, dynamic value) {
            List<dynamic> valueList = value;
            _presentableError.writeAll(valueList.map<String>((dynamic e) => e.toString()), '\n');
          });
          _presentableError.writeln('');
        }else{
          if(GoWeDo.isInDebugMode){
            _presentableError.write(errorJson['error_code'] ?? '-1');
            _presentableError.write(' - ');
          }
          _presentableError.writeln(errorJson['error_message'] ?? 'Something went wrong!');
        }

        if(GoWeDo.isInDebugMode){
          _presentableError.writeln(' --- ');
          _presentableError.writeln(errorJson);
        }

        print('Error: ${errorType.toString()}');
      }catch(exception){
        print('Exception proccessing error: $exception');

        if(GoWeDo.isInDebugMode){
          _presentableError.writeln('${response.statusCode} - ${response.reasonPhrase}');
          _presentableError.writeln(' --- ');
          _presentableError.writeln(_responseData);
        }
      }
    }
  }

  static Future<GoWeDoError> parseError(HttpClientResponse response, Config config) async {
    final GoWeDoError error = GoWeDoError(response, config);
    await error._processError();
    return Future<GoWeDoError>.value(error);
  }
}

enum ErrorType{
  accountDisabled,
  tokenExpired,
  badGateway,
  badRequest,
  unauthorized,
  unknown,
  noConnection
}
