import 'package:flutter/material.dart';

class MyTheme extends StatefulWidget {
  ThemeData myTheme = ThemeData(
    primaryColor: Colors.blue,
    buttonColor: Colors.grey,
  );

  @override
  _MyThemeState createState() => _MyThemeState();
}

class _MyThemeState extends State<MyTheme> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
