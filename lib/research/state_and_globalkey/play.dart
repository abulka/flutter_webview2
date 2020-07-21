import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Flutter'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text('Hello World'),
            ),
            AndyStateless(),
            AndyStateful(),

            // Either of these two constructors work
            Another(),
            // Another.withKey(key: another),

            AnotherButton(),
          ],
        ),
      ),
    );
  }
}

// StatelessWidget

class AndyStateless extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 100,
        color: Colors.amber,
      ),
    );
  }
}

// StatefulWidget

class AndyStateful extends StatefulWidget {
  @override
  _AndyStatefulState createState() => _AndyStatefulState();
}

class _AndyStatefulState extends State<AndyStateful> {
  var _msg = 'hi';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          height: 50,
          color: Colors.green,
          child: FittedBox(child: Text(_msg)),
        ),
        RaisedButton(
          child: Text('press'),
          color: Colors.blue,
          onPressed: () {
            // _msg = 'there';  // aha this is not enough to change state

            setState(() {
              _msg = 'there'; // must do it inside a call to setState
            });
          },
        )
      ],
    );
  }
}

// THIS IS HAIRY
// Another StatefulWidget which exposes itself to modification using key
// globalKey technique via 'another' - finally got it to work
// Also my old 'another2' hack works too

final another = GlobalKey<_AnotherState>();
var another2;

class Another extends StatefulWidget {
  Another() : super(key: another); // setting up to use pre-allocated key

  // Or could use this constructor and pass in the key from above - fiddly
  Another.withKey({Key key})
      : super(key: key); // setting up to use pre-allocated key

  @override
  _AnotherState createState() {
    another2 = _AnotherState(); // ANDY super hack, not using global key
    return another2;
  }
}

class _AnotherState extends State<Another> {
  var _msg = 'quantum';
  final another3 =
      GlobalKey<_AnotherState>(); // perhaps if key is inside class - NO DIFF

  set msg(value) {
    setState(() {
      _msg = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build $another $another2 $another3');
    return Padding(
      // Actually don't use the global key here, pass it in from above
      // otherwise .currentState of these keys is always null 😥
      // Its probably because the 'Another' StatefulWidget itself needs to
      // get the key and do it's super(key: key) call.
      // key: another,
      // key: another3,
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.cyan,
              child: Text(_msg),
            ),
            RaisedButton(
              child: Text('am inside widget'),
              onPressed: () {
                print(
                    '$another ${another.currentState} $another2  $another3 ${another3.currentState}');
                // another3.currentState.msg = 'physics inside';  // official globalkey way does not, currentState is null
                another.currentState.msg =
                    'physics inside'; // official globalkey way OK
              },
            )
          ],
        ),
      ),
    );
  }
}

// External Widget which accesses 'another' via key - naughty but nice

class AnotherButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(
        child: Text('am outside widget'),
        onPressed: () {
          print('$another ${another.currentState} $another2');
          another.currentState.msg =
              'physics'; // official globalkey way works! 🔆🔆
          // another2.msg = 'physics'; // my super hack works too
        },
      ),
    );
  }
}
