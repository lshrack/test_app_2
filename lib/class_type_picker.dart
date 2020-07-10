import 'package:flutter/material.dart';
import 'my_dropdown.dart';
import 'database_helper.dart';
import 'my_flutter_app_icons.dart';
import 'dart:async';
import 'saved_vals.dart';

class ClassTypePicker extends StatefulWidget {
  _ClassTypePickerState myState = _ClassTypePickerState();

  @override
  _ClassTypePickerState createState() => myState;

  int getTypeKey() {
    return myState.getTypeKey();
  }

  int getClassKey() {
    return myState.getClassKey();
  }
}

class _ClassTypePickerState extends State<ClassTypePicker> {
  int classKey;
  int typeKey;
  List<Entry> classes;
  List<String> classStrings = ["none selected"];
  List<Color> classColors = [Colors.white];
  IconData icon = MyFlutterApp.circle;
  StreamController<int> controller = new StreamController();
  List<Entry> types;
  List<String> typeStrings = ["none selected"];
  List<Color> typeColors = [Colors.white];
  Stream<int> stream;
  String currClassPicked;
  String currTypePicked;
  bool showTypes;
  MyDropdown classDropdown;
  MyDropdown typeDropdown;

  @override
  void initState() {
    super.initState();
    getClasses();
    currClassPicked = classStrings[0];
    currTypePicked = typeStrings[0];
    showTypes = false;
    stream = controller.stream;

    stream.listen((int val) {
      if (val == ControllerNums.dChangeVal) {
        print("got val");
        if (classDropdown.getVal() == classStrings[0]) {
          print("back to 0");
          showTypes = false;
        } else {
          print('showing types');
          showTypes = true;
        }

        updateTypes();
      }
    });

    classDropdown = MyDropdown(
      classStrings,
      icon,
      classColors,
      currClassPicked,
      controller: controller,
    );

    typeDropdown = MyDropdown(
      typeStrings,
      icon,
      typeColors,
      currTypePicked,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        classDropdown,
        Offstage(child: typeDropdown, offstage: !showTypes)
      ],
    );
  }

  void getClasses() async {
    classes = await DatabaseMethods.readAll(SchoolClassDatabaseHelper.instance);

    for (int i = 0; i < classes.length; i++) {
      classStrings.add((classes[i] as SchoolClass).name);
      classColors.add((classes[i] as SchoolClass).color);
    }

    classDropdown = MyDropdown(
      classStrings,
      icon,
      classColors,
      currClassPicked,
      controller: controller,
    );

    setState(() {});
  }

  void updateTypes() async {
    String className = classDropdown.getVal();
    SchoolClass currClass = classes[0];
    String firstVal = typeStrings[0];
    typeStrings = [firstVal];

    types = await DatabaseMethods.readAll(AssignTypeDatabaseHelper.instance);

    for (int i = 1; i < classStrings.length; i++) {
      if (classStrings[i] == className) {
        currClass = classes[i - 1] as SchoolClass;
      }
    }

    for (int i = 0; i < types.length; i++) {
      if ((types[i] as AssignType).classKey == currClass.id) {
        typeStrings.add((types[i] as AssignType).name);
        typeColors.add(Colors.white);
      }
    }

    typeDropdown = MyDropdown(
      typeStrings,
      icon,
      typeColors,
      currTypePicked,
    );

    setState(() {});
  }

  int getTypeKey() {
    String currType = typeDropdown.getVal();
    for (int i = 0; i < types.length; i++) {
      if (currType == (types[i] as AssignType).name) {
        return types[i].id;
      }
    }

    return 0;
  }

  int getClassKey() {
    String currClass = classDropdown.getVal();
    for (int i = 0; i < classes.length; i++) {
      if (currClass == (classes[i] as SchoolClass).name) {
        return classes[i].id;
      }
    }

    return 0;
  }
}
