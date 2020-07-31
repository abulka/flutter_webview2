import "dart:async";
import "dart:isolate";

// https://github.com/dart-lang/sdk/issues/28731
// How to wait till all data is sent from an isolate via a special message

void entryPoint(List args) {
  SendPort sendPort = args[0];
  Capability endOfData = args[1];
  for (int i in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]) {
    sendPort.send(i);
  }
  sendPort.send(endOfData);
}

main() async {
  Capability endOfData = Capability(); // I think this is like a uuid or similar
  ReceivePort receivePort = ReceivePort();
  Isolate isolate =
      await Isolate.spawn(entryPoint, [receivePort.sendPort, endOfData]);
  receivePort.listen((data) {
    if (data == endOfData) {
      print('got endOfData message $data ${data.runtimeType}');
      receivePort.close();
    } else {
      print("received: $data ${data.runtimeType}");
    }
  }, onDone: () {
    print("done");
  });
}
