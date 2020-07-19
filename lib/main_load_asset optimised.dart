import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/services.dart' show rootBundle;

// Uses the extra webview functionality of 'flutter_webview_plugin'
// with additional asset loading

// this is a failure - I can't return webview twice - the header updates
// but the contents do not refresh?

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
            // var s = '<html><p>Loading...</p></html>';
            // if (false && snapshot.hasData)
            //   s = Uri.dataFromString(snapshot.data, mimeType: 'text/html')
            //       .toString();

            // var s = Uri.dataFromString(
            //     '<html><button onclick="Print.postMessage(\'test\');">Click me</button></html>',
            //     mimeType: 'text/html').toString();

            // print('build being called with ${snapshot.hasData} s=$s');
            // s = Uri.dataFromString(snapshot.data, mimeType: 'text/html')
            //     .toString();



            // var s = snapshot.hasData
            //     ? Uri.dataFromString(snapshot.data, mimeType: 'text/html')
            //         .toString()
            //     : Uri.dataFromString(
            //             '<html><button onclick="Print.postMessage(\'test\');">Click me</button></html>',
            //             mimeType: 'text/html')
            //         .toString();
            // var result = WebviewScaffold(
            //     url: s,
            //     withLocalUrl: true,
            //     appBar: new AppBar(title: new Text("Widget webview 2")),
            //     javascriptChannels: jsChannels,
            //   );
            //   // yeah but how to call result.reload() ? need to return
            //   // the widget first then call the reload later?  hard.



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
          })
    });
  }
}

Future<String> loadAsset() async {
  await Future.delayed(Duration(seconds: 2)); // wait
  return await rootBundle.loadString('assets/index.html');
}
