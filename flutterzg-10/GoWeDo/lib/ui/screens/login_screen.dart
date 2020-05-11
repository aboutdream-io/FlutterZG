import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gowedo/bloc/login_bloc.dart';
import 'package:gowedo/bloc/screen_state.dart';
import 'package:gowedo/ui/screens/feed_screen.dart';
import 'package:gowedo/ui/screens/register_screen.dart';
import 'package:gowedo/ui/widgets/confirm_button.dart';
import 'package:gowedo/util/my_colors.dart';
import 'package:gowedo/util/my_images.dart';
import 'package:gowedo/util/my_localization.dart';
import 'package:gowedo/util/util.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}): super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

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
    _usernameFocusNode?.dispose();
    _passwordFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LoginBloc loginBloc = Provider.of<LoginBloc>(context);
    loginBloc.myLocalization = MyLocalization.of(context);

    return Scaffold(
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
                  stream: loginBloc.loginStateStream,
                  builder: (BuildContext context, AsyncSnapshot<LoginState> snapshot) {
                    if(snapshot.hasData){
                      if(_oldLoginState != snapshot.data){
                        _oldLoginState = snapshot.data;
                        switch(snapshot.data.stateType){
                          case StateType.waiting:
                            WidgetsBinding.instance.addPostFrameCallback((_)=> dismissLoadingDialog(context));
                            break;
                          case StateType.loading:
                            WidgetsBinding.instance.addPostFrameCallback((_)=> showLoadingDialog(context));
                            break;
                          case StateType.finished:
                            WidgetsBinding.instance.addPostFrameCallback((_){
                              dismissLoadingDialog(context);
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (BuildContext context) => FeedScreen()),
                                  (Route<dynamic> route)=> false);
                            });
                            break;
                          case StateType.error:
                            WidgetsBinding.instance.addPostFrameCallback((_)=>
                              showErrorDialog(context, snapshot.data.message,
                                error: snapshot.data.error, stackTrace: snapshot.data.stackTrace));
                            break;
                          default:
                        }
                      }
                    }
                    return Container(
                      margin: const EdgeInsets.only(left: 30, right: 30, top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          StreamBuilder<String>(
                            stream: loginBloc.username,
                            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                              return TextField(
                                focusNode: _usernameFocusNode,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: loginBloc.onUsernameChanged,
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
                            stream: loginBloc.password,
                            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                              return TextField(
                                focusNode: _passwordFocusNode,
                                obscureText: true,
                                onChanged: loginBloc.onPasswordChanged,
                                decoration: InputDecoration(
                                  hintText: MyLocalization.of(context).password,
                                  errorText: snapshot.error
                                ),
                              );
                            }
                          ),
                          const SizedBox(height: 30),
                          StreamBuilder<bool>(
                            stream: loginBloc.loginValid,
                            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                              return ConfirmButton(
                                title: MyLocalization.of(context).login,
                                onTap: loginBloc.onLoginTapped,
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
                                onPressed: loginBloc.onFacebookLoginTapped,
                                child: Image.asset(MyImages.facebookLogo, height: 50),
                              ),
                              const SizedBox(width: 40),
                              CupertinoButton(
                                padding: const EdgeInsets.all(0),
                                onPressed: loginBloc.onGoogleLoginTapped,
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
    );
  }
}
