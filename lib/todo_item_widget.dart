import 'package:flutter/material.dart';
import 'package:test_app_2/database_helper.dart';
import 'package:test_app_2/item_widget.dart';
import 'package:test_app_2/my_flutter_app_icons.dart';
import 'item_widget.dart';
import 'date_time_widget.dart';
import 'my_dropdown.dart';
import 'saved_vals.dart';
import 'dart:async';

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
          Flexible(child: Text('$title'), fit: FlexFit.tight),
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
            child: Text(
              "${DateTimeToString(due)}",
            ),
            flex: 6),
        Flexible(
            child: Text(
              typeName,
              textAlign: TextAlign.right,
            ),
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

class _BuildTileState extends State<BuildTile> {
  bool _expanded;
  int id;
  var instance;
  String whichIsInstance;
  StreamController controllerRef;
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
        decoration: BoxDecoration(
            border: Border.all(
              width: 10,
              color: widget.item.classColor == Colors.white
                  ? Colors.white10
                  : widget.item.classColor,
            ),
            borderRadius: BorderRadius.all(Radius.circular(7))),
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
              )),
          trailing: IconButton(
            icon: Icon(Icons.more_vert),
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
        thickness: 2,
        color: Theme.of(context).appBarTheme.color,
      ),
    ]);
  }

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

  Widget buildEditPage() {
    final _inputTextStyle = TextStyle(
        color: Theme.of(context).appBarTheme.color,
        fontWeight: FontWeight.bold,
        fontSize: 18.0);
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
                            style: _inputTextStyle,
                            controller: _myTextController)),
                    FlatButton(
                        child: Text("SAVE", style: _inputTextStyle),
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
                          item.classKey = widget.item.classKey;
                          item.typeKey = widget.item.typeKey;
                          await DatabaseMethods.editItem(instance, item);
                          controllerRef.add(ControllerNums.update);
                          Navigator.pop(context);
                        }))
                  ],
                )),
            Container(width: 400, height: 200, child: _myDateTimePicker),
            myPriorityDropdown,
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
  MyCheckbox({
    this.completed,
    this.controllerRefItems,
    this.controllerRefCompleted,
    this.item,
    this.index,
  });
  @override
  _MyCheckboxState createState() => _MyCheckboxState();
}

class _MyCheckboxState extends State<MyCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
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
    // TODO: implement buildTitle
    return Container(
        padding: EdgeInsets.all(6),
        color: color,
        child: Text(name,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)));
  }

  @override
  int getForeignKey() {
    return 0;
  }
}

class AssignTypeWidget extends ItemWidget {
  int id;
  String name;
  int classKey;

  AssignTypeWidget({this.id, this.name, this.classKey});

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return Container();
  }

  @override
  Widget buildSubtitle(BuildContext context) {
    // TODO: implement buildSubtitle
    return Text("subtitle, class key is $classKey");
  }

  @override
  Widget buildTitle(BuildContext context) {
    // TODO: implement buildTitle
    return Text(name);
  }

  @override
  int getForeignKey() {
    return classKey;
  }
}
