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
// globalKey technique via 'another'

final another = GlobalKey<_AnotherState>();

class Another extends StatefulWidget {
  Another() : super(key: another); // sneak in pre-allocated key instead

  @override
  _AnotherState createState() => _AnotherState();
}

class _AnotherState extends State<Another> {
  var _msg = 'quantum';

  set msg(value) {
    setState(() {
      _msg = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          another.currentState.msg =
              'physics'; // official globalkey way works! 🔆🔆
         },
      ),
    );
  }
}
