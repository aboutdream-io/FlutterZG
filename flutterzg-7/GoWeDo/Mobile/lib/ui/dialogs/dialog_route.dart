import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DialogRoute<T> extends PopupRoute<T> {
  DialogRoute({
    @required this.theme,
    bool barrierDismissible = true,
    Color barrierColor,
    this.barrierLabel,
    @required this.child,
  }) : assert(barrierDismissible != null),
      _barrierDismissible = barrierDismissible,
      _barrierColor = barrierColor;

  final Widget child;
  final ThemeData theme;
  final bool _barrierDismissible;
  final Color _barrierColor;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  Color get barrierColor => _barrierColor;

  @override
  final String barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return new Builder(
      builder: (BuildContext context) {
        return theme != null ? new Theme(data: theme, child: child) : child;
      }
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(
      opacity: new CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut
      ),
      child: child
    );
  }
}
