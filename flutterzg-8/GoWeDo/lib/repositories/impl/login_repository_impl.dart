import 'package:gowedo/util/gowedo.dart';

import '../login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  @override
  Future<String> login({String username, String password}) {
    return GoWeDo.api.login(username: username, password: password);
  }

  @override
  Future<Null> saveSecurityToken(String securityToken) {
    return GoWeDo.localStorage.setSecurityToken(securityToken);
  }

  @override
  Future<String> facebookLogin(String accessToken) {
    return GoWeDo.api.facebookLogin(accessToken);
  }

  @override
  Future<String> googleLogin(String idToken) {
    return GoWeDo.api.googleLogin(idToken);
  }
}
