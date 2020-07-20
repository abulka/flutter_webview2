import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/services.dart' show rootBundle;

// Uses the extra webview functionality of 'flutter_webview_plugin'
// with additional asset loading

final Set<JavascriptChannel> jsChannels = [
  JavascriptChannel(
      name: 'Print',
      onMessageReceived: (JavascriptMessage message) {
        print('print javascript channel, message.message: ${message.message}');
      }),
].toSet();

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<String> _foo;

  @override
  void initState() {
    super.initState();

    _foo = loadAsset();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(routes: {
      "/": (_) => FutureBuilder<String>(
          future: _foo,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              // return Text('The answer to everything is ${snapshot.data}');
              return WebviewScaffold(
                url: Uri.dataFromString(
                        snapshot.data,
                        mimeType: 'text/html')
                    .toString(),
                withLocalUrl: true,
                appBar: new AppBar(title: new Text("Widget webview")),
                javascriptChannels: jsChannels,
              );
            } else {
              return Text('Loading...');
            }
          })
    });
  }
}

Future<String> loadAsset() async {
  // await Future.delayed(Duration(seconds: 2)); // wait
  return await rootBundle.loadString('assets/index.html');
}
