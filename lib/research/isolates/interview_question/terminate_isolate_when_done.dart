import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'playHideAndSeekIsolate.dart';
import 'playHideAndSeekAsync.dart';

/* 
  Futures (run in same thread) vs Isolates (run in separate thread)
  Run: dart terminate_isolate_when_done.dart

  The async approach, which still runs the counters in the same
  thread thus doesn't help with counting to 1 billion.
*/

Isolate isolate; // holds ref to isolate

// ANDY ATTEMPT AT ISOLATE VERSION - abandoned since I can't
// figure out how to gracefully exit once the isolate is done.

// String returnValueFromIsolate;

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
  String s = await playHideAndSeekTheLongVersionAsync();
  print(s);

  await t;
  print(
      'if both messages print at < their individual cumulative times the same time it means they ran in parallel ok');
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

