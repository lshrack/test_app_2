import 'package:flutter/material.dart';
import 'package:test_app_2/settings.dart';
import 'my_flutter_app_icons.dart';
import 'todo_page.dart';
import 'forest.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    ItemList itemList = ItemList(context);
    List<Widget> _appBars = [
      AppBar(),
      itemList.getAppBar(),
      SettingsThreePage().getAppBar()
    ];
    List<Widget> _bodies = [Forest().widget, itemList, SettingsThreePage()];
    List<Color> _colors = [
      Colors.white,
      itemList.getColor(),
      SettingsThreePage().getColor()
    ];
    return Scaffold(
      backgroundColor: _colors[_currentIndex],
      appBar: _appBars[_currentIndex],
      body: _bodies[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
                icon: new Icon(MyFlutterApp.pine_tree), title: Text('Forest')),
            BottomNavigationBarItem(
                icon: new Icon(Icons.list), title: Text('Planner')),
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
