import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

// https://stackoverflow.com/questions/49930180/flutter-render-widget-after-async-call/49931743
// See this, but note that using a FutureBuilder is a better way to do this 
// and I'm just providing this for you to learn.

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'async demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List data;

  @override
  initState() {
    super.initState();

    new Future<String>.delayed(new Duration(seconds: 5), () => '["123", "456", "789"]').then((String value) {
      setState(() {
        data = json.decode(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Loading..."),
        ),
      );
    } else {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Center(
          child: new ListView(
            children: data
                .map((data) => new ListTile(
                      title: new Text("one element"),
                      subtitle: new Text(data),
                    ))
                .toList(),
          ),
        ),
      );
    }
  }
}