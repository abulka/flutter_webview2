import 'dart:async';
import 'dart:io';
import 'dart:isolate';
// import 'package:flutter/foundation.dart';
import "package:isolate/isolate.dart";

/* 
  Futures (run in same thread) vs Isolates (run in separate thread)
  Run: dart lib/research/futures/futures_vs_isolates.dart

  async, which still runs the counters in the same
  thread thus doesn't help with counting to 1 billion.
*/

Isolate isolate; // holds ref to isolate
String returnValueFromIsolate;

// Official interview question Isolate version
// - runs in separate thread - however requires flutter
void main1() async {
  String s;

  // Official interview question Isolate version - runs in separate thread -
  // requires flutter due to its reliance on the magical compute() function
  // s = await makeSomeoneElseCountForMe();
  // print(s);

  // Async, which still runs the counters in the same
  // thread thus doesn't help with counting to 1 billion.
  s = await playHideAndSeekTheLongVersion();
  print(s);
}

// ASYNC version - takes 29s to count to a billion - slower than isolate!
// isolate version only takes 8s

Future<String> playHideAndSeekTheLongVersion() async {
  const billion = 10000000000; // why 28 secs ?
  const easier = 1000000000; // 3 secs
  var counting = 0;
  // for (var i = 1; i <= billion; i++) {
  for (var i = 1; i <= easier; i++) {
    counting = i;
  }
  return '  PLAIN ASYNC VERSION $counting! Ready or not, here I come!';
}

// ANDY ATTEMPT AT ISOLATE VERSION - abandoned since I can't
// figure out how to gracefully exit once the isolate is done.

// void main() async {
//   // Isolate version - runs in separate thread
//   await start(); // 'await' applied to 'void', which is not a 'Future' ?

//   // Async, which still runs the counters in the same
//   // thread thus doesn't help with counting to 1 billion.
//   String s = await playHideAndSeekTheLongVersion();
//   print(s);

//   // if (returnValueFromIsolate != null) {
//   //   stop();
//   //   exit(0); // why do I need an explicit exit - otherwise app hangs?
//   // } else
//   //   print('isolate has not finished, we are left hanging');
//   //
//   // await theIsolate;  <--- WE WANT SOMETHING LIKE THIS (aha see below)
//   exit(0);
// }

void main() async {
  Future t = MyOperation().start();
  print('isolate thread should now be computing...');
  // await t; // uncomment if want the culumative times

  // Async, which still runs the counters in the same
  // thread thus doesn't help with counting to 1 billion.
  print('main thread computing...');
  String s = await playHideAndSeekTheLongVersion();
  print(s);

  await t;
  print('if both messages print at < their individual cumulative times the same time it means they ran in parallel ok');
  stop();
  exit(0);
}

void start() async {
  ReceivePort receivePort =
      ReceivePort(); //port for this main isolate to receive messages.
  isolate = await Isolate.spawn(
      playHideAndSeekTheLongVersionIsolate, receivePort.sendPort); // create it!

  // interesting that the same .listen() pattern is used here
  receivePort.listen((data) {
    print('$data (from receivePort)');
    stop(); // don't stop in here, doesn't seem to work
  });
}

void stop() {
  if (isolate != null) {
    print('killing isolate');
    isolate.kill(priority: Isolate.immediate);
    isolate = null;
  }
}

/// Isolate version is not async, returns void,
/// and takes SendPort sendPort as parameter.
/// Don't return, send a message instead.
void playHideAndSeekTheLongVersionIsolate(SendPort sendPort) {
  var counting = 0;
  for (var i = 1; i <= 10000000000; i++) {
    // for (var i = 1; i <= 10000000; i++) {
    // for (var i = 1; i <= 1000000000; i++) {
    counting = i;
  }
  // return '$counting! Ready or not, here I come!';
  sendPort
      .send('  ISOLATE VERSION $counting! Ready or not, here I come!');
}

/// https://api.dart.dev/stable/2.8.4/dart-async/Completer-class.html
/// experiment - WORKS - it was a guess, but it works!
class MyOperation {
  Completer _completer = new Completer();

  Future<void> start() async {
    ReceivePort receivePort =
        ReceivePort(); //port for this main isolate to receive messages.
    isolate = await Isolate.spawn(playHideAndSeekTheLongVersionIsolate,
        receivePort.sendPort); // create it!

    receivePort.listen((data) {
      print('$data (from receivePort) (MyOperation)');
      _finishOperation();
    });
    return _completer.future; // Send future object back to client.
  }

  // Something calls this when the value is ready.
  void _finishOperation() {
    // _completer.complete(result);
    _completer.complete();
  }

  // // If something goes wrong, call this.
  // void _errorHappened(error) {
  //   _completer.completeError(error);
  // }
}

// Official Interview question answer:

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

Future<String> makeSomeoneElseCountForMe() async {
  // THIS LINE REQUIRES FLUTTER, NOT JUST DART
  // return await compute(playHideAndSeekTheLongVersion2, 10000000000);
}

String playHideAndSeekTheLongVersion2(int countTo) {
  var counting = 0;
  for (var i = 1; i <= countTo; i++) {
    counting = i;
  }
  return '$counting (isolate, official answer)! Ready or not, here I come!';
}

// ANOTHER APPROACH (DIFFERENT EXAMPLE THOUGH) FROM STACKOVERFLOW
// Spawns another file - how cool is that! - WORKS
// https://stackoverflow.com/questions/31013229/how-to-use-results-from-different-isolates-in-the-main-isolate

main2() {
  var rPort1 = new ReceivePort();
  var rPort2 = new ReceivePort();

  Future.wait([
    Isolate.spawnUri(new Uri.file("my_isolate.dart"), ['0'], rPort1.sendPort)
        .then((_) => rPort1.first, onError: (x) {
      print('error in first spawn $x');
      rPort1.close();
    }),
    Isolate.spawnUri(new Uri.file("my_isolate.dart"), ['0'], rPort2.sendPort)
        .then((_) => rPort2.first, onError: (_) => rPort2.close()),
  ]).then((ps) {
    // Waiting for both streams to complete before summing our results
    print(ps[0]);
    print(ps[1]);
    var p3 = ps[0] + ps[1];
    print("ps[0]=${ps[0]} + ps[1]=${ps[1]} = p3=$p3");
  });
}

// simpler variant, which requires isolate: ^2.0.3 - WORKS
// import "package:isolate/isolate.dart";

main3() async {
  // A SingleResponseChannel has a send-port and a result future,
  // and completes the future with the first port event.
  // Warning: Only closed when event is sent on port!
  // Consider setting a time-out on the channel.
  var c1 = new SingleResponseChannel();
  var c2 = new SingleResponseChannel();
  Isolate.spawnUri(new Uri.file("my_isolate.dart"), ['0'], c1.port);
  Isolate.spawnUri(new Uri.file("my_isolate.dart"), ['0'], c2.port);
  var p3 = await c1.result + await c2.result;
  print("p3 $p3");
}

// back to the interview question....
//
// ANDY new approach using the stackoverflow pure dart approach
// but because we are awaiting both, they happen one after the other
// and we aren't doing anything useful in the main thread (like UI interaction)
// whilst the isolate runs. So, pretty useless.

void main4() async {
  // Isolate version - runs in separate thread
  var c1 = new SingleResponseChannel();
  Isolate.spawn(playHideAndSeekTheLongVersionIsolate, c1.port);
  var result = await c1.result;
  print(result);

  // Async, which still runs the counters in the same
  // thread thus doesn't help with counting to 1 billion.
  String s = await playHideAndSeekTheLongVersion();
  print(s);
}
