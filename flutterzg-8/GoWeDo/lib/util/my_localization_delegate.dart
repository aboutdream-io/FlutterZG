import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'my_localization.dart';

class MyLocalizationDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  @override
  bool isSupported(Locale locale) => supportedLocales.map((Locale locale) => locale.languageCode).contains(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale locale) => MyLocalization.load(locale);

  @override
  bool shouldReload(MyLocalizationDelegate old) => false;
}