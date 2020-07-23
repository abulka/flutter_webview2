import 'dart:math';
import 'package:flutter/material.dart';
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
      home: Scaffold(
        appBar: AppBar(title: Text('ListViews')),
        body: BodyLayout(),
      ),
    );
  }
}

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
                      var r = Random();
                      var expression =
                          '${r.nextInt(1000)} + ${r.nextInt(1000)}';
                      if (r.nextInt(100) < 50)
                        expression += ' / ${r.nextInt(1000)}';
                      final Calculation c = Calculation(
                        expression: expression,
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
        builder: (context, calculationModel, child) =>
            CalculationList(calculationModel: calculationModel),
      ),
    );
  }
}

/// Generate widgets from model
class CalculationList extends StatelessWidget {
  final CalculationsModel calculationModel;
  final _scrollController = ScrollController();

  CalculationList({@required this.calculationModel});

  _scrollToBottom() {
    // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    if (calculationModel.justAdded)
      // Timer(Duration(milliseconds: 100), () => _scrollToBottom());
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return ListView(
      controller: _scrollController,
      children: convertModelToWidgets(),
    );
  }

  /// Converts the pure model list of calculations into a list of widgets
  /// .map() returns a lazy iterable of the new thing, so .toList() forces computation
  /// not sure why we can't leave it as iterable - surely the build() method can cope?
  ///
  /// Also, had to convert .map into .map<Widget> because type inference fails
  /// in an unexpected way - see https://stackoverflow.com/questions/49603021/type-listdynamic-is-not-a-subtype-of-type-listwidget
  List<Widget> convertModelToWidgets() {
    return calculationModel.allCalculations
        .map<Widget>(
            (calculation) => CalculationListItem(calculation: calculation))
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
