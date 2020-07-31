import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/services.dart' show rootBundle;

// Uses the extra webview functionality of 'flutter_webview_plugin'
// wow, how simple is this!
// https://stackoverflow.com/questions/58985946/flutter-how-to-retrieve-javascript-value-from-flutterwebviewplugin-evaljavascrip

final Set<JavascriptChannel> jsChannels = [
  JavascriptChannel(
      name: 'Print',
      onMessageReceived: (JavascriptMessage message) {
        print('print javascript channel, message.message: ${message.message}');
      }),
].toSet();

void main() => runApp(MyApp());

// main() async {
//   String htmlPage = await rootBundle.loadString('assets/index.html');
//   String jsCode = await rootBundle.loadString('assets/javascript.js');

//   runApp(MyApp(htmlPage, jsCode));
// }

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/index.html');
}

class MyApp extends StatelessWidget {
  // String jsCode;
  // String htmlPage;
  // MyApp(this.htmlPage, this.jsCode, {Key key}) : super(key: key);

  // MyApp({Key key}) : super(key: key) {
  //   var s = await loadAsset();
  //   print(s);
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (_) => WebviewScaffold(
              url: Uri.dataFromString(
                      '<html><button onclick="Print.postMessage(\'test\');">Click me</button></html>',
                      mimeType: 'text/html')
                  .toString(),

              // url: htmlPage,

              // url: Uri.file("assets/index.html").toString(),

              // url: "assets/index.html",

              // FAILS cos File not defined - ios thing?
              // url: Uri.dataFromString(
              //     File('filePath').readAsStringSync(),
              //     mimeType: 'text/html',
              // ).toString(),

              // FAILS cos we are not async
              // url: Uri.dataFromString(
              //   await rootBundle.loadString('assets/index.html'),
              //   mimeType: 'text/html',
              // ).toString(),

              withLocalUrl: true,
              appBar: new AppBar(title: new Text("Widget webview")),
              javascriptChannels: jsChannels,
            ),
      },
    );
  }
}
