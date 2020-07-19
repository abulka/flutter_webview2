import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'App futures demo', // this does not appear? FooWidget.appBar does
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FooWidget(),
    );
  }
}

// https://stackoverflow.com/questions/53800662/how-do-i-call-async-property-in-widget-build-method

class FooWidget extends StatefulWidget {
  @override
  _FooWidgetState createState() => _FooWidgetState();
}

class _FooWidgetState extends State<FooWidget> {
  Future<String> _foo;
  Future<int> _bar;

  @override
  void initState() {
    super.initState();

    _bar = doSomeLongRunningCalculation();
    _foo = loadAsset();
  }

  void _retry() {
    setState(() {
      _bar = doSomeLongRunningCalculation();
      _foo = loadAsset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget waiting on futures demo'),
      ),
      body: Builder(builder: (BuildContext context) {
        return Column(
          children: <Widget>[
            FutureBuilder<int>(
              future: _bar,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.hasData) {
                  return Text('The answer to everything is ${snapshot.data}');
                } else {
                  return Text('Calculating answer...');
                }
              },
            ),
            RaisedButton(
              onPressed: _retry,
              child: Text('Retry'),
            ),
            FutureBuilder<String>(
              future: _foo,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Text('Asset: ${snapshot.data}');
                } else {
                  return Text('Loading asset...');
                }
              },
            ),
          ],
        );
      }),
    );
  }
}

Future<int> doSomeLongRunningCalculation() async {
  await Future.delayed(Duration(seconds: 2)); // wait 5 sec
  return 42;
}

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/index.html');
}
