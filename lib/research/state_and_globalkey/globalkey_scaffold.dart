import 'package:flutter/material.dart';

// global key technique works for accessing a scaffold

// Note we pass in the global key in the constructor of the Scaffold
//    Scaffold(key: globalKey... 
// is what we do here, which lets us get
// access to the ScaffoldState instance
// 
// When we have a custom widget, we must declare the stateful widget
// with the Another({Key key}) : super(key: key) constructor
// and just as with Scaffold, pass in the globalkey in the constructor
//    Another(key: globalKey)
// where globalKey is of type _AnotherState viz
//    final another = GlobalKey<_AnotherState>();
// MY mistake at some stage was to use the key in the constructor of
// Padding *inside* the _AnotherState build() method - WTF 😆


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


