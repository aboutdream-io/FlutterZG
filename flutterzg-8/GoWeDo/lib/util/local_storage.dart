import 'dart:async';
import 'dart:convert';
import 'package:gowedo/models/register_device_data.dart';
import 'package:gowedo/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String PREF_USER = 'user';
const String PREF_REGISTER_DEVICE_DATA = 'register_device_data';
const String PREF_SECURITY_TOKEN = 'security_token';

class LocalStorage {
  User _user;
  RegisterDeviceData _registerDeviceData;
  bool get isLoggedIn => _securityToken != null;
  String _securityToken;
  String get securityToken => _securityToken;

  Future<User> getUser() async {
    if (_user != null) {
      return Future<User>.value(_user);
    }
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String userInfo = sharedPreferences.getString(PREF_USER);
    if (userInfo?.isNotEmpty == true) {
      _user = User.fromApi(json.decode(userInfo));
    }
    return _user;
  }

  Future<Null> saveUser(User user) async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(PREF_USER, json.encode(user.toMap()));
    _user = user;
    return null;
  }

  Future<String> getSecurityToken() async {
    if (_securityToken != null) {
      return _securityToken;
    }
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String securityToken = sharedPreferences.getString(PREF_SECURITY_TOKEN);
    if (securityToken?.isNotEmpty == true) {
      _securityToken = securityToken;
    }
    return _securityToken;
  }

  Future<Null> setSecurityToken(String securityToken) async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(PREF_SECURITY_TOKEN, securityToken);
    _securityToken = securityToken;
    return null;
  }

  Future<Null> setRegisterDeviceData(RegisterDeviceData registerDeviceData) async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(PREF_REGISTER_DEVICE_DATA, json.encode(registerDeviceData.toMap()));
    _registerDeviceData = registerDeviceData;
    return null;
  }

  Future<RegisterDeviceData> getRegisterDeviceData() async {
    if (_registerDeviceData != null) {
      return _registerDeviceData;
    }
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String registerDeviceDataInfo = sharedPreferences.getString(PREF_REGISTER_DEVICE_DATA);
    if (registerDeviceDataInfo?.isNotEmpty == true) {
      _registerDeviceData = RegisterDeviceData.fromApi(json.decode(registerDeviceDataInfo));
    }
    return _registerDeviceData;
  }

  Future<String> getDeviceId() async {
    RegisterDeviceData registerDeviceData = await getRegisterDeviceData().catchError((_) => null);
    return registerDeviceData?.deviceId;
  }

  Future<String> getNotificationToken() async {
    RegisterDeviceData registerDeviceData = await getRegisterDeviceData().catchError((_) => null);
    return registerDeviceData?.registrationId;
  }

  Future<Null> resetData() async {
    _user = null;
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(PREF_USER);
    return null;
  }

  Future<Null> deleteUserData() async {
    _user = null;
    _registerDeviceData = null;
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(PREF_USER);
    sharedPreferences.remove(PREF_REGISTER_DEVICE_DATA);
    return null;
  }
}
