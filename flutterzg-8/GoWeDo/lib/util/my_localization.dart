import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'l10n/strings_messages_all.dart';

const List<Locale> supportedLocales = const <Locale>[
  const Locale('en', 'US'),
  const Locale('hr', 'HR')
];

class MyLocalization extends DefaultMaterialLocalizations {
  MyLocalization();

  static Future<MaterialLocalizations> load(Locale locale){
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool value){
      Intl.defaultLocale = localeName;
      return MyLocalization();
    });
  }

  static MyLocalization of(BuildContext context){
    return Localizations.of<MaterialLocalizations>(context, MaterialLocalizations);
  }

  String get _dayMonthYearFormat => Intl.message('dd.MM.yyyy', name: '_dayMonthYearFormat');
  String get _hourMinuteFormat => Intl.message('HH:mm', name: '_hourMinuteFormat');
  String get _dayMonthYearHourMinuteFormat => Intl.message('dd.MM.yyyy - HH:mm', name: '_dayMonthYearHourMinuteFormat');
  String get _monthNameFormat => Intl.message('MMMM', name: '_monthNameFormat');

  String getDayMonthYearString(DateTime date) {
    if (date == null) {
      return '';
    }
    return DateFormat(_dayMonthYearFormat).format(date);
  }

  String getHourMinuteString(DateTime date) {
    if (date == null) {
      return '';
    }
    return DateFormat(_hourMinuteFormat).format(date);
  }

  String getDayMonthYearHourMinuteString(DateTime date) {
    if (date == null) {
      return '';
    }
    return DateFormat(_dayMonthYearHourMinuteFormat).format(date);
  }

  String getMonthNameString(DateTime date) {
    if (date == null) {
      return '';
    }
    return DateFormat(_monthNameFormat).format(date);
  }

  String get register => Intl.message('Register', name: 'register');
  String get login => Intl.message('Login', name: 'login');
  String get genericErrorTitle => Intl.message('Error', name: 'genericErrorTitle');
  String get genericErrorMessage => Intl.message('Please try again', name: 'genericErrorMessage');
  String get success => Intl.message('Success', name: 'success');
  String get confirm => Intl.message('Confirm', name: 'confirm');
  String get done => Intl.message('Done', name: 'done');
  String get noConnection => Intl.message('Please turn on Internet connection to be able to use the app', name: 'noConnection');
  String get forgottenPassword => Intl.message('Forgotten password', name: 'forgottenPassword');
  String get proceed => Intl.message('Continue', name: 'proceed');
  String get gowedo => Intl.message('GoWeDo', name: 'gowedo');
  String get enterYourUsername => Intl.message('Enter your username', name: 'enterYourUsername');
  String get enterYourPassword => Intl.message('Enter your password', name: 'enterYourPassword');
  String get email => Intl.message('Email', name: 'email');
  String get username => Intl.message('Username', name: 'username');
  String get password => Intl.message('Password', name: 'password');
  String get repeatPassword => Intl.message('Repeat password', name: 'repeatPassword');
  String get createAccount => Intl.message('Please create your GoWeDo account', name: 'createAccount');
  String get emailIsNotValid => Intl.message('Email is not valid', name: 'emailIsNotValid');
  String get enterYourEmail => Intl.message('Enter your email', name: 'enterYourEmail');
  String get passwordLengthError => Intl.message('Password should be at least 8 characters long', name: 'passwordLengthError');
  String get enterYourPasswordAgain => Intl.message('Enter your password again', name: 'enterYourPasswordAgain');
  String get passwordsDoNotMatch => Intl.message('Passwords don\'t match', name: 'passwordsDoNotMatch');
  String get googleLoginFailed => Intl.message('Google login failed', name: 'googleLoginFailed');
  String get facebookLoginFailed => Intl.message('Facebook login failed', name: 'facebookLoginFailed');
  String get registerSuccess => Intl.message('You have successfully created GoWeDo account, ''you can log in with your credentials', name: 'registerSuccess');
  String get create => Intl.message('Create', name: 'create');
  String get description => Intl.message('Description', name: 'description');
  String get title => Intl.message('Title', name: 'title');
  String get newPost => Intl.message('New Post', name: 'newPost');
  String get uploadImage => Intl.message('Upload an image', name: 'uploadImage');
  String get uploadFailed => Intl.message('Upload failed!', name: 'uploadFailed');
  String get noImage => Intl.message('Please upload an image...', name: 'noImage');
  String get noTitle => Intl.message('Please enter title...', name: 'noTitle');
  String get noDescription => Intl.message('Please enter description...', name: 'newPostPrefix');
  String get newPostPrefix => Intl.message('New post: ', name: 'noDescription');
  String get byPrefix => Intl.message('by ', name: 'byPrefix');
  String get showNewPosts => Intl.message('Show new posts', name: 'showNewPosts');
}
