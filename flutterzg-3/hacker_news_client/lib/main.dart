import 'package:flutter/material.dart';
import 'package:hacker_news_client/bloc_arhitecture/bloc/news_bloc.dart';
import 'package:hacker_news_client/bloc_arhitecture/bloc/news_bloc_provider.dart';
import 'package:hacker_news_client/bloc_arhitecture/bloc/news_repository.dart';
import 'package:hacker_news_client/bloc_arhitecture/screens/main_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NewsBlocProvider(
      bloc: NewsBloc(NewsRepository()),
      child: MaterialApp(
        title: 'HN Client',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
        ),
        home: MainScreenBloc(),
      ),
    );
  }
}