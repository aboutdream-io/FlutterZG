abstract class LoginRepository {
  Future<String> login({String username, String password});
  Future<Null> saveSecurityToken(String securityToken);
  Future<String> facebookLogin(String accessToken);
  Future<String> googleLogin(String idToken);
}
