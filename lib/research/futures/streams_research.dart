import 'dart:async';

void main() async {
  // Have to use "main() async" cos using await

  // ** Integers (timed)

  // Accessing the stream and listening for data event
  // There is no await, so this runs in the background...
  timedCounter(Duration(seconds: 1), 7).listen((data) {
    print('Got integer $data');
  });

  // This runs in parallel whilst the above loop happens!
  // And finishes first!
  int count = await sumStream(timedCounter(Duration(seconds: 1), 4));
  print('Sum of count= $count');

  // ** Number Creator

  final myStream = NumberCreator().stream.asBroadcastStream();

  myStream.listen(
    (data) => print('NumberCreator Data: $data'),
  );

  myStream.listen(
    (data) => print('NumberCreator Data again: $data'),
    onError: (err) {
      print('Error!');
    },
    cancelOnError: false,
    onDone: () {
      print('NumberCreator Done! (2nd subscription, anyway)');
    },
  );

  // ** Fish
  // salmon, trout, trout, salmon, ...

  FishHatchery().stream.listen((data) {
    print('Got fish $data');
  });

  // Transform the stream so it returns the string sushi
  // only for the first five instances of salmon. Interview question.
  final fishStream = FishHatchery().stream;
  fishStream
      .where((fish) => fish == 'salmon')
      .map((f) => 'FOUND A SALMON $f')
      .listen(print);

  // ANDY ANSWER - works
  // Run: dart lib/research/futures/streams_research.dart | grep "STREAM 2"
  // FISH STREAM 2 sushi
  // FISH STREAM 2 trout
  // FISH STREAM 2 barramundi
  // FISH STREAM 2 sushi
  // FISH STREAM 2 sushi
  // FISH STREAM 2 sushi
  // FISH STREAM 2 sushi
  // FISH STREAM 2 trout
  // FISH STREAM 2 trout
  // FISH STREAM 2 salmon  <- any salmons past the 5th revert to salmon not sushi
  //                          (this was my interpretation of the question)
  int numSalmonFound = 0; // cannot put inside tranform function cos loses count
  var fishStream2 = FishHatchery().stream.transform(
      new StreamTransformer.fromHandlers(
          handleData: (String value, EventSink<String> sink) {
    if (value.contains('salmon') && numSalmonFound < 5) {
      sink.add('sushi');
      numSalmonFound++;
    } else {
      sink.add(value);
    }
  }));
  fishStream2.map((f) => 'FISH STREAM 2 $f').listen(print);

  // OFFICIAL ANSWER - not as good cos only prints sushi five times
  // Run: dart lib/research/futures/streams_research.dart | grep "STREAM 3"
  // FISH STREAM 3 sushi
  // FISH STREAM 3 sushi
  // FISH STREAM 3 sushi
  // FISH STREAM 3 sushi
  // FISH STREAM 3 sushi
  final fishStream3 = FishHatchery().stream;
  final sushiStream = fishStream3
      .where((fish) => fish == 'salmon')
      .map((fish) => 'sushi')
      .take(5);
  sushiStream.map((f) => 'FISH STREAM 3 $f').listen(print);
}

// Integers

Stream<int> timedCounter(Duration interval, [int maxCount]) async* {
  int i = 0;
  while (true) {
    await Future.delayed(interval);
    yield i++;
    if (i == maxCount) break;
  }
}

Future<int> sumStream(Stream<int> stream) async {
  var sum = 0;
  await for (var value in stream) {
    sum += value;
  }
  return sum;
}

// Number Creator

// class NumberCreatorAndy {
//   // ANDY GUESS re creating a class with a stream getter, works OK
//   final maxCount = 3;
//   Stream<int> get stream async* {
//     for (var i = 0; i < maxCount; i++) yield i;
//   }
// }

class NumberCreator {
  final maxCount = 3;
  // ignore: close_sinks
  final _controller = StreamController<int>();
  NumberCreator() {
    for (var i = 0; i < maxCount; i++) _controller.sink.add(i);
    // _controller.sink.close();
  }

  Stream<int> get stream => _controller.stream;
}

// class NumberCreatorProper {
//   NumberCreator() {
//     Timer.periodic(Duration(seconds: 1), (t) {
//       _controller.sink.add(_count);
//       _count++;
//     });
//   }

//   var _count = 1;
//   final _controller = StreamController<int>();
//   Stream<int> get stream => _controller.stream;
// }

// Fish

class FishHatchery {
  // ANDY GUESS re class
  final vals = [
    'salmon',
    'trout',
    'barramundi',
    'salmon',
    'salmon',
    'salmon',
    'salmon',
    'trout',
    'trout',
    'salmon'
  ];
  Stream<String> get stream async* {
    for (var val in vals) yield val;
  }
}
