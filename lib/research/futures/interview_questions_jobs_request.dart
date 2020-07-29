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

class MyDogModel extends ChangeNotifier {
  String imageUrl = "https://placeimg.com/64/48/any";

  fetchData() async {
    final res = await http.get("https://dog.ceo/api/breeds/image/random");

    if (res.statusCode == 200) {
      var v = json.decode(res.body);
      imageUrl = v['message'];
      notifyListeners();
    }
  }
}

class MyJobsModel extends ChangeNotifier {
  List<Job> jobs; // interesting we don't have to declare this Future<List<Job>>
  fetchData() async {
    jobs = await fetchJobs();
    print('After MyJobsModel await, result = ${jobs.map((job) => job.title)}');
    notifyListeners();
  }
}

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
            title: Text(
                'Interview Questions - Jobs and Dogs from Internet via Futures')),
        body: BodyLayout(),
      ),
    );
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<MyDogModel>(create: (context) => MyDogModel()),
          ChangeNotifierProvider<MyJobsModel>(
              create: (context) => MyJobsModel()),
        ],
        builder: (context, child) {
          return Page();
        });
  }
}

class Page extends StatelessWidget {
  const Page({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: InfoTextArea(),
          ),
          Divider(
            color: Colors.green,
            thickness: 2,
          ),
          Expanded(flex: 3, child: JobsArea()),
          Divider(
            color: Colors.green[200],
            thickness: 2,
          ),
          // Dogs area doesn't seem to need expanded, since it is a row which
          // is the size it is, based on the images
          DogsArea(),
        ],
      ),
    );
  }
}

class InfoTextArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Text(dedent('''
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
    );
  }
}

class JobsArea extends StatelessWidget {
  const JobsArea({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
            RaisedButton(
              onPressed: () async {
                print('fetchJobs() via model');
                Provider.of<MyJobsModel>(context, listen: false).fetchData();
              },
              child: Text('fetchJobs() via model'),
            ),
          ],
        ),
        JobsListView(),
      ],
    );
  }
}

class DogsArea extends StatelessWidget {
  const DogsArea({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text('v1. (widget does fetch and await)'),
            HttpRequestDogDemo(),
          ],
        ),
        Column(
          children: [
            Text('v2 (model, button is sep. widget).'),
            Consumer<MyDogModel>(
                builder: (context, myDogModel, child) =>
                    HttpRequestDogDemo2(myDogModel.imageUrl)),
            RaisedButton(
              onPressed: () {
                /// Initial (wrong) thought was to call a method on the model here,
                /// which would then somehow trigger the fetchData() function in
                /// the image rendering widget, which would await and then set its
                /// state with the new dog url, which would trigger image build().
                ///
                /// Turns out this is wrong because with provider you cannot have
                /// a mere method or function being a consumer/listener - the
                /// Consumer must be part of the widget build. Provider is a pattern
                /// about widgets consuming model notifications, not about arbitrary
                /// listener functions being notified.
                ///
                /// Plus the deeper problem was that in the above abandoned wrong
                /// approach the model was doing nothing and the widget was doing
                /// fetching and building. The model needed to do more - the fetching
                /// and the widget is the UI responding to the model change - perfect.

                /// Update: now use model properly - do the fetching in the model
                /// then notify the gui
                Provider.of<MyDogModel>(context, listen: false).fetchData();

                // Alternatively we might need a futurebuilder where the image
                // gets build once the http call has been received, as represented
                // as a future.
                //
                // Then again the initial implementation has the method await on
                // the http call then set state, which triggers the build - sounds
                // like an alternative to future builder!? ;-)
              },
              child: Text('Fetch Dog picture'),
            ),
          ],
        )
      ],
    );
  }
}

class JobsListView extends StatelessWidget {
  final List<String> notes = [
    "fluttermaster.com",
    "Update Android Studio to 3.3",
    "Implement ListView widget",
    "Demo ListView simplenote app",
    "Fixing app color",
    "Create new note screen",
    "Persist notes data",
    "Add screen transition animation",
    "Something long Something long Something long Something long Something long Something long",
    "2 fluttermaster.com",
    "2a fluttermaster.com",
    "2 Update Android Studio to 3.3",
    "2a Update Android Studio to 3.3",
    "2 Implement ListView widget",
    "2a Implement ListView widget",
    "2 Demo ListView simplenote app",
    "2a Demo ListView simplenote app",
    "2 Fixing app color",
    "2a Fixing app color",
    "2 Create new note screen",
    "2a Create new note screen",
    "2 Persist notes data",
    "2a Persist notes data",
    "2 Add screen transition animation",
    "2a Add screen transition animation",
    "2 Something long Something long Something long Something long Something long Something long",
    "2a Something long Something long Something long Something long Something long Something long",
  // ].map((el) => el + '--' * 20 + el * 12).toList();
  ];

  @override
  Widget build(BuildContext context) {
    // Had to wrap listview in expanded so that it sized itself out.  But also
    // had to wrap this entire widget with expanded again, so the WIDGET itself
    // expanded itself out!
    return Expanded(
      child: ListView.builder(
          // shrinkWrap: true,
          itemCount: notes.length,
          itemBuilder: (context, idx) {
            return Text(notes[idx]);
          }),
    );

    // return Text(notes[2]);
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
            height: MediaQuery.of(context).size.height / 4,
            width: MediaQuery.of(context).size.width / 4,
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

// Fetching Dog pictures v2. - using a model, which allows my
// fetch button to be a separate widget. It also leverages provider model pattern

class HttpRequestDogDemo2 extends StatelessWidget {
  final String imageUrl;
  HttpRequestDogDemo2(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.network(
        imageUrl,
        height: MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width / 4,
      ),
    );
  }
}
