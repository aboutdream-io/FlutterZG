import 'dart:async';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gowedo/bloc/screen_state.dart';
import 'package:gowedo/repositories/login_repository.dart';
import 'package:gowedo/util/my_localization.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc_provider.dart';

enum LoginStateType {
  waiting, loading, finished, error
}

class LoginState extends ScreenState{
  LoginState({StateType stateType = StateType.waiting, String message, dynamic error, StackTrace stackTrace})
      : super(stateType: stateType, message: message, error: error, stackTrace: stackTrace);
}


class LoginBloc extends BlocBase {
  static final LoginBloc _bloc = LoginBloc._internal();
  factory LoginBloc(MyLocalization myLocalization, LoginRepository loginRepository){
    if (_bloc._loginRepository == null){
      _bloc._myLocalization = myLocalization;
      _bloc._loginRepository = loginRepository;
      _bloc._loginStateController = BehaviorSubject<LoginState>();
      _bloc._loginStateController.add(LoginState(stateType: StateType.waiting));
      _bloc._usernameController = BehaviorSubject<String>();
      _bloc._passwordController = BehaviorSubject<String>();
    }
    return _bloc;
  }
  LoginBloc._internal();

  BehaviorSubject<LoginState> _loginStateController;
  BehaviorSubject<String> _usernameController;
  BehaviorSubject<String> _passwordController;
  LoginRepository _loginRepository;
  MyLocalization _myLocalization;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final FacebookLogin _facebookLogin = FacebookLogin();
  Stream<LoginState> get loginStateStream => _loginStateController.stream;

  Function(String) get onUsernameChanged => _usernameController.sink.add;
  Function(String) get onPasswordChanged => _passwordController.sink.add;
  Stream<String> get username => _usernameController.stream.transform(StreamTransformer<String, String>.fromHandlers(
    handleData: (String username, EventSink<String> sink) => username.isNotEmpty ? sink.add(username)
      : sink.addError(_myLocalization.enterYourUsername)
  ));
  Stream<String> get password => _passwordController.stream.transform(StreamTransformer<String, String>.fromHandlers(
    handleData: (String password, EventSink<String> sink) => password.isNotEmpty ? sink.add(password)
      : sink.addError(_myLocalization.enterYourPassword)
  ));
  Stream<bool> get loginValid => Observable.combineLatest2(_usernameController.stream, _passwordController.stream,
      (String username, String password) => username.isNotEmpty && password.isNotEmpty);

  @override
  void dispose() {
    _loginStateController?.close();
    _usernameController?.close();
    _passwordController?.close();
  }

  void onLoginTapped() {
    _loginStateController.add(LoginState(stateType: StateType.loading));
    _loginRepository.login(username: _usernameController.value, password: _passwordController.value)
      .then((String securityToken) {
        print('got security token: $securityToken');
        _loginRepository.saveSecurityToken(securityToken);
        _loginStateController.add(LoginState(stateType: StateType.finished));
    }).catchError((dynamic error, StackTrace stackTrace) =>
      _loginStateController.add(LoginState(stateType: StateType.error, error: error, stackTrace: stackTrace)));
  }

  Future<void> onGoogleLoginTapped() async {
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount?.authentication;
      if (googleSignInAuthentication?.idToken != null){
        _loginStateController.add(LoginState(stateType: StateType.loading));
        _loginRepository.googleLogin(googleSignInAuthentication.idToken)
          .then((String securityToken) {
          _loginRepository.saveSecurityToken(securityToken);
          _loginStateController.add(LoginState(stateType: StateType.finished));
        }).catchError((dynamic error, StackTrace stackTrace) =>
          _loginStateController.add(LoginState(stateType: StateType.error, error: error, stackTrace: stackTrace)));
      } else {
        _loginStateController.add(LoginState(stateType: StateType.error, message: _myLocalization.facebookLoginFailed));
      }
    } catch (error) {
      print(error);
      _loginStateController.add(LoginState(stateType: StateType.error, message: _myLocalization.googleLoginFailed));
    }
  }

  Future<void> onFacebookLoginTapped() async {
    final FacebookLoginResult result = await _facebookLogin.logIn(<String>['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        if (accessToken.token != null) {
          _loginStateController.add(LoginState(stateType: StateType.loading));
          _loginRepository.facebookLogin(accessToken.token)
            .then((String securityToken) {
            _loginRepository.saveSecurityToken(securityToken);
            _loginStateController.add(LoginState(stateType: StateType.finished));
          }).catchError((dynamic error, StackTrace stackTrace) =>
            _loginStateController.add(LoginState(stateType: StateType.error, error: error, stackTrace: stackTrace)));
        } else {
          _loginStateController.add(LoginState(stateType: StateType.error, message: _myLocalization.facebookLoginFailed));
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        _loginStateController.add(LoginState(stateType: StateType.error, message: _myLocalization.facebookLoginFailed));
        break;
      case FacebookLoginStatus.error:
        print('error: ${result?.errorMessage}');
        _loginStateController.add(LoginState(stateType: StateType.error, message: _myLocalization.facebookLoginFailed));
        break;
    }
  }
}
