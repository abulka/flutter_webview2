import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:dedent/dedent.dart';

import 'playHideAndSeekIsolate.dart';
import 'playHideAndSeekAsync.dart';

/* 
  Futures (run in same thread) vs Isolates (run in separate thread)
  Run: dart terminate_isolate_when_done.dart

  The async approach, which still runs the counters in the same
  thread thus doesn't help with counting to 1 billion.

  Here I spawn the isolate first then continue with awaiting on the async
  version. By the time the async version has finished, so has the isolate/thread
  version! Both thus running in parallel.

  The other big learning here is how to know when the isolate is finished
  and kill it. By using a future based thing called Completer() I can 
  control when this future completes myself - very cool!
*/

Isolate isolate; // holds ref to isolate

void main() async {
  Future t = MyOperation().start();
  print('1. isolate thread should now be computing...');
  // await t; // uncomment if want the culumative times

  // Async, which still runs the counters in the same
  // thread thus doesn't help with counting to 1 billion.
  print('2. async function in main thread computing...');
  String s = await playHideAndSeekTheLongVersionAsync();

  print('');
  print(s);

  await t;
  print(dedent('''
  
      If both messages print at about the same time and < their individual
      cumulative times THEN it means they ran in parallel ok :-)
      '''));
  stop();
  exit(0);
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
  Completer _completer = Completer();

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

