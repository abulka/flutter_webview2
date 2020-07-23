import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dart_random_choice/dart_random_choice.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ListView Experiments',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // home: MyHomePage(title: 'ListView experiments'),

      home: Scaffold(
        appBar: AppBar(title: Text('ListViews')),
        body: BodyLayout(),
      ),
    );
  }
}

// class BodyLayout extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return _myListView(context);
//   }
// }

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 15,
          color: Colors.amber[500],
          child: const Center(
              child: Text('status indicators etc',
                  style:
                      TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold))),
        ),
        Expanded(child: _myListView(context)),
        Container(
          height: 50,
          color: Colors.amber[200],
          child: Row(
            children: <Widget>[
              RaisedButton(
                child: Text('Add'),
                onPressed: () => print('xx'),
              )
            ],
          ),
        ),
        Container(
          height: 200,
          color: Colors.amber,
        ),
      ],
    );
  }
}

// replace this function with the code in the examples
Widget _myListView(BuildContext context) {
  final icons = [
    Icons.directions_bike,
    Icons.directions_boat,
    Icons.directions_bus,
    Icons.directions_car,
    Icons.directions_railway,
    Icons.directions_run,
    Icons.directions_subway,
    Icons.directions_transit,
    Icons.directions_walk
  ];

  return ListView.separated(
    itemCount: 10,
    itemBuilder: (context, index) {
      return ListTile(
        leading: Icon(randomChoice(icons)),
        title: Text('row $index'),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          print('Tapped on $index');
          var future = _ackAlert(context, msg: 'Item $index');
          print('Andy is ignoring dialog future var $future');
        },
      );
    },
    separatorBuilder: (context, index) {
      return Divider();
    },
  );
}

Future<void> _ackAlert(BuildContext context, {String msg}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Not in stock'),
        content: Text('$msg is no longer available'),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Ok2'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Container(
            height: 50,
            color: Colors.amber[500],
            child: const Center(child: Text('my text')),
          ),
          Icon(Icons.adjust),
        ],
      );
    },
  );
}
