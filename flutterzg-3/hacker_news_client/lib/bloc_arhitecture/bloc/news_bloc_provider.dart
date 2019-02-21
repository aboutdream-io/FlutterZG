import 'package:flutter/material.dart';
import 'package:hacker_news_client/bloc_arhitecture/bloc/news_bloc.dart';

class NewsBlocProvider extends InheritedWidget {
  const NewsBlocProvider({
    Key key,
    @required Widget child,
    @required this.bloc,
  })  : assert(child != null),
        super(key: key, child: child);

  final NewsBloc bloc;

  static NewsBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(NewsBlocProvider) as NewsBlocProvider).bloc;
  }

  @override
  bool updateShouldNotify(NewsBlocProvider oldWidget) {
    return bloc != oldWidget.bloc;
  }
}
