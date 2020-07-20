import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

// Uses the regular webview, with an asset being loaded from the filesystem

void main() => runApp(MyApp());

var lastResult = "nothing yet";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (_) => WebViewTest(),
      },
    );
  }
}

class WebViewTest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WebViewTestState();
  }
}

class _WebViewTestState extends State<WebViewTest> {
  //
  WebViewController _webViewController;
  String filePath = 'assets/index_main.html';
  final globalKey = GlobalKey<ScaffoldState>(); // HACK1

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey, // HACK1
      appBar: AppBar(title: Text('Webview Little JS World')),
      body: WebView(
        initialUrl: '',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
          _loadHtmlFromAssets();
        },
        javascriptChannels: <JavascriptChannel>[
          _toasterJavascriptChannel(context),
        ].toSet(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Scaffold.of(context).showSnackBar(
          //   SnackBar(content: Text('Calling JS...')),
          // );
          globalKey.currentState
              .showSnackBar(SnackBar(content: Text('Calling JS...')));

          _webViewController
              .evaluateJavascript('fred_add_via_timeout_which_posts(10, 10)');
        },
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          print('message from javascript: ${message.message}');

          // andy secret way to comm to other code - should perhaps update a provider model?
          lastResult = message.message;

          globalKey.currentState
              .showSnackBar(SnackBar(content: Text(message.message)));

          // Scaffold.of(context).showSnackBar(
          //   SnackBar(content: Text(message.message)),
          // );
        });
  }

  _loadHtmlFromAssets() async {
    String fileHtmlContents = await rootBundle.loadString(filePath);
    _webViewController.loadUrl(Uri.dataFromString(fileHtmlContents,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
