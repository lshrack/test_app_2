import 'package:flutter/material.dart';
import 'dart:async';

class ControllerNums {
  //used for items
  static int update = 0;
  static int updateAddItem = 1;
  static int deleteItem = 2;
  static int clearAll = 3;
  static int updateItem = 4;

  //used for classes and types
  static int cClearAll = 0;
  static int cAddClass = 1;
  static int cDeleteClass = 2;
  static int cAddType = 3;
  static int cDeleteType = 4;
  static int cEditType = 5;
  static int cEditClass = 6;

  //used when class dropdown changes value, to know whether to drop type dropdown
  static int dChangeVal = 0;
  static int dSetVals = 1;
}

class Vals {
  static List<String> priorityDropdownStrings = [
    "No priority",
    "  Priority 1",
    "  Priority 2",
    "  Priority 3"
  ];
  static List<Color> priorityDropdownColors = [
    Colors.white,
    Colors.red,
    Colors.orange,
    Colors.yellow[600]
  ];

  static StreamController<int> classTypeController =
      StreamController<int>.broadcast();

  static TextStyle textStyle(BuildContext context,
      {var color = 0, double size = 18.0, bool bold = false}) {
    return TextStyle(
        //fontFamily: 'Gotham',
        color: color == 0 ? Theme.of(context).appBarTheme.color : color,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontSize: size);
  }
}

class DatabaseTypes {
  static int itemDatabase = 0;
  static int classDatabase = 1;
  static int typeDatabase = 2;
}

class Col {
  static Color ab(BuildContext context) {
    return Theme.of(context).appBarTheme.color;
  }

  static Color dkblue = Color(0xff142850);
  static Color blue = Color(0xff27496d);
  static Color teal = Color(0xff00909e);
  static Color ltblue = Color(0xffdae1e7);

/*
  static Color dkblue = Color(0xffeb6383);
  static Color blue = Color(0xfffa9191);
  static Color ltblue = Color(0xffffe9c5);
  static Color teal = Color(0xffb4f2e1);*/
}

class Sort {
  static int picked = 0;
  static List<String> buttons = ['Date', 'Class', 'Priority'];
  static List<bool> selected = [true, false, false];
  static setP(int inPicked) {
    for (int i = 0; i < selected.length; i++) {
      selected[i] = false;
      if (i == inPicked) {
        selected[i] = true;
      }
    }
  }
}
