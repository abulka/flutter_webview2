import 'dart:isolate';

/// Isolate version is not async, returns void, and takes SendPort sendPort as
/// parameter. Don't return, send a message instead.
void playHideAndSeekTheLongVersionIsolate(SendPort sendPort) {
  const billion = 10000000000;
  var counting = 0;
  for (var i = 1; i <= billion; i++) {
    counting = i;
  }
  sendPort
      .send('  ISOLATE VERSION $counting! Ready or not, here I come!');
}
