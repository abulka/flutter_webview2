import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dart_random_choice/dart_random_choice.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ListView Experiments',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // home: MyHomePage(title: 'ListView experiments'),

      home: Scaffold(
        appBar: AppBar(title: Text('Creating things dynamically')),
        body: BodyLayout(),
      ),
    );
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          color: Colors.amber[500],
          child: const Center(child: Text('... is what flutter does!')),
        ),
        inputArea(),
        exampleButtonsArea(),
      ],
    );
  }

  Expanded exampleButtonsArea() {
    List columnHeaders = ['a', 'b', 'c', 'd'];
    List buttonLabels = ['Do a', 'Do b', 'Do c', 'Do d'];
    return Expanded(
      child: SingleChildScrollView(
        child: Wrap(
          children: [
            RaisedButton(
              onPressed: () {},
              child: Text('example to inch'),
            ),
            RaisedButton(
              onPressed: () {},
              child: Text('example sin'),
            ),
            RaisedButton(
              onPressed: () {},
              child: Text('example math.pow'),
            ),
            RaisedButton(
              onPressed: () {},
              child: Text('complex({ r: sqrt(2), phi: pi / 4 })'),
            ),
            Container(
              color: Colors.redAccent,
              height: 30,
              width: 130,
            ),
            Container(
              color: Colors.red[200],
              height: 30,
              width: 130,
            ),
            Container(
              color: Colors.red[300],
              height: 30,
              width: 130,
            ),
            Container(
              color: Colors.red[400],
              height: 30,
              width: 130,
            ),
            Container(
              color: Colors.red[600],
              height: 30,
              width: 130,
            ),
          ]
            ..addAll(columnHeaders
                .map((header) => new Container(
                      color: randomChoice([
                        Colors.amber,
                        Colors.green,
                        Colors.blue[400],
                        Colors.orange,
                        Colors.indigo[200]
                      ]),
                      alignment: FractionalOffset.center,
                      width: 120.0,
                      margin: EdgeInsets.all(3.0),
                      padding: const EdgeInsets.only(
                          top: 5.0, bottom: 5.0, right: 3.0, left: 3.0),
                      child: new Text(
                        header,
                        style: TextStyle(color: Colors.grey[800]),
                        textAlign: TextAlign.center,
                      ),
                    ))
                .toList())
            ..addAll(buttonLabels
                .map((label) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                        child: Text('example button $label'),
                        onPressed: () {},
                        padding: EdgeInsets.all(30),
                      ),
                ))
                .toList()),
        ),
      ),
    );
  }

  Container inputArea() {
    return Container(
      color: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              contentPadding:
                  const EdgeInsets.only(left: 4.0, bottom: 2.0, top: 2.0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(1))),
              hintText: 'Enter a math term'),
          onChanged: (text) {
            print("text field so far...: $text");
          },
          onSubmitted: (value) {},
        ),
      ),
    );
  }
}
