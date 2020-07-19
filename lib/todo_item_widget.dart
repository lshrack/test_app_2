import 'package:flutter/material.dart';
import 'package:test_app_2/class_type_picker.dart';
import 'package:test_app_2/database_helper.dart';
import 'package:test_app_2/item_widget.dart';
import 'package:test_app_2/my_flutter_app_icons.dart';
import 'item_widget.dart';
import 'date_time_widget.dart';
import 'my_dropdown.dart';
import 'saved_vals.dart';
import 'dart:async';
import 'classes_and_types.dart';

//manages how items display, mainly
class TodoItemWidget extends ItemWidget {
  final int id;
  final String title;
  final DateTime due;
  final int priority;
  final int typeKey;
  final int classKey;
  final String className;
  final String typeName;
  final Color classColor;
  TodoItemWidget(
      {this.id,
      this.title,
      this.due,
      this.priority,
      this.typeKey,
      this.classKey,
      this.className,
      this.typeName,
      this.classColor});
  @override
  Widget buildTitle(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Flexible(
              child: Text('$title',
                  style: Vals.textStyle(context, size: 17, color: Col.ltblue)),
              fit: FlexFit.tight),
          priorityToWidget(priority),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  Widget buildSubtitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Flexible(
            child: Text("${DateTimeToString(due)}",
                style: Vals.textStyle(context, size: 14, color: Col.ltblue)),
            flex: 6),
        Flexible(
            child: Text(typeName,
                textAlign: TextAlign.right,
                style: Vals.textStyle(context, size: 14, color: Col.ltblue)),
            flex: 4),
      ],
    );
  }

  Widget buildLeading(BuildContext context) {
    return MyCheckbox();
  }

  int getForeignKey() {
    return typeKey;
  }
/*
  Widget buildTrailing(BuildContext context) {
    return IconButton(icon:Icon(Icons.more_vert,), onPressed: null);
  }*/

  void setComplete(bool checked) {
    //_checked = checked;
  }

  String DateTimeToString(DateTime dateTime) {
    String assemblage = "";
    if (dateTime.toString() == DateTime.utc(1990, 12, 6, 3, 1, 7).toString()) {
      return assemblage;
    }

    assemblage += "Due: ";

    if (dateTime.year == DateTime.now().year &&
        dateTime.month == DateTime.now().month &&
        dateTime.day == DateTime.now().day) {
      assemblage += "Today";
    } else if (dateTime.year == DateTime.now().add(Duration(days: 1)).year &&
        dateTime.month == DateTime.now().add(Duration(days: 1)).month &&
        dateTime.day == DateTime.now().add(Duration(days: 1)).day) {
      assemblage += "Tomorrow";
    } else if (dateTime.isBefore(DateTime.now().add(Duration(days: 7))) &&
        dateTime.weekday != DateTime.now().weekday) {
      switch (dateTime.weekday) {
        case DateTime.monday:
          assemblage += "Monday";
          break;
        case DateTime.tuesday:
          assemblage += "Tuesday";
          break;
        case DateTime.wednesday:
          assemblage += "Wednesday";
          break;
        case DateTime.thursday:
          assemblage += "Thursday";
          break;
        case DateTime.friday:
          assemblage += "Friday";
          break;
        case DateTime.saturday:
          assemblage += "Saturday";
          break;
        case DateTime.sunday:
          assemblage += "Sunday";
          break;
        default:
          break;
      }
    } else {
      switch (dateTime.month) {
        case DateTime.january:
          assemblage += "Jan";
          break;
        case DateTime.february:
          assemblage += "Feb";
          break;
        case DateTime.march:
          assemblage += "Mar";
          break;
        case DateTime.april:
          assemblage += "Apr";
          break;
        case DateTime.may:
          assemblage += "May";
          break;
        case DateTime.june:
          assemblage += "Jun";
          break;
        case DateTime.july:
          assemblage += "Jul";
          break;
        case DateTime.august:
          assemblage += "Aug";
          break;
        case DateTime.september:
          assemblage += "Sep";
          break;
        case DateTime.october:
          assemblage += "Oct";
          break;
        case DateTime.november:
          assemblage += "Nov";
          break;
        case DateTime.december:
          assemblage += "Dec";
          break;
      }
      assemblage += " ${dateTime.day}";
    }

    if (dateTime.second == 21) {
      return assemblage;
    }

    if (dateTime.hour > 12) {
      assemblage += ", ${dateTime.hour - 12}";
    } else if (dateTime.hour == 0) {
      assemblage += ", ${dateTime.hour + 12}";
    } else {
      assemblage += ", ${dateTime.hour}";
    }

    if (dateTime.minute > 9) {
      assemblage += ":${dateTime.minute}";
    } else if (dateTime.minute != 0) {
      assemblage += ":0${dateTime.minute}";
    }

    if (dateTime.hour >= 12) {
      assemblage += " PM";
    } else {
      assemblage += " AM";
    }

    return assemblage;
  }

  Widget priorityToWidget(int priority) {
    if (priority == 0) return Container();
    Color color;
    if (priority == 1)
      color = Vals.priorityDropdownColors[1];
    else if (priority == 2)
      color = Vals.priorityDropdownColors[2];
    else
      color = Vals.priorityDropdownColors[3];

    return Icon(MyFlutterApp.exclamation_circle, color: color, size: 16.0);
  }
}

//Builds list tiles for items in the list
class BuildTile extends StatefulWidget {
  final TodoItemWidget item;
  final controllerRefItem;
  final controllerRefCompleted;
  final int index;
  bool completed;
  BuildTile(
      {this.item,
      this.controllerRefItem,
      this.controllerRefCompleted,
      this.index,
      this.completed});
  @override
  _BuildTileState createState() => _BuildTileState();
}

//manages state when building items in list
class _BuildTileState extends State<BuildTile> {
  bool _expanded;
  int id;
  var instance;
  String whichIsInstance;
  StreamController controllerRef;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Col.blue,
        child: Column(children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 5),
              title: widget.item.buildTitle(context),
              subtitle: widget.item.buildSubtitle(context),
              leading: Container(
                  width: 50,
                  height: 50,
                  child: MyCheckbox(
                      completed: widget.completed,
                      controllerRefItems: widget.controllerRefItem,
                      controllerRefCompleted: widget.controllerRefCompleted,
                      item: widget.item,
                      index: widget.index,
                      color: widget.item.classColor)),
              trailing: IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Col.ltblue,
                ),
                onPressed: () {
                  setState(() {
                    if (_expanded)
                      _expanded = false;
                    else
                      _expanded = true;
                  });
                },
              ),
            ),
          ),
          ifExpanded(_expanded),
          Divider(
            thickness: 10,
            height: 10,
            color: Col.ltblue,
          ),
        ]));
  }

  //displays extra section when more button is pressed
  Widget ifExpanded(bool _show) {
    if (!_show) {
      return Container();
    }

    return Container(
        height: 35,
        child: Row(
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  id = widget.item.id;
                  print("Going to delete item at id $id");
                  print("Our instance is $whichIsInstance");
                  _expanded = false;
                  await DatabaseMethods.deleteItem(id, instance);
                  controllerRef.add(int.parse('2${widget.index}'));
                }),
            IconButton(icon: Icon(Icons.edit), onPressed: _editItem)
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ));
  }

  @override
  void initState() {
    super.initState();
    _expanded = false;
    id = widget.item.id;
    getClassType();
    if (widget.completed) {
      controllerRef = widget.controllerRefCompleted;
      instance = CompletedItemDatabaseHelper.instance;
      whichIsInstance = "controller";
    } else {
      controllerRef = widget.controllerRefItem;
      instance = ItemDatabaseHelper.instance;
      whichIsInstance = "item";
    }
  }

  void getClassType() async {
    print("gonna rerun setstate now");

    setState(() {});
  }

  void _editItem() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Item'),
        ),
        body: buildEditPage(),
        resizeToAvoidBottomPadding: false,
      );
    }));
  }

  //builds page for when you want to edit an item
  Widget buildEditPage() {
    final TextEditingController _myTextController =
        TextEditingController(text: widget.item.title);
    final _myDateTimePicker = DateTimeWidget(
      inDateTime: widget.item.due,
    );

    final myPriorityDropdown = MyDropdown(
        Vals.priorityDropdownStrings,
        MyFlutterApp.exclamation_circle,
        Vals.priorityDropdownColors,
        Vals.priorityDropdownStrings[widget.item.priority]);

    final myClassTypePicker = ClassTypePicker(
        classKeyInput: widget.item.classKey, typeKeyInput: widget.item.typeKey);

    return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        width: 200,
                        height: 40,
                        child: TextField(
                            style: Vals.textStyle(context),
                            controller: _myTextController)),
                    FlatButton(
                        child: Text("SAVE", style: Vals.textStyle(context)),
                        onPressed: (() async {
                          id = widget.item.id;
                          Item item = new Item();
                          item.id = id;
                          item.name = _myTextController.text;
                          item.due = _myDateTimePicker.getDateTime();
                          if (myPriorityDropdown.getVal() ==
                              Vals.priorityDropdownStrings[0])
                            item.priority = 0;
                          if (myPriorityDropdown.getVal() ==
                              Vals.priorityDropdownStrings[1])
                            item.priority = 1;
                          if (myPriorityDropdown.getVal() ==
                              Vals.priorityDropdownStrings[2])
                            item.priority = 2;
                          if (myPriorityDropdown.getVal() ==
                              Vals.priorityDropdownStrings[3])
                            item.priority = 3;
                          item.classKey = myClassTypePicker.getClassKey();
                          item.typeKey = myClassTypePicker.getTypeKey();
                          await DatabaseMethods.editItem(instance, item);
                          controllerRef.add(ControllerNums.update);
                          Navigator.pop(context);
                        }))
                  ],
                )),
            Container(width: 400, height: 200, child: _myDateTimePicker),
            myPriorityDropdown,
            myClassTypePicker,
          ],
        ));
  }
}

class MyCheckbox extends StatefulWidget {
  bool completed;
  final controllerRefItems;
  final controllerRefCompleted;
  final TodoItemWidget item;
  final int index;
  final Color color;
  MyCheckbox(
      {this.completed,
      this.controllerRefItems,
      this.controllerRefCompleted,
      this.item,
      this.index,
      this.color});
  @override
  _MyCheckboxState createState() => _MyCheckboxState();
}

//manages state for item checkboxes and how items move between completed and uncompleted lists
class _MyCheckboxState extends State<MyCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
        activeColor: widget.color != null ? widget.color : Col.teal,
        checkColor: Col.ltblue,
        value: widget.completed,
        onChanged: (newVal) async {
          if (!widget.completed) {
            Item itemToSave = Item();
            itemToSave.name = widget.item.title;
            itemToSave.due = widget.item.due;
            itemToSave.priority = widget.item.priority;
            itemToSave.typeKey = widget.item.typeKey;
            itemToSave.classKey = widget.item.classKey;
            await DatabaseMethods.deleteItem(
                widget.item.id, ItemDatabaseHelper.instance);
            await DatabaseMethods.save(
                itemToSave, CompletedItemDatabaseHelper.instance);
            widget.completed = true;
            widget.controllerRefItems
                .add(int.parse('${ControllerNums.deleteItem}${widget.index}'));
            widget.controllerRefCompleted.add(ControllerNums.updateAddItem);
          } else {
            Item itemToSave = Item();
            itemToSave.name = widget.item.title;
            itemToSave.due = widget.item.due;
            itemToSave.priority = widget.item.priority;
            itemToSave.typeKey = widget.item.typeKey;
            itemToSave.classKey = widget.item.classKey;
            await DatabaseMethods.deleteItem(
                widget.item.id, CompletedItemDatabaseHelper.instance);
            await DatabaseMethods.save(itemToSave, ItemDatabaseHelper.instance);
            widget.completed = false;
            widget.controllerRefCompleted
                .add(int.parse('${ControllerNums.deleteItem}${widget.index}'));
            widget.controllerRefItems.add(ControllerNums.updateAddItem);
          }
          setState(() {});
        });
  }
}

//manages widgets for classes
class SchoolClassWidget extends ItemWidget {
  static const defaultColor = Colors.blueGrey;
  int id;
  String name;
  Color color;

  SchoolClassWidget({this.id, this.name, this.color = defaultColor});

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return Container();
  }

  @override
  Widget buildSubtitle(BuildContext context) {
    // TODO: implement buildSubtitle
    return Text("subtitle");
  }

  @override
  Widget buildTitle(BuildContext context) {
    return SchoolClassTitle(this);
  }

  Widget buildTitle2(
      BuildContext context, StreamController controller, int index) {
    return SchoolClassTitle(this, controller: controller, index: index);
  }

  @override
  int getForeignKey() {
    return 0;
  }
}

//Builds each class in list, basically (also builds types underneath, technically)
class SchoolClassTitle extends StatefulWidget {
  final SchoolClassWidget parent;
  final StreamController controller;
  final int index;
  SchoolClassTitle(this.parent, {this.controller, this.index});
  @override
  _SchoolClassTitleState createState() => _SchoolClassTitleState();
}

class _SchoolClassTitleState extends State<SchoolClassTitle> {
  bool _expanded = false;
  IconData dropdownArrow = Icons.arrow_drop_down;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: widget.parent.color),
            //color: widget.parent.color,
            child: Column(children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(widget.parent.name,
                        style: Vals.textStyle(
                          context,
                          color: Colors.white,
                          size: 16,
                        )),
                    GestureDetector(
                        child: Icon(dropdownArrow, color: Colors.white),
                        onTap: () {
                          _expanded = !_expanded;
                          if (dropdownArrow == Icons.arrow_drop_down)
                            dropdownArrow = Icons.arrow_drop_up;
                          else
                            dropdownArrow = Icons.arrow_drop_down;
                          setState(() {});
                        })
                  ]),
              _expanded
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: GestureDetector(
                              child: Icon(Icons.edit, color: Colors.white),
                              onTap: (() {
                                editClassDialog(context, widget.parent.name,
                                        widget.parent.color)
                                    .then((onValue) {
                                  onValue.id = widget.parent.id;
                                  if (onValue != null) {
                                    DatabaseMethods.editItem(
                                        SchoolClassDatabaseHelper.instance,
                                        onValue);
                                    Vals.classTypeController
                                        .add(ControllerNums.cEditClass);
                                  }
                                });
                              })),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10, right: 10, bottom: 5, top: 10),
                          child: GestureDetector(
                              child: Icon(Icons.delete, color: Colors.white),
                              onTap: () {
                                DatabaseMethods.deleteItem(widget.parent.id,
                                    SchoolClassDatabaseHelper.instance);
                                widget.controller
                                    .add(ControllerNums.cDeleteClass);
                                Vals.classTypeController.add(int.parse(
                                    "${ControllerNums.cDeleteClass}${widget.index}"));
                              }),
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: GestureDetector(
                                child: Icon(Icons.add_circle_outline,
                                    color: Colors.white),
                                onTap: () async {
                                  addTypeDialog(context).then((onValue) async {
                                    AssignType typeToAdd = AssignType();
                                    typeToAdd.name = onValue;
                                    typeToAdd.classKey = widget.parent.id;
                                    await DatabaseMethods.save(typeToAdd,
                                        AssignTypeDatabaseHelper.instance);

                                    widget.controller
                                        .add(ControllerNums.cAddType);
                                  });
                                })),
                      ],
                    )
                  : Container()
            ])),
        _expanded
            ? TypeView(
                classKey: widget.parent.id,
                myStream: widget.controller.stream,
                controllerRef: widget.controller,
              )
            : Container(height: 20),
      ],
      shrinkWrap: true,
    );
  }
}

//manages widgets for types
class AssignTypeWidget extends ItemWidget {
  int id;
  String name;
  int classKey;
  Color parentClassColor;
  bool expanded = false;

  AssignTypeWidget({this.id, this.name, this.classKey, this.parentClassColor});

  @override
  Widget buildLeading(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSubtitle(BuildContext context) {
    return Text("subtitle, class key is $classKey");
  }

  @override
  Widget buildTitle(BuildContext context) {
    return AssignTypeTitle(this);
  }

  Widget buildTitle2(
      BuildContext context, StreamController controller, int index) {
    return AssignTypeTitle(this, controller: controller, index: index);
  }

  @override
  int getForeignKey() {
    return classKey;
  }
}

class AssignTypeTitle extends StatefulWidget {
  final AssignTypeWidget parent;
  final StreamController controller;
  final int index;
  AssignTypeTitle(this.parent, {this.controller, this.index});
  @override
  _AssignTypeTitleState createState() => _AssignTypeTitleState();
}

class _AssignTypeTitleState extends State<AssignTypeTitle> {
  bool _expanded;
  @override
  void initState() {
    super.initState();
    _expanded = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Text(
                  widget.parent.name,
                  style: Vals.textStyle(context, color: Colors.black, size: 15),
                ),
              ),
              GestureDetector(
                  child: Icon(Icons.more_vert),
                  onTap: (() {
                    _expanded = !_expanded;
                    setState(() {});
                  }))
            ]),
        _expanded
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    child: GestureDetector(
                        child: Icon(Icons.delete),
                        onTap: () {
                          DatabaseMethods.deleteItem(widget.parent.id,
                              AssignTypeDatabaseHelper.instance);
                          widget.controller.add(int.parse(
                              "${ControllerNums.cDeleteType}${widget.index}"));
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    child: GestureDetector(
                        child: Icon(Icons.edit),
                        onTap: () {
                          _expanded = false;
                          editTypeDialog(context, widget.parent.name)
                              .then((onValue) {
                            AssignType newType = AssignType();
                            newType.name = onValue;
                            newType.classKey = widget.parent.classKey;
                            newType.id = widget.parent.id;

                            DatabaseMethods.editItem(
                                AssignTypeDatabaseHelper.instance, newType);

                            widget.controller.add(ControllerNums.cEditType);
                          });
                        }),
                  ),
                ],
              )
            : Container(),
        Divider(thickness: 1.5, color: widget.parent.parentClassColor)
      ],
    );
  }
}

editTypeDialog(BuildContext context, String text) {
  final _controller = TextEditingController();
  _controller.text = text;
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Edit Type"),
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
                  hintText: "Type Name",
                ))
          ]),
          actions: <Widget>[
            FlatButton(
                child: Text("SAVE"),
                onPressed: () {
                  if (_controller.text != "" && _controller.text != text) {
                    Navigator.of(context, rootNavigator: true)
                        .pop(_controller.text);
                  } else
                    Navigator.of(context, rootNavigator: true).pop(text);
                })
          ],
        );
      });
}

addTypeDialog(BuildContext context) {
  final _controller = TextEditingController();

  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Add Type"),
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
                  hintText: "Type Name",
                ))
          ]),
          actions: <Widget>[
            FlatButton(
                child: Text("ADD"),
                onPressed: () {
                  if (_controller.text != "") {
                    Navigator.of(context, rootNavigator: true)
                        .pop(_controller.text);
                  } else
                    Navigator.of(context, rootNavigator: true).pop();
                })
          ],
        );
      });
}

editClassDialog(BuildContext context, String text, Color color) {
  final _controller = TextEditingController();
  ColorPicker myPicker = ColorPicker();
  myPicker.setColor(color);
  _controller.text = text;
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Edit Class"),
                IconButton(
                    icon: (Icon(Icons.close)),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    }),
              ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            //add color picker here
            TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Class Name",
                  suffixIcon: myPicker,
                ))
          ]),
          actions: <Widget>[
            FlatButton(
                child: Text("SAVE"),
                onPressed: () {
                  //also check if color is the same
                  if (_controller.text != "" &&
                      (_controller.text != text || myPicker.color != color)) {
                    print('determined to have changed, popping with value');
                    SchoolClass editedClass = SchoolClass();
                    editedClass.name = _controller.text;
                    editedClass.color = myPicker.getColor();
                    Navigator.of(context, rootNavigator: true).pop(editedClass);
                  } else {
                    print('determined to be the same, popping without value');
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                })
          ],
        );
      });
}
