import 'package:flutter/material.dart';

// Shows the use of basic App using a stateless widget, stateful widget.
// Proves you need to call setState() to affect change in the statefule widget.

// Also shows 'Another' stateful widget and accessing it from a sibling stateless
// widget via a globalkey technique (and also via my original hacky state var technique)
// which took a while to get working.

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

// Another StatefulWidget which exposes itself to modification using key
// globalKey technique via 'another' - finally got it to work
// Also my old 'another2' hack works too

// When we have a custom widget, we must declare the stateful widget
// with the Another({Key key}) : super(key: key) constructor
// and just as with Scaffold, pass in the globalkey in the constructor
//    Another(key: globalKey)
// where globalKey is of type _AnotherState viz
//    final another = GlobalKey<_AnotherState>();
// MY mistake at some stage was to use the key in the constructor of
// Padding *inside* the _AnotherState build() method - WTF 😆

// You can declare the globalkey variable anywhere - inside a class or even
// in the global namespace - just depends on who needs to access it.

final another = GlobalKey<_AnotherState>();
var another2;

class Another extends StatefulWidget {
  Another() : super(key: another); // setting up to use pre-allocated key COOL SHORTCUT 

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
      // Ummm - plus its not even the right type!  'another' is _AnotherState
      // which is nothing to do with padding!
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
