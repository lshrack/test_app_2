import 'package:flutter/material.dart';
import 'home_widget.dart';
import 'saved_vals.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            scaffoldBackgroundColor: Col.ltblue,
            accentColor: Colors.orange,
            appBarTheme: AppBarTheme(color: Col.dkblue),
            buttonTheme: ButtonThemeData(
                buttonColor: Colors.blue, disabledColor: Colors.amber)),
        title: 'My Flutter App',
        home: Home());
  }
}
