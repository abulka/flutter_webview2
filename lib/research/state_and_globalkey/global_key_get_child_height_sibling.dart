import 'package:flutter/material.dart';

// https://stackoverflow.com/questions/50115416/get-height-of-a-widget-using-its-globalkey-in-flutter
// using global key inside normal widgets actually does work
// this example the parent widget creates a child widget (passing in a pre-allocated key)
// then is able to access the child widget state later
// 
// this sibling version shows a sibling widget accessing the sibling state OK
// finally! so there is hope for this technique after all.

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
        body: TestPage(),
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TestPageState();
}

final key =
    GlobalKey<TestWidgetState>(); // try declaring in global namespace, ok

class TestPageState extends State<TestPage> {
  @override
  initState() {
    //calling the getHeight Function after the Layout is Rendered
    WidgetsBinding.instance.addPostFrameCallback((_) => getHeight());

    super.initState();
  }

  void getHeight() {
    //returns null:
    final State state = key.currentState;
    //returns null:
    final BuildContext context = key.currentContext;

    //Error: The getter 'context' was called on null.
    final RenderBox box = state.context.findRenderObject();

    print('child TestWidget box.size.height=${box.size.height}');
    print('child TestWidget context.size.height=${context.size.height}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          TestWidget(key: key),
          AnotherButton(),
        ],
      ), // pass pre-allocated key to the widget constructor
    );
  }
}

class TestWidget extends StatefulWidget {
  TestWidget({Key key}) : super(key: key); // uses pre-allocated key

  @override
  State<StatefulWidget> createState() => new TestWidgetState();
}

class TestWidgetState extends State<TestWidget> {
  var _msg = 'quantum';
  set msg(value) {
    setState(() {
      _msg = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Text(
        "Test $_msg",
        style: const TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// External Widget which accesses 'another' via key - naughty but nice - works🚀

class AnotherButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(
        child: Text('am outside widget'),
        onPressed: () {
          print('$key ${key.currentState}');
          key.currentState.msg = 'physics'; // official globalkey way - works!!
        },
      ),
    );
  }
}
