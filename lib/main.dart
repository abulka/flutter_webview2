import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_webview2/models/calculation.dart';
import 'package:provider/provider.dart';

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
        "/": (_) => ChangeNotifierProvider(
            create: (context) => CalculationsModel(),
            builder: (context, child) {
              return WebViewTest();
            })
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
              height: 15,
              color: Colors.amber[500],
              child: const Center(
                  child: Text('status indicators etc',
                      style: TextStyle(
                          fontSize: 10.0, fontWeight: FontWeight.bold))),
            ),
            Expanded(child: _myListView2(context)),
            Container(
              color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: txtController,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.only(
                          left: 4.0, bottom: 2.0, top: 2.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(1))),
                      hintText: 'Enter a math term'),
                  onChanged: (text) {
                    print("text field so far...: $text");
                  },
                  onSubmitted: (value) {
                    assert(value == txtController.text);
                    doEval();
                  },
                ),
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

                  // Dummy
                  // var r = Random();
                  // var expression = '${r.nextInt(1000)} + ${r.nextInt(1000)}';
                  // if (r.nextInt(100) < 50) expression += ' / ${r.nextInt(1000)}';
                  // final Calculation c = Calculation(
                  //   expression: expression,
                  //   completed: false,
                  // );
                  // Provider.of<CalculationsModel>(context, listen: false).add(c);
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

          // Scaffold.of(context).showSnackBar(
          //   SnackBar(content: Text(message.message)),
          // );

          // a real calculation
          var r = Random();
          var expression = '${r.nextInt(1000)} + ${r.nextInt(1000)}';
          if (r.nextInt(100) < 50) expression += ' / ${r.nextInt(1000)}';
          expression += ' = ${message.message}';
          final Calculation c = Calculation(
            expression: expression,
            completed: false,
          );

          Provider.of<CalculationsModel>(context, listen: false).add(c);
        });
  }

  _loadHtmlFromAssets() async {
    String fileHtmlContents = await rootBundle.loadString(filePath);
    _webViewController.loadUrl(Uri.dataFromString(fileHtmlContents,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}

// MODEL

Widget _myListView2(BuildContext context) {
  return AllCalculations();
}

/// It is generally considered a bad practice to enclose a huge widget tree
/// inside a Consumer widget. This widget should be inserted as deep as possible
/// in the widget tree to prevent unnecessary re-renders. For more info, see
/// here. We need to re-render all the list items in case any of the task item
/// changes. That's why I have enclosed the use of TaskList widget inside the
/// Consumer. Now whenever our provider calls notifyListener in its model. It
/// will re-render our TaskList widget.
class AllCalculations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<CalculationsModel>(
        builder: (context, calculationModel, child) =>
            CalculationList(calculationModel: calculationModel),
      ),
    );
  }
}

/// Generate widgets from model
class CalculationList extends StatelessWidget {
  final CalculationsModel calculationModel;
  final _scrollController = ScrollController();

  CalculationList({@required this.calculationModel});

  _scrollToBottom() {
    // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    if (calculationModel.justAdded)
      // Timer(Duration(milliseconds: 100), () => _scrollToBottom());
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return ListView(
      controller: _scrollController,
      children: convertModelToWidgets(),
    );
  }

  /// Converts the pure model list of calculations into a list of widgets
  /// .map() returns a lazy iterable of the new thing, so .toList() forces computation
  /// not sure why we can't leave it as iterable - surely the build() method can cope?
  ///
  /// Also, had to convert .map into .map<Widget> because type inference fails
  /// in an unexpected way - see https://stackoverflow.com/questions/49603021/type-listdynamic-is-not-a-subtype-of-type-listwidget
  List<Widget> convertModelToWidgets() {
    return calculationModel.allCalculations
        .map<Widget>(
            (calculation) => CalculationListItem(calculation: calculation))
        .toList();
  }
}

class CalculationListItem extends StatelessWidget {
  final Calculation calculation;

  CalculationListItem({@required this.calculation});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: calculation.completed,
        onChanged: (bool checked) {
          Provider.of<CalculationsModel>(context, listen: false)
              .toggleComplete(calculation);
        },
      ),
      title: Text(calculation.expression),
      trailing: IconButton(
        icon: Icon(
          Icons.delete,
          color: Colors.red,
        ),
        onPressed: () {
          Provider.of<CalculationsModel>(context, listen: false)
              .delete(calculation);
        },
      ),
    );
  }
}
