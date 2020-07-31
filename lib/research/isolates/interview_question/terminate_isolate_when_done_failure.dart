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

  ANDY ATTEMPT AT ISOLATE VERSION - abandoned since I couldn't
  figure out how to gracefully kill the process and exit once the isolate is done.

  NOTE: see terminate_isolate_when_done.dart for solution I worked out!
*/

Isolate isolate; // holds ref to isolate

String returnValueFromIsolate;  // this idea doesn't work

void main() async {
  // Isolate version - runs in separate thread
  await start(); // 'await' applied to 'void', which is not a 'Future' ?

  // Async, which still runs the counters in the same
  // thread thus doesn't help with counting to 1 billion.
  String s = await playHideAndSeekTheLongVersionAsync();
  print(s);

  if (returnValueFromIsolate != null) {
    stop();
    exit(0); // why do I need an explicit exit - otherwise app hangs?
  } else
    print('isolate has not finished, we are left hanging');
  
  // await theIsolate;  <--- WE WANT SOMETHING LIKE THIS (aha see non failed project)
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
