import 'package:flutter/material.dart';
import 'my_flutter_app_icons.dart';
import 'todo_page.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  ItemList todoPage = ItemList();
  List<Widget> _appBars;
  List<Widget> _bodies;

  @override
  void initState() {
    super.initState();
    _bodies = [Container(), todoPage, Container()];
    _appBars = [AppBar(), todoPage.getAppBar(), AppBar()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBars[_currentIndex],
      body: _bodies[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
                icon: new Icon(MyFlutterApp.pine_tree), title: Text('Forest')),
            BottomNavigationBarItem(
                icon: new Icon(Icons.list), title: Text('Homework')),
            BottomNavigationBarItem(
                icon: new Icon(Icons.settings), title: Text("Settings"))
          ]),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
