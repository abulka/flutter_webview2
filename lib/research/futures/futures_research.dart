
/* 
  Pure futures, building your own async functions that return futures
  Run: dart lib/research/futures/futures_research.dart

  Lessons learned:

  An async method has to be declared to return a Future but actually returns
  the thing you are returning e.g. String which makes the caller simply do
    String s = await f()

  You can call a future without awaiting - it runs ok
  but the return value will be lost
  
  You can declare a variable and await a variable instead e.g.
    Future<String> futureString = f()
    String s = await futureString;

  Its like the 'await' converts from the Future type to actual thing type.

  You don't have to yield in a future e.g. yield i++; that's for streams
  where you are returning multiple values, like a generator.  In those cases
  we do weird things like declare 'async*' instead of just 'async'?
*/

void main() async {
  Future<String> futureString = fetchUserOrder();
  String s = await futureString;
  print(s);

  // or just
  s = await fetchUserOrder();
  print(s);

  // how simple is this
  s = await simple();
  print(s);

  // you can call a future without awaiting - it runs ok
  // but the return value will be lost
  playHideAndSeek2();
  playHideAndSeek3();

  // let's call my own home grown delay future...
  s = await playHideAndSeekTheLongVersion();
  print(s);

}

Future<String> fetchUserOrder() =>
    // why no async on this function?
    Future.delayed(
      Duration(seconds: 1),
      () => 'Large Latte',
    );

/// Make my own future function.
/// Looks like I can return a regular String from a function
/// declared to return a Future<String>

Future<String> simple() async {
  return 'simple blah';
}

/// You don't have to yield in a future - that's for streams
/// where you are returning multiple values, like a generator.
Future<String> playHideAndSeekTheLongVersion() async {
  var counting = 0;
  for (var i = 1; i <= 1000000; i++) {
    counting = i;
  }
  return '$counting! Ready or not, here I come!';
}

Future<String> playHideAndSeek2() async {
  var counting = 0;
  for (var i = 1; i <= 20000000; i++) {
    counting = i;
  }
  print('playHideAndSeek2 $counting! Ready or not, here I come!');
  return '$counting! Ready or not, here I come!';
}

Future<void> playHideAndSeek3() async {
  var counting = 0;
  for (var i = 1; i <= 30000000; i++) {
    counting = i;
  }
  print('playHideAndSeek3 $counting! Ready or not, here I come!');
}

