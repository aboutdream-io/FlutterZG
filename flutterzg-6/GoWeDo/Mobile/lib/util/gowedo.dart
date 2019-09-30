import 'dart:io';

import 'api_calls.dart';
import 'local_storage.dart';

enum Flavour {
  production,
  development,
}

class GoWeDo {
  static final GoWeDo _goWeDo = new GoWeDo._internal();
  static Flavour _flavour;
  static LocalStorage localStorage;
  static ApiCalls api;

  factory GoWeDo() {
    return _goWeDo;
  }

  GoWeDo._internal();

  static Future<void> configure(Flavour flavour) async {
    print('Configuring app with: ${flavour.toString()}');
    _flavour = flavour;

    localStorage = LocalStorage();
    api = ApiCalls();
  }

  Flavour get appFlavour => _flavour;

  String platformType = Platform.isIOS ? 'ios' : 'android';

  static String get server {
    switch (_flavour) {
      case Flavour.production:
        return 'https://gowedo.hot-soup.com/api';
      default:
        return 'https://gowedo.hot-soup.com/api';
    }
  }

  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}
