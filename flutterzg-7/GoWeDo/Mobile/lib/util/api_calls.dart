import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:gowedo/models/post.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

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

  Future<Null> resetPassword(String phoneNumber) async {
    final Map<String, dynamic> bodyMap = <String, dynamic>{'phone_number': phoneNumber};
    final HttpClientResponse response = await apiClient.request(Config(
      uri: Uri.parse('$server/users/password/reset/'),
      method: RequestMethod.post,
      body: RequestBody.json(bodyMap)
    ));
    return _processNullResponse(response);
  }

  Future<Null> resetPasswordConfirm(String phoneNumber, {@required String key, @required String password}) async {
    final Map<String, dynamic> bodyMap = <String, dynamic>{'phone_number': phoneNumber, 'key': key, 'password': password};
    final HttpClientResponse response = await apiClient.request(Config(
      uri: Uri.parse('$server/users/password/reset/confirm'),
      method: RequestMethod.post,
      body: RequestBody.json(bodyMap)
    ));
    return _processNullResponse(response);
  }

  Future<Null> logout(int clientId) async {
    final Map<String, dynamic> bodyMap = <String, dynamic>{'client_id': clientId};
    final HttpClientResponse response = await apiClient.request(Config(
      uri: Uri.parse('$server/logout'),
      method: RequestMethod.post,
      body: RequestBody.json(bodyMap)
    ));
    return _processNullResponse(response);
  }

  Future<List<Post>> getPosts({int offset, int limit}) {
    return apiClient.request<Map<String, dynamic>>(Config(
        uri: Uri.parse('$server/posts?offset=$offset&limit=$limit'),
        method: RequestMethod.get,
        responseType: ResponseBody.json()))
        .then<List<dynamic>>((Map<String, dynamic> json) => json['results'])
        .then((List<dynamic> jsonList) => jsonList.map((json) => Post.fromApi(json)).toList());
  }

  Future<Post> createPost(Post post) async {
    final MultipartRequest request = MultipartRequest('POST', Uri.parse('$server/posts/'))
      ..headers.addAll(<String, String>{
        'Authorization': 'Token ${GoWeDo.localStorage.securityToken}',
        'content-type': 'multipart/form-data'
      })
      ..fields.addAll({
        'title' : post.title,
        'description' : post.description
      })
      ..files.add(new MultipartFile.fromBytes(
        'image',
        post.imageFile.readAsBytesSync(),
        filename: post.imageFile.path.split('/').last,
        contentType: MediaType.parse('image/jpg'),
      ));

    final StreamedResponse response = await request.send();

    print('Received response code: ${response.statusCode} - ${response.reasonPhrase}');
    if (response.statusCode == HttpStatus.created) {
      return Future<Post>.value(post);
    } else
      return Future<Post>.error('${response.statusCode} - ${response.reasonPhrase}');
  }

}
