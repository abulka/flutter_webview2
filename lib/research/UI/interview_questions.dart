import 'package:flutter/material.dart';
// import 'dart:math';
// import 'package:dart_random_choice/dart_random_choice.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'dart:convert'; // for json.decode
import 'package:http/http.dart' as http;

// interview question puzzles
// https://www.raywenderlich.com/10971345-flutter-interview-questions-and-answers

void main() {
  runApp(MyApp());
}

class MyModel extends ChangeNotifier {
  List buttonLabels = ['Do A', 'Do B', 'Do C', 'Do D'];

  void add(String label) {
    buttonLabels.add(label);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Experiments',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Interview Questions Learning')),
        body: BodyLayout(),
      ),
    );
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyModel(),
        builder: (context, child) {
          return Column(
            children: [
              // MyTextWidget(),
              // MyTextWidget(
              //   kind: Kind.fittedBox,
              // ),
              // MyTextWidget(
              //   kind: Kind.fittedBoxNoRowOrIcons,
              // ),
              // MyTextWidget(
              //   kind: Kind.expanded,
              // ),
              // MyTextWidget(
              //   kind: Kind.expandedFittedBox,
              // ),
              // NestedScaffolds(),
              // UsingKeysPuzzle(),
              JobsWidgetPuzzle(),
            ],
          );
        });
  }
}

// Text Widget variants

enum Kind {
  none,
  fittedBox,
  fittedBoxNoRowOrIcons,
  expandedFittedBox,
  expanded
}

extension ParseToString on Kind {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

class MyTextWidget extends StatelessWidget {
  final personNextToMe =
      'That reminds me about the time when I was ten and our neighbor, her name was Mrs. Mable, and she said...';
  final Kind kind;
  MyTextWidget({this.kind = Kind.none});

  @override
  Widget build(BuildContext context) {
    var widget;
    var txt = '$personNextToMe ${this.kind}';
    // var txt = this.kind.toString().split('.').last;
    // var txt = '$personNextToMe (${this.kind.toShortString()})';

    switch (this.kind) {
      case Kind.expanded:
        txt += ' (notice this wraps)';
        widget = Expanded(child: Text(txt));
        break;
      case Kind.fittedBox:
        widget = FittedBox(child: Text(txt));
        break;
      case Kind.expandedFittedBox:
        widget = Expanded(child: FittedBox(child: Text(txt)));
        break;
      case Kind.fittedBoxNoRowOrIcons:
        widget = FittedBox(
            child: Text(
          txt,
          // style: new TextStyle(
          //     color: Colors.orange[900],
          //     fontWeight: FontWeight.bold,
          //     fontFamily: "Roboto"),
        ));
        return widget;
        break;
      default:
        widget = Text(txt);
    }

    return Row(children: [
      Icon(Icons.airline_seat_legroom_reduced),
      widget,
      Icon(Icons.airline_seat_legroom_reduced),
    ]);
  }
}

class NestedScaffolds extends StatelessWidget {
  const NestedScaffolds({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Scaffold(
        appBar: AppBar(title: Text('sub scaffold')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Colors.red,
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Scaffold(
                appBar: AppBar(title: Text('sub sub scaffold')),
                body: Row(
                  // mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.blue,
                        height: 100,
                        child: Text('body of sub sub'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Intermediate Written Questions - Question 1
// dynamic delete puzzle
// https://www.raywenderlich.com/10971345-flutter-interview-questions-and-answers#toc-anchor-008

/*
When you have a stateful widget and something about the widget tree changes, the
framework compares widget types to see what it can reuse.

Since both CounterButton widgets are of the same type, Flutter doesn’t know
which widget to assign the state to. That results in the red button updating
with the blue button’s internal counter state.

To address this, use the key property for each widget. This property adds an ID
for the widget:

CounterButton(
  key: ValueKey('red'),
  color: Colors.red,
),

By adding key, you’ve uniquely identified the red counter button and Flutter
will be able to preserve its state. You can read more about using keys in the
Medium article, Keys! What are they good for?.
*/

class UsingKeysPuzzle extends StatefulWidget {
  @override
  _UsingKeysPuzzleState createState() => _UsingKeysPuzzleState();
}

class _UsingKeysPuzzleState extends State<UsingKeysPuzzle> {
  bool isShowing = true;
  bool whiteOnTop = false;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      RaisedButton(
        child: (Text('Delete blue')),
        onPressed: () {
          setState(() {
            isShowing = false;
          });
        },
      ),
      RaisedButton(
        child: (Text('Toggle White on Top')),
        onPressed: () {
          setState(() {
            whiteOnTop = !whiteOnTop;
          });
        },
      ),

      // Original problem posed - solved by key trick. But remember you not only
      // have to create the constructor, but you MUST PASS IN A UNIQUE KEY when
      // CREATING the object instance - the key can be anything
      if (isShowing)
        CounterButton(
            key: ValueKey('blue ha'),
            color: Colors.blue), // self contained line
      CounterButton(
          key: ValueKey('red ho ho'), color: Colors.red), // always draw the red

      Divider(
        color: Colors.black,
        thickness: 2,
      ),

      // A different problem, which the 'key' constructor trick to preserve the state
      // should also fix.
      ...getButtonsInParticularOrder(),
    ]);
  }

  List<Widget> getButtonsInParticularOrder() {
    // takes advantage of spread operator
    // https://stackoverflow.com/questions/55286524/how-to-pass-list-of-widgets-in-children-property-of-another-widget
    if (whiteOnTop)
      return [
        CounterButton(key: ValueKey('1'), color: Colors.white),
        CounterButton(key: ValueKey('2'), color: Colors.green)
      ];
    else
      return [
        // Do not allocated different keys e.g. 3, 4 here cos we want to
        // associate state, and the keys seem to be how the state is preserved.
        // ANDY TIP: Even when widgets are rebuilt, if their key is the same as
        // an old widget the state will be transferred.
        CounterButton(key: ValueKey('2'), color: Colors.green),
        CounterButton(key: ValueKey('1'), color: Colors.white)
      ];
  }
}

// CounterButton has to be a stateful widget because it has a counter inside itself.
// Found it at https://stackoverflow.com/questions/59516450/preserve-widget-state-when-temporarily-removed-from-tree-in-flutter
// Had to enhance it myself with a 'color' parameter using info from
// https://stackoverflow.com/questions/50818770/passing-data-to-a-stateful-widget
// where you put the constructor on the StatefulWidget not on the State.
// Thus there is state in both! :-o
// But here we learn about accessing the state of the StatefulWidget from State
// via 'widget' property.

class CounterButton extends StatefulWidget {
  // apparently should keep constructor state in here, not in state sub obj !
  final Color color;
  // 'key' constructor trick to preserve the state - remember to construct
  // the widget instance passing in a key, that key being something unique
  // so the new widget (rebuilt on build) gets state transferred to it.
  // CounterButton({this.color});
  const CounterButton({Key key, this.color}) : super(key: key);

  @override
  _CounterButtonState createState() => _CounterButtonState();
}

class _CounterButtonState extends State<CounterButton> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      // color: Colors.orangeAccent,
      color: widget
          .color, // AHA this is how to access the widget owning this state
      child: Text(counter.toString()),
      onPressed: () {
        setState(() {
          counter++;
        });
      },
    );
  }
}

// GitHub jobs puzzle
// https://www.raywenderlich.com/10971345-flutter-interview-questions-and-answers#toc-anchor-015

class Job {
  final String company;
  final String title;
  Job({this.company, this.title});

  // factory Job.fromJson(Map<String, dynamic> json) {
  //   return Job(
  //     company: json['company'],
  //     title: json['title'],
  //   );
  // }

  Job.fromJson(Map<String, dynamic> json)
      : company = json['company'],
        title = json['title'];
}

class JobsWidgetPuzzle extends StatefulWidget {
  @override
  _JobsWidgetPuzzleState createState() => _JobsWidgetPuzzleState();
}

class _JobsWidgetPuzzleState extends State<JobsWidgetPuzzle> {
  // Future<Job> futureJob;
  Future<List<Job>> futureJobs;

  @override
  void initState() {
    super.initState();
    // futureJob = fetchJob();
    futureJobs = fetchJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: Colors.green,
          thickness: 2,
        ),
        RaisedButton(
          onPressed: () {
            print('fetchJobs().then');
            fetchJobs().then((result) {
              // print('fetchJobs().then, result = $result');
              print('fetchJobs().then, ${result.map((job) => job.title)}');
            });
          },
          child: Text('fetchJobs().then()'),
        ),
        RaisedButton(
          onPressed: () async {
            print('fetchJobs() async await');
            var result = await fetchJobs();
            print('In await, result = ${result.map((job) => job.title)}');
          },
          child: Text('fetchJobs() async await'),
        )
      ],
    );
  }
}

// Future<http.Response> fetchAlbum() {
//   return http.get('https://jobs.github.com/positions.json?location=remote');
// }

//   Future<Job> fetchJob() async {
//     print('fetchJob begins....');
//     final response = await http
//         .get('https://jobs.github.com/positions.json?location=remote');
//     print('response.statusCode = ${response.statusCode}');
//     if (response.statusCode == 200) {
//       // If the server did return a 200 OK response,
//       // then parse the JSON.
//       return Job.fromJson(json.decode(response.body));
//     } else {
//       // If the server did not return a 200 OK response,
//       // then throw an exception.
//       throw Exception('Failed to load jobs');
//     }
//   }
// }

Future<List<Job>> fetchJobs() async {
  // THIS MORE COMPLEX INVOCATION WORKS OK TOO
  // print('fetchJobs()');
  // final host = 'jobs.github.com';
  // final path = 'positions.json';
  // final queryParameters = {'location': 'remote'};
  // final headers = {'Accept': 'application/json'};
  // final uri = Uri.https(host, path, queryParameters);
  // final results = await http.get(uri, headers: headers);

  final results = await http
        .get('https://jobs.github.com/positions.json?location=remote');
  print(
      'fetchJobs() result after await, status = ${results.statusCode}');
  final jsonList = json.decode(results.body) as List;
  // print('fetchJobs() jsonList = $jsonList');
  return jsonList.map((job) => Job.fromJson(job)).toList();
}
