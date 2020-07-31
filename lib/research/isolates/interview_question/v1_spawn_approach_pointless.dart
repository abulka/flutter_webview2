import 'dart:isolate';
import "package:isolate/isolate.dart";
import 'playHideAndSeekIsolate.dart';
import 'playHideAndSeekAsync.dart';

// Andy's new approach using the stackoverflow pure dart approach
// (based on spawn_two/ research)
// Third party isolate/isolate.dart needed for SingleResponseChannel
// 
// But because we are awaiting both, they happen one after the other
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
  String s = await playHideAndSeekTheLongVersionAsync();
  print(s);
}
