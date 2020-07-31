import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/services.dart' show rootBundle;

// Uses the extra webview functionality of 'flutter_webview_plugin'
// with additional asset loading

// version 2 of the initialisation is a failure - I can't return the same
// webview twice - the header updates but the contents do not refresh?
// Even adding the key constructor trick to the widget doesn't help.

final Set<JavascriptChannel> jsChannels = [
  JavascriptChannel(
      name: 'Print',
      onMessageReceived: (JavascriptMessage message) {
        print('print javascript channel, message.message: ${message.message}');
      }),
].toSet();

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key); // let's try this mysterious key thing

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
            const version = 2;

            // SCRAPS

            // var s = '<html><p>Loading...</p></html>';
            // if (false && snapshot.hasData)
            //   s = Uri.dataFromString(snapshot.data, mimeType: 'text/html')
            //       .toString();

            // var s = Uri.dataFromString(
            //     '<html><button onclick="Print.postMessage(\'test\');">Click me</button></html>',
            //     mimeType: 'text/html').toString();

            // s = Uri.dataFromString(snapshot.data, mimeType: 'text/html')
            //     .toString();

            if (version == 1) {
              // This works, but am creating WebviewScaffold twice
              if (snapshot.hasData)
                return WebviewScaffold(
                  url: Uri.dataFromString(snapshot.data, mimeType: 'text/html')
                      .toString(),
                  withLocalUrl: true,
                  appBar: new AppBar(title: new Text("Widget webview 2")),
                  javascriptChannels: jsChannels,
                );
              else {
                return Text('loading...'); // prefer not to return this
                // but for some reason the webview widget doesn't refresh with the new url
                return WebviewScaffold(
                  url: Uri.dataFromString(
                          '<html><button onclick="Print.postMessage(\'test\');">Click me</button></html>',
                          mimeType: 'text/html')
                      .toString(),
                  withLocalUrl: true,
                  appBar: new AppBar(title: new Text("Widget webview 1")),
                  javascriptChannels: jsChannels,
                );
              }
            } else if (version == 2) {
              var s = snapshot.hasData
                  ? Uri.dataFromString(snapshot.data, mimeType: 'text/html')
                      .toString()
                  : Uri.dataFromString(
                          '<html><button onclick="Print.postMessage(\'test\');">Click me</button></html>',
                          mimeType: 'text/html')
                      .toString();
              print('build being called with ${snapshot.hasData} s=$s');

              var result = WebviewScaffold(
                url: s,
                withLocalUrl: true,
                appBar: new AppBar(title: new Text("Widget webview 1 and 2")),
                javascriptChannels: jsChannels,
              );
              return result;
              // yeah but how to call result.reload() ? need to return
              // the widget first then call the reload later?  hard.
              // let's try keys
            }
          })
    });
  }
}

Future<String> loadAsset() async {
  await Future.delayed(Duration(seconds: 2)); // wait
  return await rootBundle.loadString('assets/index.html');
}
