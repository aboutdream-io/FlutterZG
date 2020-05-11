import 'dart:async';

import 'package:gowedo/repositories/register_repository.dart';
import 'package:gowedo/util/my_localization.dart';
import 'package:rxdart/rxdart.dart';
import 'package:validators/validators.dart';

import 'bloc_base.dart';

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
  RegisterBloc(this.registerRepository);

  final BehaviorSubject<RegisterState> _registerStateController = BehaviorSubject<RegisterState>.seeded(RegisterState(registerStateType: RegisterStateType.waiting));
  final BehaviorSubject<String> _emailController = BehaviorSubject<String>();
  final BehaviorSubject<String> _usernameController = BehaviorSubject<String>();
  final BehaviorSubject<String> _passwordController = BehaviorSubject<String>();
  final BehaviorSubject<String> _repeatPasswordController = BehaviorSubject<String>();
  final RegisterRepository registerRepository;
  MyLocalization myLocalization;
  Stream<RegisterState> get registerStateStream => _registerStateController.stream;

  Function(String) get onEmailChanged => _emailController.sink.add;
  Function(String) get onUsernameChanged => _usernameController.sink.add;
  Function(String) get onPasswordChanged => _passwordController.sink.add;
  Function(String) get onRepeatPasswordChanged => _repeatPasswordController.sink.add;
  Stream<String> get email => _emailController.stream.transform(StreamTransformer<String, String>.fromHandlers(
    handleData: (String email, EventSink<String> sink) => email.isNotEmpty && isEmail(email) ? sink.add(email)
      : sink.addError(email.isNotEmpty ? myLocalization.emailIsNotValid : myLocalization.enterYourEmail)
  ));
  Stream<String> get username => _usernameController.stream.transform(StreamTransformer<String, String>.fromHandlers(
    handleData: (String username, EventSink<String> sink) => username.isNotEmpty ? sink.add(username)
      : sink.addError(myLocalization.enterYourUsername)
  ));
  Stream<String> get password => _passwordController.stream.transform(StreamTransformer<String, String>.fromHandlers(
    handleData: (String password, EventSink<String> sink) => password.length >= 8 ? sink.add(password)
      : sink.addError(password.isNotEmpty ? myLocalization.passwordLengthError : myLocalization.enterYourPassword)
  ));
  Stream<String> get repeatPassword => _repeatPasswordController.stream.transform(StreamTransformer<String, String>.fromHandlers(
    handleData: (String repeatPassword, EventSink<String> sink) => repeatPassword.isNotEmpty
      && repeatPassword == _passwordController.value ? sink.add(repeatPassword)
      : sink.addError(repeatPassword.isEmpty ? myLocalization.enterYourPasswordAgain : myLocalization.passwordsDoNotMatch)
  ));
  Stream<bool> get registerValid => Rx.combineLatest4(_emailController.stream, _usernameController.stream, _passwordController.stream, _repeatPasswordController.stream,
    (String email, String username, String password, String repeatPassword) =>
    isEmail(_emailController.value) && _usernameController.value.isNotEmpty && _passwordController.value.length >= 6 &&
      _passwordController.value == _repeatPasswordController.value);

  void onRegisterTapped() {
    _registerStateController.add(RegisterState(registerStateType: RegisterStateType.loading));
    registerRepository.register(email: _emailController.value, username: _usernameController.value, password: _passwordController.value)
      .then((String securityToken) {
      _registerStateController.add(RegisterState(registerStateType: RegisterStateType.finished));
    }).catchError((dynamic error, StackTrace stackTrace) =>
      _registerStateController.add(RegisterState(registerStateType: RegisterStateType.error, error: error, stackTrace: stackTrace)));
  }

  @override
  void dispose() {
    _registerStateController?.close();
    _emailController?.close();
    _usernameController?.close();
    _passwordController?.close();
    _repeatPasswordController?.close();
  }
}
