import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gowedo/bloc/bloc_provider.dart';
import 'package:gowedo/bloc/login_bloc.dart';
import 'package:gowedo/ui/dialogs/dialog_route.dart';
import 'package:gowedo/ui/dialogs/loading_dialog.dart';
import 'package:gowedo/ui/screens/register_screen.dart';
import 'package:gowedo/ui/widgets/confirm_button.dart';
import 'package:gowedo/util/dependency_injection.dart';
import 'package:gowedo/util/my_colors.dart';
import 'package:gowedo/util/my_images.dart';
import 'package:gowedo/util/my_localization.dart';
import 'package:gowedo/util/util.dart';

import 'main_menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}): super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  LoginBloc _loginBloc;
  LoginState _oldLoginState;
  FocusNode _usernameFocusNode, _passwordFocusNode;

  @override
  void initState() {
    super.initState();

    _usernameFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _loginBloc?.dispose();
    _usernameFocusNode?.dispose();
    _passwordFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _loginBloc = LoginBloc(MyLocalization.of(context), Injector.of(context).loginRepository);
    return BlocProvider(
      bloc: _loginBloc,
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            _usernameFocusNode.unfocus();
            _passwordFocusNode.unfocus();
          },
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                color: MyColors.goWeDoBlue,
                height: 120,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  alignment: Alignment.bottomCenter,
                  child: Text(MyLocalization.of(context).gowedo,
                    style: Theme.of(context).primaryTextTheme.display1.copyWith(
                      fontSize: 50.0,
                      fontWeight: FontWeight.w500,
                      color: MyColors.goWeDoWhite)
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: StreamBuilder<LoginState>(
                    stream: _loginBloc.loginStateStream,
                    builder: (BuildContext context, AsyncSnapshot<LoginState> snapshot) {
                      if(snapshot.hasData){
                        if(_oldLoginState != snapshot.data){
                          _oldLoginState = snapshot.data;
                          switch(snapshot.data.loginStateType){
                            case LoginStateType.waiting:
                              WidgetsBinding.instance.addPostFrameCallback((_)=> dismissLoadingDialog());
                              break;
                            case LoginStateType.loading:
                              WidgetsBinding.instance.addPostFrameCallback((_)=> showLoadingDialog());
                              break;
                            case LoginStateType.finished:
                              WidgetsBinding.instance.addPostFrameCallback((_){
                                dismissLoadingDialog();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (BuildContext context) => const MainMenuScreen()),
                                    (Route<dynamic> route)=> false);
                              });
                              break;
                            case LoginStateType.error:
                              WidgetsBinding.instance.addPostFrameCallback((_)=>
                                showErrorDialog(snapshot.data.message,
                                  error: snapshot.data.error, stackTrace: snapshot.data.stackTrace));
                              break;
                          }
                        }
                      }
                      return Container(
                        margin: const EdgeInsets.only(left: 30, right: 30, top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            StreamBuilder<String>(
                              stream: _loginBloc.username,
                              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                return TextField(
                                  focusNode: _usernameFocusNode,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: _loginBloc.onUsernameChanged,
                                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                                  decoration: InputDecoration(
                                    hintText: MyLocalization.of(context).username,
                                    errorText: snapshot.error
                                  )
                                );
                              }
                            ),
                            const SizedBox(height: 10),
                            StreamBuilder<String>(
                              stream: _loginBloc.password,
                              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                return TextField(
                                  focusNode: _passwordFocusNode,
                                  obscureText: true,
                                  onChanged: _loginBloc.onPasswordChanged,
                                  decoration: InputDecoration(
                                    hintText: MyLocalization.of(context).password,
                                    errorText: snapshot.error
                                  ),
                                );
                              }
                            ),
                            const SizedBox(height: 30),
                            StreamBuilder<bool>(
                              stream: _loginBloc.loginValid,
                              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                return ConfirmButton(
                                  title: MyLocalization.of(context).login,
                                  onTap: _loginBloc.onLoginTapped,
                                  isEnabled: snapshot.hasData && snapshot.data,
                                );
                              }
                            ),
                            const SizedBox(height: 20),
                            ConfirmButton(
                              title: MyLocalization.of(context).register,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (BuildContext context) => const RegisterScreen()))
                            ),
                            const SizedBox(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CupertinoButton(
                                  padding: const EdgeInsets.all(0),
                                  onPressed: _loginBloc.onFacebookLoginTapped,
                                  child: Image.asset(MyImages.facebookLogo, height: 50),
                                ),
                                const SizedBox(width: 40),
                                CupertinoButton(
                                  padding: const EdgeInsets.all(0),
                                  onPressed: _loginBloc.onGoogleLoginTapped,
                                  child: Image.asset(MyImages.googleLogo, height: 50),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    }
                  )
                ),
              ),
            ],
          ),
        )
      ),
    );
  }

  void dismissLoadingDialog() {
    Navigator.of(context).popUntil((Route<dynamic> route)=> route is! DialogRoute);
  }

  void showLoadingDialog() {
    Util.showMyDialog<void>(barrierDismissible: false, context: context, child: const LoadingDialog());
  }

  void showErrorDialog(String message, {dynamic error, StackTrace stackTrace}) {
    dismissLoadingDialog();
    Util.showErrorDialog(context, description: message, error: error, stackTrace: stackTrace);
  }
}
