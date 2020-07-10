import 'package:flutter/material.dart';
import 'dart:async';

class ControllerNums {
  static int update = 0;
  static int updateAddItem = 1;
  static int deleteItem = 2;
  static int clearAll = 3;
  static int updateItem = 4;

  static int cClearAll = 0;
  static int cAddClass = 1;
  static int cDeleteClass = 2;
  static int cAddType = 3;
  static int cDeleteType = 4;

  static int dChangeVal = 0;
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
}
