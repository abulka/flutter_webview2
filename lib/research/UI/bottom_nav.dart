// Flutter code sample for BottomNavigationBar

// This example shows a [BottomNavigationBar] as it is used within a [Scaffold]
// widget. The [BottomNavigationBar] has three [BottomNavigationBarItem]
// widgets and the [currentIndex] is set to index 0. The selected item is
// amber. The `_onItemTapped` function changes the selected item's index
// and displays a corresponding message in the center of the [Scaffold].
//
// ![A scaffold with a bottom navigation bar containing three bottom navigation
// bar items. The first one is selected.](https://flutter.github.io/assets-for-api-docs/assets/material/bottom_navigation_bar.png)

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  // this is a list of content widgets - one per page
  // but cannot embed $_selectedIndex in what is returned cos its
  // a compile time creation - even if 'static const ' is removed
  //
  // static const List<Widget> _widgetOptions = <Widget>[
  //   Text(
  //     'Index 0: Home',
  //     style: optionStyle,
  //   ),
  //   Text(
  //     'Index 1: Business',
  //     style: optionStyle,
  //   ),
  //   Text(
  //     'Index 2: School',
  //     style: optionStyle,
  //   ),
  // ];

  Widget getPage() {
    List<Widget> _widgetOptions = <Widget>[
      Center(
        child: Text(
          'Andy Index 0: Home',
          style: optionStyle,
        ),
      ),
      Center(
        child: Text(
          'Andy Index $_selectedIndex: Business',
          style: optionStyle,
        ),
      ),
      // SchoolPage(index: _selectedIndex), // if don't pass in the optionStyle it will be null, but that's rendered OK
      SchoolPage(index: _selectedIndex, optionStyle: optionStyle),
      // Text(
      //   'Andy Index 2: School',
      //   style: optionStyle,
      // ),
    ];
    return _widgetOptions.elementAt(_selectedIndex);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print('changed tab to $index');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BottomNavigationBar Sample'),
      ),
      body: getPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Business'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            title: Text('School'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

// School widget

class SchoolPage extends StatelessWidget {
  final int _selectedIndex;
  final optionStyle;  // if don't pass in the optionStyle it will be null, but that's rendered OK
  const SchoolPage({Key key, int index = 22, this.optionStyle})
      : _selectedIndex = index,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    print(
        'building school page with $_selectedIndex and optionStyle $optionStyle');
    return Container(
      child: Column(
        children: [
          // looks like you CAN refer to $_selectedIndex here, probably because
          // this is more dynamic code - not a compile time variable declaration
          Container(
            height: 50,
            color: Colors.amber[500],
            child: const Center(child: Text('hi there')),
          ),
          RaisedButton(
            onPressed: () {
              print('hi');
            },
            child: Text('press me'),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Andy Index $_selectedIndex: School',
                style: optionStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
