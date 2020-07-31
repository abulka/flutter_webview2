import 'dart:async';
import 'dart:isolate';
import "package:isolate/isolate.dart";

// Spawns another dart file 'my_isolate.dart' - how cool is that! - WORKS
// https://stackoverflow.com/questions/31013229/how-to-use-results-from-different-isolates-in-the-main-isolate
// RUN dart spawn_two_and_wait.dart/spawn_two_isolates.dart

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

main() async {
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
