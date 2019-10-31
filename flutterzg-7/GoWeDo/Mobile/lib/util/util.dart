import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gowedo/ui/dialogs/dialog_route.dart';
import 'package:gowedo/ui/dialogs/info_dialog.dart';
import 'package:gowedo/ui/dialogs/loading_dialog.dart';

import 'api_client.dart';
import 'my_colors.dart';
import 'my_localization.dart';
import 'gowedo.dart';

void doAfterBuild(Function function) {
  WidgetsBinding.instance.addPostFrameCallback((_)=> function());
}

void dismissLoadingDialog(BuildContext context) {
  Navigator.of(context).popUntil((Route<dynamic> route)=> route is! DialogRoute);
}

void showLoadingDialog(BuildContext context) {
  Util.showMyDialog<void>(barrierDismissible: false, context: context, child: const LoadingDialog());
}

void showErrorDialog(BuildContext context, String message, {dynamic error, StackTrace stackTrace}) {
  dismissLoadingDialog(context);
  Util.showErrorDialog(context, description: message, error: error, stackTrace: stackTrace);
}

String getRandomHello() {
  List<String> list = [
    'moo.mp3',
    'mooo.mp3',
    'moooo.mp3',
  ];
  int rand = Random().nextInt(3);
  print(rand);
  print(list[rand]);
  return list[rand];
}

class Util {
  static Future<T> showMyDialog<T>({
    @required BuildContext context,
    bool barrierDismissible = true,
    bool barrierColorTransparent = false,
    @required Widget child,
  }) {
    return Navigator.of(context, rootNavigator: true).push(DialogRoute<T>(
      child: child,
      theme: Theme.of(context, shadowThemeOnly: true),
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColorTransparent ? null : Colors.white.withOpacity(0.4),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    ));
  }

  static Future<void> showSuccessDialog(BuildContext context, {String title, @required String description}) {
    final String _title = title ?? MyLocalization.of(context).success;
    return Util.showMyDialog(
      context: context,
      child: InfoDialog(
        title: Text(_title,
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.display1.copyWith(
            fontSize: 25.0,
            fontWeight: FontWeight.w400,
            color: MyColors.goWeDoBlue
          )),
        message: Text(description,
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.display1.copyWith(
            fontSize: 17.0,
            fontWeight: FontWeight.w400
          ),
        ),
      )
    );
  }

  static Future<Null> showErrorDialog(BuildContext context, {String title, String description, dynamic error, StackTrace stackTrace}){
    Navigator.popUntil(context, (Route<dynamic> route) => route is! DialogRoute);

    String _errorFromJson;

    if (error != null){
      try{
        if(error is GoWeDoError){
          final GoWeDoError goWeDoError = error;
          if (goWeDoError.errorType == ErrorType.noConnection) {
            _errorFromJson = MyLocalization.of(context).noConnection;
          } else {
            _errorFromJson = error.errorString;
          }
        }else if(error is FlutterErrorDetails){
          _errorFromJson = error.exceptionAsString();

          print('Flutter error details:');
          print(error.library);
          print(error.informationCollector);
          print(error.stack);
        }else if(GoWeDo.isInDebugMode){
          _errorFromJson = error.toString();

          if(stackTrace != null){
            print('ERROR!');
            print('$stackTrace');
          }
        }
      }catch(exception){
        print(exception);
      }
    }

    _errorFromJson ??= MyLocalization.of(context).genericErrorMessage;

    final String _title = title ?? MyLocalization.of(context).genericErrorTitle;
    final String _error = description ?? _errorFromJson;

    print('Showing error: $_title - $_error');

    return showMyDialog(
      context: context,
      barrierDismissible: true,
      child: InfoDialog(
        title: Text(_title,
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.display1.copyWith(
            fontSize: 25.0,
            fontWeight: FontWeight.w400,
            color: MyColors.goWeDoBlue
          )),
        message: Text(_error,
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.display1.copyWith(
            fontSize: 17.0,
            fontWeight: FontWeight.w400
          ),
        ),
      )
    );
  }

  static Future<bool> showConfirmDialog(BuildContext context, {String title, String confirmButtonTitle}) {
    final String _title = title ?? MyLocalization.of(context).success;
    return Util.showMyDialog(
      context: context,
      child: InfoDialog(
        title: Text(_title,
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.display1.copyWith(
            fontSize: 25.0,
            fontWeight: FontWeight.w400,
            color: MyColors.goWeDoBlue
          )),
        showConfirmButton: true,
        confirmButtonTitle: confirmButtonTitle
      )
    );
  }

  static DateTime getCurrentDateTimeWithoutSeconds() {
    final DateTime currentDateTime = DateTime.now();
    return DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day, currentDateTime.hour, currentDateTime.minute);
  }

  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  static Widget getNoConnectionWidget(BuildContext context, {Color textColor = Colors.black}) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(MyLocalization.of(context).noConnection,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.title.copyWith(
            fontSize: 17.0,
            fontWeight: FontWeight.w400,
            color: textColor)
        ),
      ),
    );
  }
}
