import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:flutter_webview2/models/calculation.dart';
import 'package:provider/provider.dart';

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
    return ChangeNotifierProvider(
      create: (context) => CalculationsModel(),
      builder: (context, child) {
        // return Text('xxx');
        return Column(
          children: [
            Container(
              height: 15,
              color: Colors.amber[500],
              child: const Center(
                  child: Text('status indicators etc',
                      style: TextStyle(
                          fontSize: 10.0, fontWeight: FontWeight.bold))),
            ),
            // Expanded(child: _myListView(context)),
            Expanded(child: _myListView2(context)),
            Container(
              height: 50,
              color: Colors.amber[200],
              child: Row(
                children: <Widget>[
                  RaisedButton(
                    child: Text('Add'),
                    onPressed: () {
                      print('xx');
                      var r = Random();
                      final Calculation c = Calculation(
                        expression: '${r.nextInt(1000)} + ${r.nextInt(1000)}',
                        completed: false,
                      );
                      Provider.of<CalculationsModel>(context, listen: false)
                          .add(c);
                    },
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
      },
    );
  }
}

// MODEL

Widget _myListView2(BuildContext context) {
  return AllCalculations();
}

/// It is generally considered a bad practice to enclose a huge widget tree
/// inside a Consumer widget. This widget should be inserted as deep as possible
/// in the widget tree to prevent unnecessary re-renders. For more info, see
/// here. We need to re-render all the list items in case any of the task item
/// changes. That's why I have enclosed the use of TaskList widget inside the
/// Consumer. Now whenever our provider calls notifyListener in its model. It
/// will re-render our TaskList widget.
class AllCalculations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<CalculationsModel>(
        builder: (context, calculations, child) => CalculationList(
          calculations: calculations.allCalculations,
        ),
      ),
    );
  }
}

class CalculationList extends StatelessWidget {
  final List<Calculation> calculations; // I guess this is the view model list

  CalculationList({@required this.calculations});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: convertModelToWidgets(),
    );
  }

  /// Converts the pure model list of calculations into a list of widgets
  /// .map() returns a lazy iterable of the new thing, so .toList() forces computation
  /// not sure why we can't leave it as iterable - surely the build() method can cope?
  List<Widget> convertModelToWidgets() {
    return calculations
        .map((calculation) => CalculationListItem(calculation: calculation))
        .toList();
  }
}

class CalculationListItem extends StatelessWidget {
  final Calculation calculation;

  CalculationListItem({@required this.calculation});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: calculation.completed,
        onChanged: (bool checked) {
          Provider.of<CalculationsModel>(context, listen: false)
              .toggleComplete(calculation);
        },
      ),
      title: Text(calculation.expression),
      trailing: IconButton(
        icon: Icon(
          Icons.delete,
          color: Colors.red,
        ),
        onPressed: () {
          Provider.of<CalculationsModel>(context, listen: false)
              .delete(calculation);
        },
      ),
    );
  }
}

// ORI

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
