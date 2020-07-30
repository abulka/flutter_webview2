import 'package:flutter/material.dart';
import 'streams_research.dart';

/* 
  Display Numbers stream in UI
  
  Two versions 
    - update listview as we watch
    - wait till list fills then display (future builder used)

  To get them to use the same number stream would be the next step.
*/

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: Text('Display Numbers stream in UI')),
          body: Page()),
    );
  }
}

class Page extends StatelessWidget {
  const Page({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: NumbersDisplay()),
        Expanded(child: NumbersDisplay2()),
      ],
    );
  }
}

// Common stream both implementations listen to

// final myStream = NumberCreator().stream.asBroadcastStream();
final myStream = timedCounter(Duration(seconds: 1), 7).asBroadcastStream();

// Implementation 1 - listview displays as we go...

class NumbersDisplay extends StatefulWidget {
  NumbersDisplay({Key key}) : super(key: key);

  @override
  _NumbersDisplayState createState() => _NumbersDisplayState();
}

class _NumbersDisplayState extends State<NumbersDisplay> {
  List<int> numbersReceived = [];
  @override
  initState() {
    _listenToData();
    super.initState();
  }

  _listenToData() {
    // timedCounter(Duration(seconds: 1), 7).listen((number) {
    myStream.listen((number) {
      setState(() {
        numbersReceived.add(number);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber[100],
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

// Implementation 2 - Displays once we get all the values using a future builder...

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
    numbersReceived =
        gatherNumbersIntoList(myStream);
  }

  // Future<List<int>> gatherNumbers() async {
  //   await Future.delayed(Duration(seconds: 2)); // wait 2 sec
  //   return [42, 43, 55];
  // }

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
      color: Colors.amber[50],
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
