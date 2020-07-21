import 'package:flutter/material.dart';

// global key technique works for accessing a scaffold
// but not when accessing other custom widgets - why?

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

final globalKey = GlobalKey<ScaffoldState>(); // HACK1 allocate a new key

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        key: globalKey, // HACK1 make Scaffold use it, thus giving us access
        appBar: AppBar(
          title: Text('Welcome to Flutter'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text('Hello World'),
            ),
            // AndyStateless(),
            // AndyStateful(),
            // Another(),
            AnotherButton(),
          ],
        ),
      ),
    );
  }
}

// External Widget which accesses 'another' via key - naughty but nice - works

class AnotherButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(
        child: Text('am outside widget'),
        onPressed: () {
          print('$globalKey ${globalKey.currentState}');
          globalKey.currentState
                .showSnackBar(SnackBar(content: Text('Hey')));
        },
      ),
    );
  }
}


