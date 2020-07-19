import 'package:flutter/material.dart';
import 'my_dropdown.dart';
import 'database_helper.dart';
import 'my_flutter_app_icons.dart';
import 'dart:async';
import 'saved_vals.dart';

//class for class and type pickers
class ClassTypePicker extends StatefulWidget {
  final int classKeyInput;
  final int typeKeyInput;

  ClassTypePicker({this.classKeyInput = 0, this.typeKeyInput = 0});

  final _ClassTypePickerState myState = _ClassTypePickerState();

  @override
  _ClassTypePickerState createState() => myState;

  int getTypeKey() {
    return myState.getTypeKey();
  }

  int getClassKey() {
    return myState.getClassKey();
  }
}

//manages state for class and type pickers (two dropdown menus)
class _ClassTypePickerState extends State<ClassTypePicker> {
  int classKey;
  int typeKey;
  List<Entry> classes = [];
  List<String> classStrings = ["none selected"];
  List<Color> classColors = [Colors.white];
  IconData icon = MyFlutterApp.circle;
  StreamController<int> controller;
  List<Entry> types = [];
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
    controller = new StreamController();
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

  //gets the list of classes from the database, builds the dropdown, and sets state
  void getClasses() async {
    classes = await DatabaseMethods.readAll(SchoolClassDatabaseHelper.instance);

    for (int i = 0; i < classes.length; i++) {
      classStrings.add((classes[i] as SchoolClass).name);
      classColors.add((classes[i] as SchoolClass).color);
    }

    setClass();
    print("having set class, currClassPicked is $currClassPicked");
    if (currClassPicked != classStrings[0]) {
      await updateTypes(shouldSetType: true);
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

  //gets the list of types from the database, figures out what class is picked,
  //figures out what types are in that class, builds dropdown, and sets state
  Future<void> updateTypes({bool shouldSetType = false}) async {
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

    if (shouldSetType) {
      setType();
    }

    if (!typeStrings.contains(currTypePicked)) {
      currTypePicked = typeStrings[0];
    }

    typeDropdown = MyDropdown(
      typeStrings,
      icon,
      typeColors,
      currTypePicked,
    );

    setState(() {});
  }

  //figures out what type has been selected from the types dropdown
  int getTypeKey() {
    String currType = typeDropdown.getVal();
    for (int i = 0; i < types.length; i++) {
      if (currType == (types[i] as AssignType).name) {
        return types[i].id;
      }
    }

    return 0;
  }

  //figures out what class has been selected from the classes dropdown
  int getClassKey() {
    String currClass = classDropdown.getVal();
    for (int i = 0; i < classes.length; i++) {
      if (currClass == (classes[i] as SchoolClass).name) {
        return classes[i].id;
      }
    }

    return 0;
  }

  void setClass() {
    if (widget.classKeyInput != 0) {
      print("going through to check class keys");
      for (int i = 0; i < classes.length; i++) {
        print("${classes[i].id}");
        if (widget.classKeyInput == classes[i].id) {
          currClassPicked = (classes[i] as SchoolClass).name;
          showTypes = true;
        }
      }
    }
  }

  void setType() {
    if (widget.typeKeyInput != 0) {
      print("going to go through list, types.length = ${types.length}");
      for (int i = 0; i < types.length; i++) {
        if (widget.typeKeyInput == types[i].id) {
          String name = (types[i] as AssignType).name;
          if (typeStrings.contains(name)) {
            currTypePicked = name;
            print("currTypePicked set to $currTypePicked");
          }
        }
        print("Looping");
      }
    }
  }
}
