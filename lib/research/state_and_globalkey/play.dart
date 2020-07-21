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
            Another(),
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
// globalKey technique via 'another' doesn't work but my old 'another2' hack does

final another = GlobalKey<_AnotherState>();
var another2;

class Another extends StatefulWidget {
  Another({Key key}) : super(key: key);
  @override
  _AnotherState createState() {
    another2 = _AnotherState();
    return another2;
  }
}

class _AnotherState extends State<Another> {
  var _msg = 'quantum';
  final another3 = GlobalKey<_AnotherState>(); // perhaps if key is inside class

  set msg(value) {
    setState(() {
      _msg = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build $another $another2 $another3');
    return Padding(
      // key: another,
      key: another3,
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
                print('$another ${another.currentState} $another2  $another3 ${another3.currentState}');
                // another3.currentState.msg = 'physics inside';  // official globalkey way does not, currentState is null
              },
            )
          ],
        ),
      ),
    );
  }
}

// External Widget which accesses 'another' via key - naughty but nice - doesn't work

class AnotherButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(
        child: Text('am outside widget'),
        onPressed: () {
          print('$another ${another.currentState} $another2');
          another2.msg = 'physics'; // my super hack works
          // another.currentState.msg = 'physics';  // official globalkey way does not, currentState is null
        },
      ),
    );
  }
}
