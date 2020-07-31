import "dart:async";
import "dart:isolate";

import 'dart:math';

// https://stackoverflow.com/questions/31013229/how-to-use-results-from-different-isolates-in-the-main-isolate

main(args, SendPort port) {
  // var partial = 1;
  var partial = Random().nextInt(100);
  // ... do stuff ...
  // args are used and partial is updated
  print('in myisolate.dart with value $partial');
  port.send(partial);
}
