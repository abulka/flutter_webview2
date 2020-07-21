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
      body: Builder(
        // HACK2 wrap webview in a Builder to give 'ctx' to pass to
        // _toasterJavascriptChannel which needs access to Scaffold context
        builder: (ctx) => WebView(
          initialUrl: '',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            print(
                'onWebViewCreated thus _webViewController ${_webViewController.hashCode} = webViewController ${webViewController.hashCode}');
            _webViewController = webViewController;
            _loadHtmlFromAssets();
          },
          javascriptChannels: <JavascriptChannel>[
            // _toasterJavascriptChannel(context),
            _toasterJavascriptChannel(ctx),
          ].toSet(),
        ),
      ),
      floatingActionButton:
          FloatyButton_FAILURE(_webViewController), // NEW IDEA - failing though
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

          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  _loadHtmlFromAssets() async {
    String fileHtmlContents = await rootBundle.loadString(filePath);
    _webViewController.loadUrl(Uri.dataFromString(fileHtmlContents,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}

/// Extracting the button widget allows us to remove the outer Builder
/// which was simply giving us a new context local to get the scaffold in
/// order to do toast popups.
/// But now we have a problem re the value of webViewController not updating?!
/// and even being null initially (which we expect, actually)
class FloatyButton_FAILURE extends StatefulWidget {
  FloatyButton_FAILURE(
    this._webViewController, {
    Key key,
  }) : super(key: key) {
    print(
        'Floaty constructor _webViewController=$_webViewController}');
    // assert(_webViewController != null);
  }
  WebViewController _webViewController;

  // unfortunately the _webViewController passed in as a parameter is the
  // original value, before the real value is allocated in onWebViewCreated
  // WTF - aren't refs honoured? Ah its a final, perhaps if we remove that.
  // final WebViewController _webViewController;
  // No that didn't work. This is a stateless widget and has const and other
  // stateless expectations. I think we need to convert to a stateful widget?
  // even though our state isn't really changing - its just the
  // webViewController pointer changing
  // WebViewController _webViewController;

  /// converting to a stateful widget didn't work - the
  /// _webViewController arrives as null and never gets updated!
  /// even widget._webViewController is null

  @override
  _FloatyButton_FAILUREState createState() => _FloatyButton_FAILUREState(_webViewController);
}

class _FloatyButton_FAILUREState extends State<FloatyButton_FAILURE> {
  _FloatyButton_FAILUREState(this._webViewController);
  WebViewController _webViewController; // doesn't get updated!

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Calling JS2...'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.blueGrey[200],
            duration: Duration(milliseconds: 200),
          ),
        );
        print(
            'button context: ${context.hashCode} _webViewController=$_webViewController} widget=$widget widget._webViewController=${widget._webViewController}');

        widget._webViewController
            // .evaluateJavascript('fred_add_via_timeout_which_posts(10, 10)');
            .evaluateJavascript('add(10, 10)');
      },
    );
  }
}
