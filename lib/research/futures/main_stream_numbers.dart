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
          body: NumbersDisplay2()),
    );
  }
}

// Displays as we go...

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

// Displays once we get all the values using a future builder...

class NumbersDisplay2 extends StatefulWidget {
  NumbersDisplay2({Key key}) : super(key: key);

  @override
  _NumbersDisplay2State createState() => _NumbersDisplay2State();
}

class _NumbersDisplay2State extends State<NumbersDisplay2> {
  Future<List<int>> numbersReceived;

  @override
  void initState() {
    super.initState();
    // numbersReceived = gatherNumbers();
    numbersReceived = gatherNumbersIntoList(timedCounter(Duration(seconds: 1), 4));
  }

  Future<List<int>> gatherNumbers() async {
    await Future.delayed(Duration(seconds: 2)); // wait 2 sec
    return [42, 43, 55];
  }

  Future<List<int>> gatherNumbersIntoList(Stream<int> stream) async {
    List<int> numbersReceived = [];
    await for (var value in stream) {
      numbersReceived.add(value);
    }
    return numbersReceived;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildAll(),
    );
  }

  _buildAll() {
    return FutureBuilder<List<int>>(
      future: numbersReceived,
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Text('got ${snapshot.data[index]}');
              });
        } else {
          return Text('Waiting for all the numbers to arrive...');
        }
      },
    );
  }
}
