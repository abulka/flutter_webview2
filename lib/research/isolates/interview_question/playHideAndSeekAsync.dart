// ASYNC version - takes 29s to count to a billion - slower than isolate!
// isolate version only takes 8s

Future<String> playHideAndSeekTheLongVersionAsync() async {
  // const billion = 10000000000; // why 28 secs ?
  const easier =     3000000000;
  var counting = 0;
  // for (var i = 1; i <= billion; i++) {
  for (var i = 1; i <= easier; i++) {
    counting = i;
  }
  return '  PLAIN ASYNC VERSION $counting! Ready or not, here I come!';
}
