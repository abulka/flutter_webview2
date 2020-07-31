import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Older initial webview project from macbook air.  
// Its now part of this project - here I create the webview on top of the
// basic stasrter template. Was trying to get javascript running without
// success - abandoned in favour of other .dart research approaches, though
// it could no doubt be resurrected.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'ANDY Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

final Set<JavascriptChannel> jsChannels = [
  JavascriptChannel(
      name: 'Print',
      onMessageReceived: (JavascriptMessage message) {
        print('message.message: ${message.message}');
      }),
].toSet();

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;

      print('counter is now $_counter');
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body:
          // Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          // child: Column(
          Column(
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Invoke "debug painting" (press "p" in the console, choose the
        // "Toggle Debug Paint" action from the Flutter Inspector in Android
        // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
        // to see the wireframe for each widget.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 30.0),
          ),

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Sunday!!!',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),

          _centered_text('Hey Andy'),

          Text(
            'Andy B has pushed the button this many times:',
          ),
          Text(
            '$_counter',
            style: Theme.of(context).textTheme.headline4,
          ),

          Padding(
            padding: EdgeInsets.only(top: 30.0),
          ),

          Icon(Icons.star, size: 50),

          RaisedButton(
            onPressed: () {
              // flutterWebviewPlugin.evalJavascript('alert("Hello World")')
              print('pressed!');
            },
            child: const Text('run some js', style: TextStyle(fontSize: 20)),
          ),

          Padding(
            padding: EdgeInsets.only(top: 30.0),
          ),

          // new Container(
          //   child: new Image.network(
          //     'https://placeimg.com/640/480/any',
          //     fit: BoxFit.fill,
          //   ),
          //   color: const Color(0xFF378c53),
          //   padding: const EdgeInsets.all(0.0),
          //   alignment: Alignment.center,
          // ),

          Expanded(
            child: WebView(
              initialUrl: 'https://www.javatpoint.com/android-versions',

              javascriptMode: JavascriptMode.unrestricted,
              
              // javascriptChannels: <JavascriptChannel>[
              //   JavascriptChannel(name: 'Print', onMessageReceived: (String msg) { print(msg); }),
              // ].toSet(),

              javascriptChannels: jsChannels,

              onPageStarted: (String url) {
                print('Page started loading: $url');
              },
              onPageFinished: (String url) {
                print('Page finished loading: $url');
              },
            ),
          ),

          // Container(
          //   // width: 400, // Container child widget will get this width value
          //   height: 600, // Container child widget will get this height value
          //   child: WebView(
          //     initialUrl: 'https://flutter.dev',
          //     onPageStarted: (String url) {
          //       print('Page started loading: $url');
          //     },
          //     onPageFinished: (String url) {
          //       print('Page finished loading: $url');
          //     },
          //   ),
          // ),

          Container(
            color: Colors.lightGreen,
            height: 50,
            // width: 100,
          ),
          // Expanded(
          //   child: Container(
          //     color: Colors.amber,
          //     width: 100,
          //   ),
          // ),
        ],
        // ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// Andy extras - not part of project

Widget _centered_text(String s) {
  return Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          s,
          style: TextStyle(fontSize: 20),
        ),
      ],
    ),
  );
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text('Hello, Andy', style: Theme.of(context).textTheme.headline4),
        Text(
          'Hello, Andy2',
          style: Theme.of(context).textTheme.headline4,
        ),
        Text('Hello, Andy3', style: Theme.of(context).textTheme.headline4),
      ],
    );
  }
}
