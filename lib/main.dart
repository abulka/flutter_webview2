import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

// Uses the regular webview, with an asset being loaded from the filesystem

// Both webview and FloatingActionButton wrapped in a Builder to give 'ctx' to pass to
// _toasterJavascriptChannel or onPressed - which needs access to Scaffold context for toaster
// (research in research/webview_official/toaster_scaffold_context_tricks/main_toaster_hacks.dart)

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
  TextEditingController txtController;
  // String _input = '';

  // set input(String val) {
  //   setState(() {
  //     _input = val;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    txtController = TextEditingController(text: "2 + 3");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // avoid resize when keyboard appears
      appBar: AppBar(title: Text('Webview Little JS World')),
      body: Builder(
        builder: (ctx) => Column(
          children: [
            Container(
              color: Colors.amber,
              child: TextField(
                controller: txtController,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'Enter a math term'),
                onChanged: (text) {
                  print("text field so far...: $text");
                },
                onSubmitted: (value) {
                  assert(value == txtController.text);
                  doEval();
                },
              ),
            ),
            Row(
              children: [
                RaisedButton(
                  onPressed: () {
                    txtController.text = "math.evaluate('12.7 cm to inch')";
                    txtController.selection = TextSelection.fromPosition(
                      TextPosition(offset: txtController.text.length),
                    );
                  },
                  child: Text('example to inch'),
                ),
                RaisedButton(
                  onPressed: () =>
                      txtController.text = "math.evaluate('sin(45 deg) ^ 2')",
                  child: Text('example sin'),
                ),
                RaisedButton(
                  onPressed: () =>
                      txtController.text = "math.pow([[-1, 2], [3, 1]], 2)",
                  child: Text('example math.pow'),
                )
              ],
            ),
            Center(
              child: RaisedButton(
                color: Colors.green,
                onPressed: () {
                  doEval();
                },
                child: Text('='),
              ),
            ),
            Container(
              height: 250,
              child: WebView(
                initialUrl: '',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _webViewController = webViewController;
                  _loadHtmlFromAssets();
                },
                javascriptChannels: <JavascriptChannel>[
                  _toasterJavascriptChannel(ctx),
                ].toSet(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (ctx) => FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Scaffold.of(ctx).showSnackBar(
              SnackBar(
                content: Text('Calling JS2...'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.blueGrey[200],
                duration: Duration(milliseconds: 200),
              ),
            );
            _webViewController
                // .evaluateJavascript('fred_add_via_timeout_which_posts(10, 10)');
                // .evaluateJavascript('add(10, 10)');
                // .evaluateJavascript('mathjs1(10, 10)');
                .evaluateJavascript(
                    'result = math.sqrt(-2).toString(); Toaster.postMessage(result)');
          },
        ),
      ),
    );
  }

  void doEval() {
    var expr = txtController.text;
    var s = 'result = $expr; Toaster.postMessage(result.toString())';
    print(s);
    _webViewController.evaluateJavascript(s);
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
