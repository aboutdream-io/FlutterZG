import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';

import 'api_client.dart';
import 'request_config.dart';
import 'gowedo.dart';

class ApiCalls {
  final ApiClient apiClient = ApiClient();
  final JsonDecoder _decoder = const JsonDecoder();

  String get server => GoWeDo.server;

  Future<Null> _processNullResponse(HttpClientResponse response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Future<Null>.value(null);
    }
    return Future<Null>.error(response);
  }

  Future<String> login({String username, String password}) {
    final Map<String, dynamic> bodyMap = <String, dynamic>{'username': username, 'password': password};
    return apiClient.request<Map<String, dynamic>>(Config(
      uri: Uri.parse('$server/login/'),
      body: RequestBody.json(bodyMap),
      method: RequestMethod.post,
      responseType: ResponseBody.json()
    )).then((Map<String, dynamic> jsonResponse) => jsonResponse['token']);
  }

  Future<Null> register({String emailAddress, String username, String password}) async {
    final Map<String, dynamic> bodyMap = <String, dynamic>{'email': emailAddress, 'username': username, 'password': password};
    final HttpClientResponse response = await apiClient.request(Config(
      uri: Uri.parse('$server/users/registration/'),
      method: RequestMethod.post,
      body: RequestBody.json(bodyMap)
    ));
    return _processNullResponse(response);
  }

  Future<String> facebookLogin(String accessToken) async {
    final Map<String, dynamic> bodyMap = <String, dynamic>{'access_token': accessToken};
    return apiClient.request<Map<String, dynamic>>(Config(
      uri: Uri.parse('$server/facebook/login/'),
      body: RequestBody.json(bodyMap),
      method: RequestMethod.post,
      responseType: ResponseBody.json()
    )).then((Map<String, dynamic> jsonResponse) => jsonResponse['token']);
  }

  Future<String> googleLogin(String idToken) async {
    final Map<String, dynamic> bodyMap = <String, dynamic>{'google_id_token': idToken};
    return apiClient.request<Map<String, dynamic>>(Config(
      uri: Uri.parse('$server/google/login/'),
      body: RequestBody.json(bodyMap),
      method: RequestMethod.post,
      responseType: ResponseBody.json()
    )).then((Map<String, dynamic> jsonResponse) => jsonResponse['token']);
  }
}
