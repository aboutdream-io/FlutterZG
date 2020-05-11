import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gowedo/bloc/register_bloc.dart';
import 'package:gowedo/ui/dialogs/dialog_route.dart';
import 'package:gowedo/ui/dialogs/loading_dialog.dart';
import 'package:gowedo/ui/widgets/confirm_button.dart';
import 'package:gowedo/util/my_colors.dart';
import 'package:gowedo/util/my_localization.dart';
import 'package:gowedo/util/util.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key key}): super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  RegisterState _oldRegisterState;
  FocusNode _emailFocusNode, _usernameFocusNode, _passwordFocusNode, _repeatPasswordFocusNode;

  @override
  void initState() {
    super.initState();

    _emailFocusNode = FocusNode();
    _usernameFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _repeatPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _repeatPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RegisterBloc registerBloc = Provider.of<RegisterBloc>(context);
    registerBloc.myLocalization = MyLocalization.of(context);

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _emailFocusNode.unfocus();
          _usernameFocusNode.unfocus();
          _passwordFocusNode.unfocus();
          _repeatPasswordFocusNode.unfocus();
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 20),
                child: CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Icon(Icons.arrow_back, color: MyColors.goWeDoBlue)
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 40, right: 40, top: 10),
                  child: SingleChildScrollView(
                    child: StreamBuilder(
                      stream: registerBloc.registerStateStream,
                      builder: (BuildContext context, AsyncSnapshot<RegisterState> snapshot){
                        if(snapshot.hasData){
                          if(_oldRegisterState != snapshot.data){
                            _oldRegisterState = snapshot.data;
                            switch(snapshot.data.registerStateType){
                              case RegisterStateType.waiting:
                                WidgetsBinding.instance.addPostFrameCallback((_)=> dismissLoadingDialog());
                                break;
                              case RegisterStateType.loading:
                                WidgetsBinding.instance.addPostFrameCallback((_)=> showLoadingDialog());
                                break;
                              case RegisterStateType.finished:
                                WidgetsBinding.instance.addPostFrameCallback((_)=> showSuccessDialog());
                                break;
                              case RegisterStateType.error:
                                WidgetsBinding.instance.addPostFrameCallback((_)=>
                                  showErrorDialog(
                                    null, error: snapshot.data.error, stackTrace: snapshot.data.stackTrace));
                                break;
                            }
                          }
                        }
                        return Column(
                          children: <Widget>[
                            Text(MyLocalization.of(context).createAccount,
                              style: Theme.of(context).primaryTextTheme.display1.copyWith(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w500,
                                color: MyColors.goWeDoBlue)
                            ),
                            const SizedBox(height: 30),
                            StreamBuilder<String>(
                              stream: registerBloc.email,
                              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                return TextField(
                                  focusNode: _emailFocusNode,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: registerBloc.onEmailChanged,
                                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_usernameFocusNode),
                                  decoration: InputDecoration(
                                    hintText: MyLocalization.of(context).email,
                                    errorText: snapshot.error
                                  ),
                                );
                              }
                            ),
                            const SizedBox(height: 10),
                            StreamBuilder<String>(
                              stream: registerBloc.username,
                              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                return TextField(
                                  focusNode: _usernameFocusNode,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: registerBloc.onUsernameChanged,
                                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                                  decoration: InputDecoration(
                                    hintText: MyLocalization.of(context).username,
                                    errorText: snapshot.error
                                  ),
                                );
                              }
                            ),
                            const SizedBox(height: 10),
                            StreamBuilder<String>(
                              stream: registerBloc.password,
                              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                return TextField(
                                  focusNode: _passwordFocusNode,
                                  obscureText: true,
                                  onChanged: registerBloc.onPasswordChanged,
                                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_repeatPasswordFocusNode),
                                  decoration: InputDecoration(
                                    hintText: MyLocalization.of(context).password,
                                    errorText: snapshot.error
                                  ),
                                );
                              }
                            ),
                            const SizedBox(height: 10),
                            StreamBuilder<String>(
                              stream: registerBloc.repeatPassword,
                              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                return TextField(
                                  focusNode: _repeatPasswordFocusNode,
                                  obscureText: true,
                                  onChanged: registerBloc.onRepeatPasswordChanged,
                                  decoration: InputDecoration(
                                    hintText: MyLocalization.of(context).repeatPassword,
                                    errorText: snapshot.error,
                                  ),
                                );
                              }
                            ),
                            const SizedBox(height: 30),
                            StreamBuilder<bool>(
                              stream: registerBloc.registerValid,
                              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                return ConfirmButton(
                                  title: MyLocalization.of(context).register,
                                  onTap: registerBloc.onRegisterTapped,
                                  isEnabled: snapshot.hasData && snapshot.data,
                                );
                              }
                            ),
                          ],
                        );
                      }
                    )
                  ),
                ),
              ),
            ],
          ),
        ),
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

  void showSuccessDialog() {
    dismissLoadingDialog();
    Util.showSuccessDialog(context, description: MyLocalization.of(context).registerSuccess)
      .then((_) => Navigator.of(context).pop());
  }
}
