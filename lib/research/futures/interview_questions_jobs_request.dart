import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'dart:convert'; // for json.decode
import 'package:http/http.dart' as http;
import 'package:dedent/dedent.dart'; // my dedent library

// interview question puzzles - Future with a List of Jobs
// https://www.raywenderlich.com/10971345-flutter-interview-questions-and-answers#toc-anchor-015

/*
GitHub Jobs has an open API for querying software engineering-related job
positions. The following URL returns a list of remote jobs:

https://jobs.github.com/positions.json?location=remote

Given the following simple data class, in which you only care about the company
name and job title, write a function that returns a Future with a List of Jobs.
You can ignore error checking for this question.

class Job {
  Job(this.company, this.title);

  final String company;
  final String title;
}

*/

void main() {
  runApp(MyApp());
}

class MyModel extends ChangeNotifier {
  newDogPlease() {
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
        appBar: AppBar(
            title:
                Text('Interview Questions - Jobs from Internet via Futures')),
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
              // Why does this wrap nicely? Whereas previously (in the interview
              // question puzzle) we had to add the Expanded() widget. But if we
              // add Expanded() here, it pushes the text area to be HUGE and
              // taking up most of the screen!
              Text(dedent('''
                  Fetching Jobs only works in an emulator - not in chrome browser. 
                  Because "access-control-allow-origin: *" is not the header 
                  coming back from the Jobs server.
                  https://jobs.github.com/positions.json?location=remote
                  
                  AAA aasdassd das adss  lsdkjf lsdkjf lsdkjf lskdjf lskdjf lskdjflksd jflksdj flksdj flksdjf lksdjf lskdjf lksd sldkfjsdlkfj lsdkjf lskdjf lksdjf lskdjf l ldskjf lsdkjf lskdfj lskdfj lsdkjf

                  However this endpoint 
                  https://dog.ceo/api/breeds/image/random (API doco: https://dog.ceo/dog-api/documentation/random)
                  does return "access-control-allow-origin: *" in the header (yay)
                  So fetching dog pictures should work in chrome.
                  ''')),

              JobsWidgetPuzzle(),
            ],
          );
        });
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
    // futureJobs = fetchJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Adding any Expanded Text stuff here breaks the layout completely.
        /// I think this is because  we are a column in a column? Adding the text
        /// one layer up works better.
        //
        // Expanded(
        //   child: FittedBox(
        //       child: Text(
        //           'This only works in an emulator - not in chrome browser')),
        // ),
        // Flexible(child: FittedBox(child: Text('aasdassd das adss'))),
        // Flexible(child: Text('aasdassd das adss')),
        // FittedBox(child: Text('aasdassd das adss  lsdkjf lsdkjf lsdkjf lskdjf lskdjf lskdjflksd jflksdj flksdj flksdjf lksdjf lskdjf lksd sldkfjsdlkfj lsdkjf lskdjf lksdjf lskdjf l ldskjf lsdkjf lskdfj lskdfj lsdkjf')),
        // Expanded(child: Text('aasdassd das adss  lsdkjf lsdkjf lsdkjf lskdjf lskdjf lskdjflksd jflksdj flksdj flksdjf lksdjf lskdjf lksd sldkfjsdlkfj lsdkjf lskdjf lksdjf lskdjf l ldskjf lsdkjf lskdfj lskdfj lsdkjf')),
        // SizedBox(
        //     height: 50,
        //     child:
        //         Text('This only works in an emulator - not in chrome browser')),

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
        ),
        Divider(
          color: Colors.green[200],
          thickness: 2,
        ),
        RaisedButton(
          onPressed: () {
            Provider.of<MyModel>(context, listen: false).newDogPlease();
            // Disabled using a Consumer because we don't want to build anything,
            // we instead want to trigger Dog fetchData() which in turn
            // will trigger the build once the data has arrived.
            // The question is whether provider allows a receiver of the notifyall
            // to be a regular method somewhere? NO

            // Alternatively we might need a futurebuilder where the image
            // gets build once the http call has been received, as represented
            // as a future.
            //
            // Then again the initial implementation has the method await on
            // the http call then set state, which triggers the build - sounds
            // like an alternative to future builder!? ;-)

            /// AHA what about putting the fetching of the jobs in the model
            /// then when the jobs arrive, we notifylisteners.  this sounds
            /// sensible!

          },
          child: Text('Fetch Dog picture'),
        ),
        // Consumer<MyModel>(
        //     builder: (context, myModel, child) => HttpRequestDogDemo()),
        HttpRequestDogDemo(),
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
  final host = 'jobs.github.com';
  final path = 'positions.json';
  final queryParameters = {'location': 'remote'};
  final headers = {'Accept': 'application/json'};
  final uri = Uri.https(host, path, queryParameters);
  print('fetchJobs() async function being called... $uri');
  final results = await http.get(uri, headers: headers);

  // SIMPLER INVOCATION
  // final results =
  //     await http.get('https://jobs.github.com/positions.json?location=remote');

  print('fetchJobs() result after await, status = ${results.statusCode}');
  final jsonList = json.decode(results.body) as List;
  // print('fetchJobs() jsonList = $jsonList');
  return jsonList.map((job) => Job.fromJson(job)).toList();
}

// Fetching Dog pictures
// https://stackoverflow.com/questions/58557173/how-to-make-http-request-work-in-flutter-web

class HttpRequestDogDemo extends StatefulWidget {
  @override
  _HttpRequestDogDemoState createState() => _HttpRequestDogDemoState();
}

class _HttpRequestDogDemoState extends State<HttpRequestDogDemo> {
  String imageUrl = "";

  @override
  void initState() {
    print('DOG WIDGET - initState()');

    // this only happens once ever during the app.
    // fetchData();

    super.initState();

    // this only happens once ever during the app.
    // WidgetsBinding.instance
    //     .addPostFrameCallback((_) => fetchData());
  }

  Consumer<MyModel>(
    builder: (context, myModel, child) => print );

  @override
  Widget build(BuildContext context) {
    print('DOG WIDGET - build()');

    // Yeah, this just sets off an infinit loop, cos the fetchData() triggers
    // a build() and the build triggers a fetchData() etc.
    // WidgetsBinding.instance.addPostFrameCallback((_) => fetchData());

    return Container(
        child: Column(
      children: <Widget>[
        Center(
          child: Image.network(
            imageUrl,
            height: MediaQuery.of(context).size.height / 6,
            width: MediaQuery.of(context).size.width / 6,
          ),
        ),
        FloatingActionButton(
          child: Icon(Icons.cloud_download),
          onPressed: () {
            fetchData();
          },
        )
      ],
    ));
  }

  fetchData() async {
    final res = await http.get("https://dog.ceo/api/breeds/image/random");

    if (res.statusCode == 200) {
      var v = json.decode(res.body);
      setState(() {
        imageUrl = v['message'];
      });
    }
  }
}
