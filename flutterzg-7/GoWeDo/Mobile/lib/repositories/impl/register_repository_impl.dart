import 'package:gowedo/repositories/register_repository.dart';
import 'package:gowedo/util/gowedo.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  @override
  Future<Null> register({String email, String username, String password}) {
    return GoWeDo.api.register(emailAddress: email, username: username, password: password);
  }
}
