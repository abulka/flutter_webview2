import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:provider/provider.dart';

// interview question puzzles
// https://www.raywenderlich.com/10971345-flutter-interview-questions-and-answers

void main() {
  runApp(MyApp());
}

class MyModel extends ChangeNotifier {
  List buttonLabels = ['Do A', 'Do B', 'Do C', 'Do D'];

  void add(String label) {
    buttonLabels.add(label);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Experiments',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Interview Questions Learning')),
        body: BodyLayout(),
      ),
    );
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyModel(),
        builder: (context, child) {
          return Column(
            children: [
              MyTextWidget(),
              MyTextWidget(
                kind: Kind.fittedBox,
              ),
              MyTextWidget(
                kind: Kind.fittedBoxNoRowOrIcons,
              ),
              MyTextWidget(
                kind: Kind.expanded,
              ),
              MyTextWidget(
                kind: Kind.expandedFittedBox,
              ),
              NestedScaffolds(),
            ],
          );
        });
  }
}

// Text Widget variants

enum Kind {
  none,
  fittedBox,
  fittedBoxNoRowOrIcons,
  expandedFittedBox,
  expanded
}

extension ParseToString on Kind {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

class MyTextWidget extends StatelessWidget {
  final personNextToMe =
      'That reminds me about the time when I was ten and our neighbor, her name was Mrs. Mable, and she said...';
  final Kind kind;
  MyTextWidget({this.kind = Kind.none});

  @override
  Widget build(BuildContext context) {
    var widget;
    var txt = '$personNextToMe ${this.kind}';
    // var txt = this.kind.toString().split('.').last;
    // var txt = '$personNextToMe (${this.kind.toShortString()})';

    switch (this.kind) {
      case Kind.expanded:
        txt += ' (notice this wraps)';
        widget = Expanded(child: Text(txt));
        break;
      case Kind.fittedBox:
        widget = FittedBox(child: Text(txt));
        break;
      case Kind.expandedFittedBox:
        widget = Expanded(child: FittedBox(child: Text(txt)));
        break;
      case Kind.fittedBoxNoRowOrIcons:
        widget = FittedBox(
            child: Text(
          txt,
          // style: new TextStyle(
          //     color: Colors.orange[900],
          //     fontWeight: FontWeight.bold,
          //     fontFamily: "Roboto"),
        ));
        return widget;
        break;
      default:
        widget = Text(txt);
    }

    return Row(children: [
      Icon(Icons.airline_seat_legroom_reduced),
      widget,
      Icon(Icons.airline_seat_legroom_reduced),
    ]);
  }
}

class NestedScaffolds extends StatelessWidget {
  const NestedScaffolds({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Scaffold(
        appBar: AppBar(title: Text('sub scaffold')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Colors.red,
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Scaffold(
                appBar: AppBar(title: Text('sub sub scaffold')),
                body: Row(
                  // mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.blue,
                        height: 100,
                        child: Text('body of sub sub'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
