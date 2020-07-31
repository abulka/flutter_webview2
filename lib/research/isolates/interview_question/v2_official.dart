import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'playHideAndSeekIsolate.dart';
import 'playHideAndSeekAsync.dart';

/*
 Official Interview question answer: It blocks your app because counting to ten
 billion is a computationally expensive task, even for a computer. Dart code
 runs inside its own area of memory called an isolate — also known as memory
 thread. Each isolate has its own memory heap, which ensures that no isolate can
 access any other isolate's state.

 Making it an async function wouldn't help, either, because it would still run
 on the same isolate.

 OFFICIAL ANSWER is so simple - but uses the magical compute() function 
 (requires import 'package:flutter/foundation.dart';)
 which requires flutter - cannot run this as pure dart.
 */

// Official interview question Isolate version
// - runs in separate thread - however requires flutter

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
      home: Scaffold(
        appBar: AppBar(title: Text('Spawning Isolate thread from button')),
        // body: Container(color: Colors.amber, height: 200,),
        body: Body(),
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Container(color: Colors.amber, child: Text('hello, world')),
        ),
        Column(
          children: [
            RaisedButton(
              onPressed: () async {
                // Official interview question Isolate version - runs in
                // separate thread - Requires flutter due to its reliance on the
                // magical compute() function
                print('spawning thread (note, this doesn\'t work in chrome device)...');
                String s = await makeSomeoneElseCountForMe();
                print(s);
              },
              child: Text('spawn isolate thread'),
            ),
            RaisedButton(
              onPressed: () async {
                // Async, which still runs the counters in the same
                // thread thus doesn't help with counting to 1 billion.
                print('awaiting async...');
                // YIKES - this locks up the UI !!!!!!!!!!!!!
                String s = await playHideAndSeekTheLongVersionAsync();
                print(s);
              },
              child: Text('async (warning, this will lock the UI)'),
            ),
            RaisedButton(
              onPressed: () {
                print('hi');
              },
              child: Text('do nothing (ensure UI responsive)',
                  style: TextStyle(color: Colors.blue, fontSize: 18.0, fontWeight: FontWeight.bold)),
            ),
          ],
        )
      ],
    );
  }
}

// Business Logic

Future<String> makeSomeoneElseCountForMe() async {
  // THIS LINE CONTAINING 'compute()' REQUIRES A FLUTTER PROJECT, NOT JUST DART
  return await compute(playHideAndSeekIsolate2, 4000000000);
}

/// this version doesn't take a sendport - nice and simple
String playHideAndSeekIsolate2(int countTo) {
  var counting = 0;
  for (var i = 1; i <= countTo; i++) {
    counting = i;
  }
  return '$counting (isolate, official answer)! Ready or not, here I come!';
}
