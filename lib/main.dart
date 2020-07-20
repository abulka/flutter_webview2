import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

// Uses the regular webview, with an asset being loaded from the filesystem

// HACK 1 and 2 are just two techniques to allow calling a toaster on a scaffold
// https://stackoverflow.com/questions/51304568/scaffold-of-called-with-a-context-that-does-not-contain-a-scaffold

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
  final globalKey = GlobalKey<ScaffoldState>(); // HACK1 allocate a new key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey, // HACK1 make Scaffold use it, thus giving us access
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
      floatingActionButton: Builder(
        // HACK2 wrap in a Builder to give 'ctx'
        builder: (ctx) => FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            /// Note: context here is wrong, you are using the context of the
            /// widget that instantiated Scaffold, not the context of a child of Scaffold.
            // Scaffold.of(context).showSnackBar(
            //   SnackBar(content: Text('Calling JS...')),
            // );
            /// HACK1 use global key to get access to the state object!
            // globalKey.currentState
            //     .showSnackBar(SnackBar(content: Text('Calling JS...')));
            /// HACK2 wrap the FloatingActionButton in a a Builder
            Scaffold.of(ctx).showSnackBar(
              SnackBar(
                content: Text('Calling JS2...'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.blueGrey[200],
                duration: Duration(milliseconds: 200),
              ),
            );
            // print('button ctx: ${ctx.hashCode}');

            _webViewController
                // .evaluateJavascript('fred_add_via_timeout_which_posts(10, 10)');
                .evaluateJavascript('add(10, 10)');
          },
        ),
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          print(
              'message from javascript: ${message.message} context: ${context.hashCode}');

          // andy secret way to comm to other code - should perhaps update a provider model?
          lastResult = message.message;

          // HACK1 use global key to get access to the state object!
          globalKey.currentState.showSnackBar(SnackBar(
            content: Text(message.message),
            duration: Duration(seconds: 2),
          ));

          // HACK2 not possible here because we can't wrap anything in a builder,
          // I mean, a JavascriptChannel is not a widget.
          // Though lib\research\webview_official\main_official_big_plus_andy.dart
          // seems to do it using some future magic - see
          // Widget favoriteButton() { ... on line 133.

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
