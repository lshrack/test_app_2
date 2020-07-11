import 'package:flutter/material.dart';
import 'package:test_app_2/saved_vals.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'todo_item_widget.dart';
import 'item_widget.dart';
import 'database_helper.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ClassesAndTypes extends StatefulWidget {
  final Stream<int> myStream;
  ClassesAndTypes({this.myStream});
  @override
  _ClassesAndTypesState createState() => _ClassesAndTypesState();
}

class _ClassesAndTypesState extends State<ClassesAndTypes> {
  bool type2 = true;
  StreamController<int> classController = StreamController();
  StreamSubscription mySubscription;
  final myTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(21.0),
        controller: ScrollController(),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                    child: Text("Add Class",
                        style: TextStyle(color: Colors.white)),
                    color: Theme.of(context).appBarTheme.color,
                    onPressed: () {
                      createAlertDialog(context).then((onValue) {
                        if (onValue != null) updateAddClass(onValue);
                      });
                    }),
              ],
            ),
            ClassView(stream: classController.stream),
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    setType2();
    mySubscription = widget.myStream.listen((int myNum) {
      if (myNum == ControllerNums.cClearAll) {
        clear();
      }
      if (int.parse(myNum.toString().substring(0, 1)) ==
          ControllerNums.cDeleteClass) {
        classController.add(myNum);
      }
    });
  }

  @override
  void dispose() {
    mySubscription.cancel();
    super.dispose();
  }

  createAlertDialog(BuildContext context) {
    final myPicker = ColorPicker();
    final _controller = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("New Class"),
                  IconButton(
                      icon: (Icon(Icons.close)),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      }),
                ]),
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Class Name",
                    suffixIcon: myPicker,
                  ))
            ]),
            actions: <Widget>[
              FlatButton(
                  child: Text("ADD"),
                  onPressed: () {
                    if (_controller.text != "") {
                      SchoolClass classToReturn = SchoolClass();
                      classToReturn.name = _controller.text;
                      classToReturn.color = myPicker.getColor();
                      Navigator.of(context, rootNavigator: true)
                          .pop(classToReturn);
                    } else
                      Navigator.of(context, rootNavigator: true).pop();
                  })
            ],
          );
        });
  }

  void clear() {
    classController.add(ControllerNums.cClearAll);
    if (this.mounted) setState(() {});
  }

  void updateAddClass(SchoolClass classToAdd) async {
    await DatabaseMethods.save(classToAdd, SchoolClassDatabaseHelper.instance);
    classController.add(ControllerNums.cAddClass);
    if (this.mounted) setState(() {});
  }

  void setType2() async {
    String fileContent = await readContent();
    if (fileContent == "true")
      type2 = true;
    else
      type2 = false;
    setState(() {});
  }

  Future<File> get _classModeFile async {
    final path = await getApplicationDocumentsDirectory();
    return File('$path/class_mode.txt');
  }

  Future<File> writeContent(String toWrite) async {
    final file = await _classModeFile;
    return file.writeAsString(toWrite);
  }

  Future<String> readContent() async {
    try {
      final file = await _classModeFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return 'Error';
    }
  }
}

class ClassView extends StatefulWidget {
  final bool type2;
  final Stream<int> stream;
  ClassView({this.type2 = false, this.stream});
  @override
  _ClassViewState createState() => _ClassViewState();
}

class _ClassViewState extends State<ClassView> {
  List<StreamController> typeControllers;
  DatabaseHelper classHelper = SchoolClassDatabaseHelper.instance;
  List<ItemWidget> classes = [];
  int itemCount = 0;
  GlobalKey<AnimatedListState> _listKey = GlobalKey();
  bool atInit;
  bool firstBuild;

  @override
  void initState() {
    super.initState();
    atInit = true;
    firstBuild = true;
    setClasses();
    widget.stream.listen((int myNum) async {
      print("class view got a val!");
      if (myNum == ControllerNums.cClearAll) {
        await clearClasses();
      }
      if (myNum == ControllerNums.cAddClass) {
        await updateAddClass();
      }
      if (int.parse(myNum.toString().substring(0, 1)) ==
          ControllerNums.cDeleteClass) {
        updateDeleteClass(int.parse(myNum.toString().substring(1)));
      }
    });
    typeControllers = [];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.all(10),
        key: _listKey,
        initialItemCount: itemCount,
        itemBuilder: (context, i, animation) {
          if (classes.length == 0) {
            return Container();
          }

          final index = i;

          if (index < classes.length) {
            try {
              final currClass = classes[index];
              return classBuilder(currClass, index);
            } catch (e) {
              return Container();
            }
          }

          return Container();
        });
  }

  Widget classBuilder(ItemWidget classToBuild, int index) {
    TextEditingController myController = new TextEditingController();
    print("index is $index");
    print("trying to return the listview!!!");
    if (firstBuild && typeControllers.length < classes.length) {
      print("adding type controller at ${typeControllers.length}");
      typeControllers.add(StreamController<int>.broadcast());
    }

    return (classToBuild as SchoolClassWidget)
        .buildTitle2(context, typeControllers[index], index);
    //return ClassBuilder(classToBuild, typeControllers[index]);
  }

  void updateDeleteClass(int index) {
    print("got index $index");
    _listKey.currentState.removeItem(index, (context, animation) {
      return Container();
    });

    setClasses();
  }

  Future<void> updateAddClass() async {
    _listKey.currentState.insertItem(classes.length);
    print("adding type controller at ${typeControllers.length}");
    typeControllers.add(StreamController<int>.broadcast());
    firstBuild = false;

    await setClasses();
  }

  Future<void> clearClasses() async {
    List<TodoItemWidget> classesWidgetType = [];

    for (int i = classes.length - 1; i >= 0; i--) {
      AnimatedListRemovedItemBuilder builder = (context, animation) {
        return classBuilder(classes[i], i);
      };

      try {
        _listKey.currentState.removeItem(i, builder);
      } catch (e) {}
    }
    setState(() {});

    //OK, so i admit this is probably a terrible work-around, but hey, it works, so
    await new Future.delayed(const Duration(milliseconds: 500));

    classes = classesWidgetType;

    setState(() {});
  }

  Future<void> setClasses() async {
    //await prestockDatabases();
    classes = await DatabaseMethods.readAllAsWidget(
        classHelper, DatabaseTypes.classDatabase);

    if (this.mounted)
      setState(() {
        if (atInit) {
          for (int i = 0; i < classes.length; i++) {
            _listKey.currentState.insertItem(i);
          }
          atInit = false;
        }
      });
  }
}

class TypeView extends StatefulWidget {
  final classKey;
  final Stream<int> myStream;
  final StreamController controllerRef;
  TypeView({this.classKey, this.myStream, this.controllerRef});
  @override
  _TypeViewState createState() => _TypeViewState();
}

class _TypeViewState extends State<TypeView> {
  DatabaseHelper typeHelper = AssignTypeDatabaseHelper.instance;
  List<ItemWidget> types = [];
  int itemCount = 0;
  GlobalKey<AnimatedListState> _listKey = GlobalKey();
  bool atInit;

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        key: _listKey,
        padding: EdgeInsets.all(10),
        initialItemCount: itemCount,
        itemBuilder: (context, i, animation) {
          if (types.length == 0) {
            return Container();
          }

          final index = i;
          if (index < types.length) {
            final currType = types[index];
            return (currType as AssignTypeWidget)
                .buildTitle2(context, widget.controllerRef, i);
          }

          return Container();
        });
  }

  @override
  void initState() {
    super.initState();
    atInit = true;
    setTypes();
    widget.myStream.listen((int myNum) async {
      print("got a val!");
      if (myNum == ControllerNums.cAddType) {
        _listKey.currentState.insertItem(types.length);
        await setTypes();
      } else if (int.parse(myNum.toString().substring(0, 1)) ==
          ControllerNums.cDeleteType) {
        if (myNum.toString().length > 1) {
          print("removing item");
          removeItem(int.parse(myNum.toString().substring(1)));
        }
      } else if (myNum == ControllerNums.cEditType) {
        await setTypes();
      } else if (myNum == ControllerNums.cDeleteClass) {
        for (int i = types.length - 1; i >= 0; i--) {
          await DatabaseMethods.deleteItem(
              types[i].id, AssignTypeDatabaseHelper.instance);

          _listKey.currentState.removeItem(i, ((context, animation) {
            return Container();
          }));
        }

        types = [];

        setState(() {});
      }
    });
  }

  void removeItem(int index) {
    _listKey.currentState.removeItem(index, ((context, animation) {
      return Container();
    }));
    types.removeAt(index);

    setState(() {});
  }

  Future<void> setTypes() async {
    List<ItemWidget> allTypes;
    allTypes = await DatabaseMethods.readAllAsWidget(
        typeHelper, DatabaseTypes.typeDatabase);

    types = [];
    for (int i = 0; i < allTypes.length; i++) {
      if (allTypes[i].getForeignKey() == widget.classKey) {
        types.add(allTypes[i]);
      }
    }
    if (this.mounted)
      setState(() {
        if (atInit) {
          for (int i = 0; i < types.length; i++) {
            _listKey.currentState.insertItem(i);
          }
          atInit = false;
        }
      });
  }
}

class ColorPicker extends StatefulWidget {
  final myState = _ColorPickerState();
  Color color = Color(0xfff44336);
  @override
  _ColorPickerState createState() {
    return myState;
  }

  void setColor() {
    color = Color(0xfff44336);
  }

  Color getColor() {
    if (color != null)
      return color;
    else
      return Colors.orange;
  }
}

class _ColorPickerState extends State<ColorPicker> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: IconButton(
            icon: Icon(Icons.palette, color: widget.color),
            onPressed: () {
              _openPicker(context, widget.color).then((onValue) {
                if (onValue != null) {
                  widget.color = onValue;
                  setState(() {});
                }
              });
            }));
  }

  _openPicker(BuildContext _context, Color initialColor) {
    Color pickerColor = initialColor;
    Color currentColor = initialColor;
    //NOTE: Red (first color on palette) is Color(0xfff44336)

    // ValueChanged<Color> callback
    void changeColor(Color color) {
      setState(() => pickerColor = color);
    }

    return showDialog(
      context: _context,
      child: AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: currentColor,
            onColorChanged: changeColor,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Got it'),
            onPressed: () {
              setState(() => currentColor = pickerColor);
              Navigator.of(context).pop(currentColor);
            },
          ),
        ],
      ),
    );
  }
}
