import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gowedo/bloc/feed_bloc.dart';
import 'package:gowedo/bloc/login_bloc.dart';
import 'package:gowedo/bloc/register_bloc.dart';
import 'package:gowedo/repositories/impl/post_repository_impl.dart';
import 'package:gowedo/repositories/impl/register_repository_impl.dart';
import 'package:gowedo/ui/screens/feed_screen.dart';
import 'package:gowedo/util/gowedo.dart';
import 'package:provider/provider.dart';

import 'repositories/impl/login_repository_impl.dart';
import 'ui/dialogs/loading_dialog.dart';
import 'ui/screens/login_screen.dart';
import 'util/my_colors.dart';
import 'util/my_localization.dart';
import 'util/my_localization_delegate.dart';

/// Root Widget for the app
class MyApp extends StatelessWidget {

  Future<Widget> getFirstScreen() async {
    final String securityToken = await GoWeDo.localStorage.getSecurityToken().catchError((_) {
      return null;
    });
    if (securityToken != null) {
      print(securityToken);
      print('Going to user main menu!');
      return FeedScreen();
    }
    print('Going to login screen!');
    return const LoginScreen();
  }

  Typography get getTypography => Typography(platform: TargetPlatform.iOS);

  @override
  StatelessElement createElement() {
    /// Lock device orientation
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp]);
    return super.createElement();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LoginBloc>(
          create: (_) => LoginBloc(LoginRepositoryImpl()),
          dispose: (_, loginBloc) => loginBloc?.dispose(),
        ),
        Provider<RegisterBloc>(
          create: (_) => RegisterBloc(RegisterRepositoryImpl()),
          dispose: (_, registerBloc) => registerBloc?.dispose(),
        ),
        Provider<FeedBloc>(
          create: (_) => FeedBloc(PostRepositoryImpl()),
          dispose: (_, feedBloc) => feedBloc?.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'GoWeDo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColorBrightness: Brightness.light,
          textTheme: getTypography.black,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: MyColors.goWeDoWhite,
          hintColor: MyColors.goWeDoBlue.withOpacity(0.7),
          dividerColor: MyColors.goWeDoLightGray,
          splashColor: MyColors.goWeDoBlue.withOpacity(0.5),
          errorColor: MyColors.goWeDoErrorColor,
          accentColor: MyColors.goWeDoBlue,
          primaryColor: MyColors.goWeDoBlue,
          textSelectionColor: MyColors.goWeDoBlue.withOpacity(0.5),
          textSelectionHandleColor: MyColors.goWeDoBlue,
          primaryTextTheme: getTypography.black.copyWith(
            display1: getTypography.black.display1.copyWith(
              color: MyColors.goWeDoBlue,
            )),
          ),
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          MyLocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          const FallbackCupertinoLocalisationsDelegate()
        ],
        supportedLocales: supportedLocales,
        locale: const Locale('en', 'EN'),
        home: FutureBuilder<Widget>(
          future: getFirstScreen(),
          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
            return snapshot.data ?? const LoadingDialog();
          },
        ),
      ),
    );
  }
}

// added because of issue with textfields long click if this is missing
class FallbackCupertinoLocalisationsDelegate
  extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
    DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalisationsDelegate old) => false;
}
