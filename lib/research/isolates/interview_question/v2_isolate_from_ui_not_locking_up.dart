import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

// Launch isolate from UI event and not lock up the UI
// https://stackoverflow.com/questions/56758816/flutter-ui-hangs-on-async-operation
// DOESN'T WORK IN CHROME DEVICE - presumably cos cannot launch threads

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolate Experiment',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  var title = 'How to not lock UI using isolate (stackoverflow)';

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _pressed() async {
    print("I am pressed");
    print("I will make a cheap operation now");

    // string returned is "Good Morning"
    String string =
        await compute(runExpensiveOperation, null); // this is what you need
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            RaisedButton(
              child: Text("Press me for tough operation"),
              onPressed: _pressed,
            ),
            RaisedButton(
              child: Text("Do nothing (check UI responsiveness)"),
              onPressed: () => print('hi'),
            )
          ],
        ),
      ),
    );
  }
}

// make sure this is outside your class definition
Future<String> runExpensiveOperation(void _) async {
  print('starting expensive operation');
  for (var i = 0; i < 1000000; i++) {
    List<int> bytes = utf8.encode('somethingtohash');
    String hash = sha256.convert(bytes).toString();
  }
  print('finished expensive operation');
  return "Good Morning";
}
