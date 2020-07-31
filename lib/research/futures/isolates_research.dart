import 'dart:io';
import 'dart:async';
import 'dart:isolate';

// Run an isolate - which is a a separate process/thread, which we communicate 
// with via messages.
// RUN: dart lib/research/futures/isolates_research.dart
// https://codingwithjoe.com/dart-fundamentals-isolates/

Isolate isolate; // holds ref to isolate

void start() async {
  ReceivePort receivePort =
      ReceivePort(); //port for this main isolate to receive messages.
  isolate = await Isolate.spawn(runTimer, receivePort.sendPort); // create it!

  // interesting that the same .listen() pattern is used here
  receivePort.listen((data) {
    print('  main process RECEIVES: ' + data + ', ');
  });
}

/// This is the code that runs in the isolate / process 
void runTimer(SendPort sendPort) {
  int counter = 0;
  Timer.periodic(new Duration(seconds: 1), (Timer t) {
    counter++;
    String msg = 'notification ' + counter.toString();
    print('Inside isolate, SENDING: ' + msg + ' - ');
    sendPort.send(msg);
  });
}

void stop() {
  if (isolate != null) {
    print('killing isolate');
    isolate.kill(priority: Isolate.immediate);
    isolate = null;
  }
}

void main() async {
  print('spawning isolate...');
  await start();
  print('press enter key to quit...');
  await stdin.first;
  stop();
  print('goodbye!');
  exit(0);
}
