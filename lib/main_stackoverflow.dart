import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (_) => WebviewScaffold(
              url: Uri.dataFromString(
                      '<html><button onclick="Print.postMessage(\'test\');">Click me</button></html>',
                      mimeType: 'text/html')
                  .toString(),
              appBar: new AppBar(title: new Text("Widget webview")),
              javascriptChannels: jsChannels,
            ),
      },
    );
  }
}