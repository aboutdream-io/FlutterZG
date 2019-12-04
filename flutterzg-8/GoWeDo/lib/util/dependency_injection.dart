import 'package:flutter/widgets.dart';
import 'package:gowedo/repositories/login_repository.dart';
import 'package:gowedo/repositories/post_repository.dart';
import 'package:gowedo/repositories/register_repository.dart';

/// Injector is [InheritedWidget] that will hold all of app's repositories.
/// Repositories are initialized and used later as needed
class Injector extends InheritedWidget{

  const Injector({
    Key key,
    @required this.loginRepository,
    @required this.registerRepository,
    @required this.postRepository,
    @required Widget child,
  }) : super(key: key, child: child);

  final LoginRepository loginRepository;
  final RegisterRepository registerRepository;
  final PostRepository postRepository;

  static Injector of(BuildContext context) =>
    context.inheritFromWidgetOfExactType(Injector);

  @override
  bool updateShouldNotify(Injector oldWidget) {
    return loginRepository != oldWidget.loginRepository ||
      registerRepository != oldWidget.registerRepository ||
      postRepository != oldWidget.postRepository;
  }
}
