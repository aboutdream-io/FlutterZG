import 'dart:async';

import 'package:gowedo/repositories/register_repository.dart';
import 'package:gowedo/util/my_localization.dart';
import 'package:rxdart/rxdart.dart';
import 'package:validators/validators.dart';

import 'bloc_provider.dart';

enum RegisterStateType {
  waiting, loading, finished, error
}

class RegisterState {
  RegisterState({this.registerStateType = RegisterStateType.waiting, this.error, this.stackTrace});

  final RegisterStateType registerStateType;
  final dynamic error;
  final StackTrace stackTrace;
}

class RegisterBloc extends BlocBase {

  static final RegisterBloc _bloc = RegisterBloc._internal();
  factory RegisterBloc(MyLocalization myLocalization, RegisterRepository registerRepository){
    if (_bloc._registerRepository == null){
      _bloc._myLocalization = myLocalization;
      _bloc._registerRepository = registerRepository;
      _bloc._registerStateController = BehaviorSubject<RegisterState>();
      _bloc._registerStateController.add(RegisterState(registerStateType: RegisterStateType.waiting));
      _bloc._emailController = BehaviorSubject<String>();
      _bloc._usernameController = BehaviorSubject<String>();
      _bloc._passwordController = BehaviorSubject<String>();
      _bloc._repeatPasswordController = BehaviorSubject<String>();
    }
    return _bloc;
  }
  RegisterBloc._internal();

  BehaviorSubject<RegisterState> _registerStateController;
  BehaviorSubject<String> _emailController;
  BehaviorSubject<String> _usernameController;
  BehaviorSubject<String> _passwordController;
  BehaviorSubject<String> _repeatPasswordController;
  RegisterRepository _registerRepository;
  MyLocalization _myLocalization;
  Stream<RegisterState> get registerStateStream => _registerStateController.stream;

  Function(String) get onEmailChanged => _emailController.sink.add;
  Function(String) get onUsernameChanged => _usernameController.sink.add;
  Function(String) get onPasswordChanged => _passwordController.sink.add;
  Function(String) get onRepeatPasswordChanged => _repeatPasswordController.sink.add;
  Stream<String> get email => _emailController.stream.transform(StreamTransformer<String, String>.fromHandlers(
    handleData: (String email, EventSink<String> sink) => email.isNotEmpty && isEmail(email) ? sink.add(email)
      : sink.addError(email.isNotEmpty ? _myLocalization.emailIsNotValid : _myLocalization.enterYourEmail)
  ));
  Stream<String> get username => _usernameController.stream.transform(StreamTransformer<String, String>.fromHandlers(
    handleData: (String username, EventSink<String> sink) => username.isNotEmpty ? sink.add(username)
      : sink.addError(_myLocalization.enterYourUsername)
  ));
  Stream<String> get password => _passwordController.stream.transform(StreamTransformer<String, String>.fromHandlers(
    handleData: (String password, EventSink<String> sink) => password.length >= 8 ? sink.add(password)
      : sink.addError(password.isNotEmpty ? _myLocalization.passwordLengthError : _myLocalization.enterYourPassword)
  ));
  Stream<String> get repeatPassword => _repeatPasswordController.stream.transform(StreamTransformer<String, String>.fromHandlers(
    handleData: (String repeatPassword, EventSink<String> sink) => repeatPassword.isNotEmpty
      && repeatPassword == _passwordController.value ? sink.add(repeatPassword)
      : sink.addError(repeatPassword.isEmpty ? _myLocalization.enterYourPasswordAgain : _myLocalization.passwordsDoNotMatch)
  ));
  Stream<bool> get registerValid => Observable.combineLatest4(_emailController.stream, _usernameController.stream, _passwordController.stream, _repeatPasswordController.stream,
    (String email, String username, String password, String repeatPassword) =>
    isEmail(_emailController.value) && _usernameController.value.isNotEmpty && _passwordController.value.length >= 6 &&
      _passwordController.value == _repeatPasswordController.value);



  @override
  void dispose() {
    _registerStateController?.close();
    _emailController?.close();
    _usernameController?.close();
    _passwordController?.close();
    _repeatPasswordController?.close();
  }

  void onRegisterTapped() {
    _registerStateController.add(RegisterState(registerStateType: RegisterStateType.loading));
    _registerRepository.register(email: _emailController.value, username: _usernameController.value, password: _passwordController.value)
      .then((String securityToken) {
      _registerStateController.add(RegisterState(registerStateType: RegisterStateType.finished));
    }).catchError((dynamic error, StackTrace stackTrace) =>
      _registerStateController.add(RegisterState(registerStateType: RegisterStateType.error, error: error, stackTrace: stackTrace)));
  }
}
