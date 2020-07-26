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
        appBar: AppBar(title: Text('Two scroll areas')),
        body: BodyLayout(),
      ),
    );
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          color: Colors.amber[500],
          child: const Center(child: Text('A simple container!')),
        ),
        AnimatedContainerPlay(),
        Expanded(child: _myListView(context)),
        inputArea(),
        //Expanded(child: _myListView(context)),
        exampleButtonsArea(),
      ],
    );
  }

  Expanded exampleButtonsArea() {
    return Expanded(
      child: SingleChildScrollView(
        child: Wrap(
          children: [
            RaisedButton(
              onPressed: () {},
              child: Text('example to inch'),
            ),
            RaisedButton(
              onPressed: () {},
              child: Text('example sin'),
            ),
            RaisedButton(
              onPressed: () {},
              child: Text('example math.pow'),
            ),
            RaisedButton(
              onPressed: () {},
              child: Text('complex({ r: sqrt(2), phi: pi / 4 })'),
            ),
            Container(color: Colors.redAccent, height: 30, width: 130,),
            Container(color: Colors.red[200], height: 30, width: 130,),
            Container(color: Colors.red[300], height: 30, width: 130,),
            Container(color: Colors.red[400], height: 30, width: 130,),
            Container(color: Colors.red[600], height: 30, width: 130,),
          ],
        ),
      ),
    );
  }

  Container inputArea() {
    return Container(
      color: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              contentPadding:
                  const EdgeInsets.only(left: 4.0, bottom: 2.0, top: 2.0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(1))),
              hintText: 'Enter a math term'),
          onChanged: (text) {
            print("text field so far...: $text");
          },
          onSubmitted: (value) {},
        ),
      ),
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
    itemCount: 1000,
    itemBuilder: (context, index) {
      return Card(
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          leading: Icon(randomChoice(icons)),
          title: Text('row $index'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            print('Tapped on $index');
            var future = _ackAlert(context, msg: 'Item $index');
            print('Andy is ignoring dialog future var $future');
          },
        ),
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

// https://flutter.dev/docs/cookbook/animation/animated-container

class AnimatedContainerPlay extends StatefulWidget {
  @override
  _AnimatedContainerPlayState createState() => _AnimatedContainerPlayState();
}

class _AnimatedContainerPlayState extends State<AnimatedContainerPlay> {
  // Define the various properties with default values. Update these properties
  // when the user taps a FloatingActionButton.
  double _width = 50;
  double _height = 50;
  Color _color = Colors.green;
  BorderRadiusGeometry _borderRadius = BorderRadius.circular(8);
  final oneSec = const Duration(seconds: 3);
  final fiveSecs = const Duration(seconds: 5);

  _AnimatedContainerPlayState() : super() {
    print('constructor called ok');
    new Timer.periodic(fiveSecs, (Timer t) => print('hi!'));
    new Timer.periodic(oneSec, (Timer t) => onPressedFunc());
  }

  onPressedFunc() {
    // Use setState to rebuild the widget with new values.
    setState(() {
      // Create a random number generator.
      final random = Random();

      // Generate a random width and height.
      _width = random.nextInt(300).toDouble();
      _height = random.nextInt(300).toDouble();

      // Generate a random color.
      _color = Color.fromRGBO(
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
        1,
      );

      // Generate a random border radius.
      _borderRadius = BorderRadius.circular(random.nextInt(100).toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      // Use the properties stored in the State class.
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: _borderRadius,
      ),
      // Define how long the animation should take.
      duration: Duration(seconds: 1),
      // Provide an optional curve to make the animation feel smoother.
      curve: Curves.fastOutSlowIn,
    );
  }
}
