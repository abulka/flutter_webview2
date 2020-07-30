import 'package:flutter/material.dart';
import 'streams_research.dart';

// Display Numbers stream in UI - update as we watch

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: Text('Display Numbers stream in UI')),
          body: NumbersDisplay()),
    );
  }
}

class NumbersDisplay extends StatefulWidget {
  NumbersDisplay({Key key}) : super(key: key);

  @override
  _NumbersDisplayState createState() => _NumbersDisplayState();
}

class _NumbersDisplayState extends State<NumbersDisplay> {
  List<int> numbersReceived = [1, 2, 3, 444, 555, 666];
  @override
  initState() {
    _listenToData();
    super.initState();
  }

  _listenToData() {
    timedCounter(Duration(seconds: 1), 7).listen((number) {
      setState(() {
        numbersReceived.add(number);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // child: Text('hi there'),
      child: _buildAll(),
    );
  }

  _buildAll() {
    return ListView.builder(
        itemCount: numbersReceived.length,
        itemBuilder: (context, index) {
          return Text('got ${numbersReceived[index]}');
        });
  }
}
