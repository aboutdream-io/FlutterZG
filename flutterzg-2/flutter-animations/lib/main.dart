import 'package:flutter/material.dart';
import 'package:flutter_animations/animated_container_example.dart';
import 'package:flutter_animations/easinganimationwidget.dart';
import 'package:flutter_animations/hero_animation.dart';
import 'package:flutter_animations/maskinganimationwidget.dart';
import 'package:flutter_animations/offsetdelayanimation.dart';
import 'package:flutter_animations/parentinganimation.dart';
import 'package:flutter_animations/springfreefallinganimation.dart';
import 'package:flutter_animations/transformationanimationwidget.dart';

void main() => runApp(new MyApp());

enum AnimationWidgets{
  easing, offset, parenting, transformation, masking, springFreeFall, animatedContainer, hero
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Meetup Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: "Meetup Animations Demo"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() {
    return new MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  AnimationWidgets _animatedWidget;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: new Text(widget.title),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              title: Text("Easing animation"),
              onTap: () {
                  setState((){
                    _animatedWidget = AnimationWidgets.easing;
                  });
              },
            ),
            ListTile(
              title: Text("Offset & Delay animation"),
              onTap: () {
                  setState((){
                    _animatedWidget = AnimationWidgets.offset;
                  });
              },
            ),
            ListTile(
              title: Text("Parenting animation"),
              onTap: () {
                  setState((){
                    _animatedWidget = AnimationWidgets.parenting;
                  });
              },
            ),
            ListTile(
              title: Text("Transformation animation"),
              onTap: () {
                  setState((){
                    _animatedWidget = AnimationWidgets.transformation;
                  });
              },
            ),
            ListTile(
              title: Text("Masking animation"),
              onTap: () {
                  setState((){
                    _animatedWidget = AnimationWidgets.masking;
                  });
              },
            ),
            ListTile(
              title: Text("Physics animation"),
              onTap: () {
                  setState((){
                    _animatedWidget = AnimationWidgets.springFreeFall;
                  });
              },
            ),
            ListTile(
              title: Text("Animated container"),
              onTap: () {
                setState((){
                  _animatedWidget = AnimationWidgets.animatedContainer;
                });
              },
            ),

            ListTile(
              title: Text("Hero animation"),
              onTap: () {
                setState((){
                  _animatedWidget = null;
                });

                Navigator.of(context).push<Null>(PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 1500),
                  pageBuilder: (BuildContext context, Animation<double> intro, Animation<double> outro){
                    return FadeTransition(
                      opacity: intro,
                      child: HeroScreen()
                    );
                  }
                ));
              },
            ),

            SizedBox(height: 20.0),

            _showWidget(),
          ],
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  Widget _showWidget(){
    switch(_animatedWidget){
      case AnimationWidgets.easing:
        return EasingAnimationWidget();
      case AnimationWidgets.masking:
        return MaskingAnimationWidget();
      case AnimationWidgets.offset:
        return OffsetDelayAnimationWidget();
      case AnimationWidgets.parenting:
        return ParentingAnimationWidget();
      case AnimationWidgets.springFreeFall:
        return SpringFreeFallingAnimation();
      case AnimationWidgets.transformation:
        return TransformationAnimationWidget();
      case AnimationWidgets.animatedContainer:
        return AnimatedContainerWidget();
      case AnimationWidgets.hero:
        return Container();
      default:
        return Container(
          alignment: Alignment.center,
          child: Hero(
            tag: 'hero_1',
            child: Container(
              width: 200.0,
              height: 200.0,
              color: Colors.black12,
              child: FlutterLogo(),
            ),
          ),
        );
    }
  }
}