//test_app_2 by Lauren Shrack
//Priority 1 here will be implementing a to-do list view,
//similar to the one previously implemented in Android Studio
import 'package:flutter/material.dart';
import 'package:test_app_2/classes_and_types.dart';
import 'item_widget.dart';
import 'todo_item_widget.dart';
import 'date_time_widget.dart';
import 'database_helper.dart';
import 'dart:async';
import 'my_flutter_app_icons.dart';
import 'my_dropdown.dart';
import 'saved_vals.dart';
import 'class_type_picker.dart';

class TodoPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: Col.ltblue,
          accentColor: Colors.orange,
          appBarTheme: AppBarTheme(color: Col.dkblue),
          buttonTheme: ButtonThemeData(
              buttonColor: Colors.blue, disabledColor: Colors.amber)),
      title: 'To-Do List',
      home: ItemList(),
    );
  }
}

class ItemList extends StatefulWidget {
  _ItemListState myState = _ItemListState();

  @override
  _ItemListState createState() => myState;

  Widget getAppBar() {
    return myState.buildAppBar();
  }
}

class _ItemListState extends State<ItemList> {
  StreamController<int> itemController = StreamController();
  StreamController<int> completedController = StreamController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final itemDbInstance = ItemDatabaseHelper.instance;
  final completedItemDbInstance = CompletedItemDatabaseHelper.instance;

  Widget buildAppBar() {
    return AppBar(
      title: Text(
        'To-Do List',
        style: Vals.textStyle(context, size: 20, color: Col.ltblue),
      ),
      actions: [
        IconButton(
            icon: Icon(Icons.settings, color: Col.ltblue), onPressed: manage),
        IconButton(
            icon: Icon(Icons.delete, color: Col.ltblue), onPressed: clearAll),
        IconButton(
            icon: Icon(
              Icons.add,
              color: Col.ltblue,
            ),
            onPressed: _addItem,
            iconSize: 40)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Col.ltblue,
      child: BuildLists(
        controllerRefItems: itemController,
        controllerRefCompleted: completedController,
      ),
    );
  }

  void manage() async {
    List<ItemWidget> classes = await DatabaseMethods.readAllAsWidget(
        SchoolClassDatabaseHelper.instance, DatabaseTypes.classDatabase);
    List<ItemWidget> types = await DatabaseMethods.readAllAsWidget(
        AssignTypeDatabaseHelper.instance, DatabaseTypes.typeDatabase);
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        //backgroundColor: Col.blue,
        appBar: AppBar(
          title: Text('Manage Classes',
              style: Vals.textStyle(context, color: Col.ltblue, size: 20)),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: (() async {
                  await DatabaseMethods.clearAll(
                      SchoolClassDatabaseHelper.instance);
                  await DatabaseMethods.clearAll(
                      AssignTypeDatabaseHelper.instance);
                  Vals.classTypeController.add(ControllerNums.cClearAll);
                })),
          ],
        ),
        body: ClassesAndTypes(
          myStream: Vals.classTypeController.stream,
        ),
        resizeToAvoidBottomPadding: false,
      );
    }));
  }

  void _addItem() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Add Item'),
        ),
        body: buildAddPage(),
        resizeToAvoidBottomPadding: false,
      );
    }));
  }

  Widget buildAddPage() {
    final myTextController = TextEditingController();
    final myDateTimePicker = DateTimeWidget();
    final myPriorityDropdown = MyDropdown(
        Vals.priorityDropdownStrings,
        MyFlutterApp.exclamation_circle,
        Vals.priorityDropdownColors,
        Vals.priorityDropdownStrings[0]);

    final myClassTypePicker = ClassTypePicker();

    String _selected;
    @override
    void initState() {
      super.initState();
      _selected = "No priority";
    }

    return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 200,
                    height: 40,
                    child: TextField(
                      style: Vals.textStyle(context),
                      decoration: InputDecoration(
                          hintText: "Item Name",
                          hintStyle: TextStyle(color: Colors.grey)),
                      controller: myTextController,
                    ),
                  ),
                  FlatButton(
                      child: Text('ADD', style: Vals.textStyle(context)),
                      onPressed: () {
                        Item item = new Item();
                        item.name = myTextController.text;
                        item.due = myDateTimePicker.getDateTime();
                        item.priority = 0;
                        item.typeKey = myClassTypePicker.getTypeKey();
                        print("saved the type key as ${item.typeKey}");
                        item.classKey = myClassTypePicker.getClassKey();
                        print("saved the class key as ${item.classKey}");

                        if (myPriorityDropdown.getVal() ==
                            Vals.priorityDropdownStrings[1]) item.priority = 1;
                        if (myPriorityDropdown.getVal() ==
                            Vals.priorityDropdownStrings[2]) item.priority = 2;
                        if (myPriorityDropdown.getVal() ==
                            Vals.priorityDropdownStrings[3]) item.priority = 3;

                        _insertItem(item);
                        Navigator.pop(context);
                      })
                ],
              ),
            ),
            Container(width: 400, height: 200, child: myDateTimePicker),
            myPriorityDropdown,
            myClassTypePicker,
          ],
        ));
  }

  void _insertItem(Item newItem) {
    DatabaseMethods.save(newItem, itemDbInstance);
    DatabaseMethods.readAll(itemDbInstance);
    itemController.add(ControllerNums.updateAddItem);
  }

  void clearAll() async {
    await DatabaseMethods.clearAll(itemDbInstance);
    await DatabaseMethods.clearAll(completedItemDbInstance);
    itemController.add(ControllerNums.clearAll);
    completedController.add(ControllerNums.clearAll);
  }
}

class MyAnimatedList extends StatefulWidget {
  final Stream<int> stream;
  final controllerRefItem;
  final controllerRefCompleted;
  final dbInstance;
  final bool completed;
  MyAnimatedList(
      {this.stream,
      this.controllerRefItem,
      this.controllerRefCompleted,
      this.dbInstance,
      this.completed});

  @override
  _MyAnimatedListState createState() => _MyAnimatedListState();
}

class _MyAnimatedListState extends State<MyAnimatedList> {
  StreamController controllerRef;
  GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<ItemWidget> items = [];
  bool atInit;
  int itemCount = 0;

  @override
  Widget build(BuildContext context) {
    print("Building. completed is ${widget.completed}");
    print("my initial item count is $itemCount");
    return AnimatedList(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      key: _listKey,
      padding: EdgeInsets.all(10),
      initialItemCount: itemCount,
      itemBuilder: (context, i, animation) {
        if (items.length == 0) {
          return Container();
        }

        final index = i;
        if (index < items.length) {
          final item = items[index];
          return BuildTile(
              item: item,
              controllerRefItem: widget.controllerRefItem,
              controllerRefCompleted: widget.controllerRefCompleted,
              index: index,
              completed: widget.completed);
        }

        return Container();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    atInit = true;
    if (widget.completed)
      controllerRef = widget.controllerRefCompleted;
    else
      controllerRef = widget.controllerRefItem;

    widget.stream.listen((int val) {
      if (val == ControllerNums.update) {
        _update();
      } else if (val == ControllerNums.updateAddItem) {
        _updateAddItem();
      } else if (val == ControllerNums.clearAll) {
        _updateClearAll();
      } else if (int.parse(val.toString().substring(0, 1)) ==
          ControllerNums.deleteItem) {
        _updateDeleteItem(int.parse(val.toString().substring(1)));
      }
    });
  }

  void _update() async {
    print("Updating. completed is ${widget.completed}");
    List<ItemWidget> itemsWidgetType = await DatabaseMethods.readAllAsWidget(
        widget.dbInstance, DatabaseTypes.itemDatabase);
    setState(() {
      items = itemsWidgetType;
      sortItems();
    });

    if (atInit) {
      for (int i = 0; i < items.length; i++) {
        _listKey.currentState.insertItem(i);
      }
      atInit = false;
    }

    _listKey.currentState.build(context);
  }

  void _updateAddItem() async {
    List<ItemWidget> itemsWidgetType = await DatabaseMethods.readAllAsWidget(
        widget.dbInstance, DatabaseTypes.itemDatabase);
    setState(() {
      items = itemsWidgetType;
      sortItems();
    });

    _listKey.currentState.insertItem(items.length - 1);
  }

  void _updateDeleteItem(int index) async {
    List<ItemWidget> itemsWidgetType = await DatabaseMethods.readAllAsWidget(
        widget.dbInstance, DatabaseTypes.itemDatabase);

    ItemWidget removedItem = items.removeAt(index);
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return BuildTile(
          item: removedItem,
          controllerRefItem: widget.controllerRefItem,
          controllerRefCompleted: widget.controllerRefCompleted,
          index: index,
          completed: widget.completed);
    };
    _listKey.currentState.removeItem(index, builder);

    setState(() {
      items = itemsWidgetType;
      sortItems();
    });
  }

  void _updateClearAll() {
    List<TodoItemWidget> itemsWidgetType = [];

    final length = items.length;
    for (int i = length - 1; i >= 0; i--) {
      ItemWidget removedItem = items.removeAt(i);
      AnimatedListRemovedItemBuilder builder = (context, animation) {
        return BuildTile(
            item: removedItem,
            controllerRefItem: widget.controllerRefItem,
            controllerRefCompleted: widget.controllerRefCompleted,
            index: i,
            completed: widget.completed);
      };
      _listKey.currentState.removeItem(i, builder);
    }

    setState(() {
      items = itemsWidgetType;
    });
  }

  Future<void> sortItems() async {
    if (Sort.selected[0] == true) {
      items.sort((a, b) {
        final aT = a as TodoItemWidget;
        final bT = b as TodoItemWidget;
        if (compareByDate(aT, bT) != 0) return compareByDate(aT, bT);
        if (compareByPriority(aT, bT) != 0) return compareByPriority(aT, bT);
        if (compareByClass(aT, bT) != 0) return compareByClass(aT, bT);
        return compareByType(aT, bT);
      });
    }

    if (Sort.selected[1] == true) {
      items.sort((a, b) {
        final aT = a as TodoItemWidget;
        final bT = b as TodoItemWidget;
        if (compareByClass(aT, bT) != 0) return compareByClass(aT, bT);
        if (compareByPriority(aT, bT) != 0) return compareByPriority(aT, bT);
        if (compareByDate(aT, bT) != 0) return compareByDate(aT, bT);
        return compareByType(aT, bT);
      });
    }

    if (Sort.selected[2] == true) {
      items.sort((a, b) {
        final aT = a as TodoItemWidget;
        final bT = b as TodoItemWidget;
        if (compareByPriority(aT, bT) != 0) return compareByPriority(aT, bT);
        if (compareByDate(aT, bT) != 0) return compareByDate(aT, bT);
        if (compareByClass(aT, bT) != 0) return compareByClass(aT, bT);
        return compareByType(aT, bT);
      });
    }
  }

  int compareByDate(TodoItemWidget a, TodoItemWidget b) {
    DateTime aDue = a.due;
    DateTime bDue = b.due;

    if (aDue.toString() == DateTime.utc(1990, 12, 6, 3, 1, 7).toString())
      aDue = DateTime.utc(2200);

    if (bDue.toString() == DateTime.utc(1990, 12, 6, 3, 1, 7).toString())
      bDue = DateTime.utc(2200);
    return aDue.compareTo(bDue);
  }

  int compareByPriority(TodoItemWidget a, TodoItemWidget b) {
    int aPriority = a.priority;
    int bPriority = b.priority;

    if (aPriority == 0) aPriority = 10;
    if (bPriority == 0) bPriority = 10;
    return aPriority.compareTo(bPriority);
  }

  int compareByClass(TodoItemWidget a, TodoItemWidget b) {
    int aClass = a.classKey;
    int bClass = b.classKey;

    if (aClass == 0) aClass = 1000;
    if (bClass == 0) bClass = 1000;

    return aClass.compareTo(bClass);
  }

  int compareByType(TodoItemWidget a, TodoItemWidget b) {
    int aType = a.typeKey;
    int bType = b.typeKey;

    if (aType == 0) aType = 1000;
    if (bType == 0) bType = 1000;

    return aType.compareTo(bType);
  }
}

class BuildLists extends StatefulWidget {
  final controllerRefItems;
  final controllerRefCompleted;

  BuildLists({this.controllerRefItems, this.controllerRefCompleted});
  @override
  _BuildListsState createState() => _BuildListsState();
}

class _BuildListsState extends State<BuildLists> {
  bool showCompleted;

  @override
  void initState() {
    showCompleted = false;
  }

  @override
  Widget build(BuildContext context) {
    MyAnimatedList myItemList = MyAnimatedList(
        stream: widget.controllerRefItems.stream,
        controllerRefItem: widget.controllerRefItems,
        controllerRefCompleted: widget.controllerRefCompleted,
        dbInstance: ItemDatabaseHelper.instance,
        completed: false);
    MyAnimatedList myCompletedList = MyAnimatedList(
        stream: widget.controllerRefCompleted.stream,
        controllerRefItem: widget.controllerRefItems,
        controllerRefCompleted: widget.controllerRefCompleted,
        dbInstance: CompletedItemDatabaseHelper.instance,
        completed: true);

    widget.controllerRefItems.add(ControllerNums.update);
    widget.controllerRefCompleted.add(ControllerNums.update);

    return SingleChildScrollView(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      //controller: _controller,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Container(
            decoration: BoxDecoration(color: Col.teal),
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text("SORT BY: ",
                      style: Vals.textStyle(context, color: Col.ltblue)),
                  Expanded(
                    child: Container(
                      child: LayoutBuilder(builder: (context, constraints) {
                        return ToggleButtons(
                          renderBorder: false,
                          constraints: BoxConstraints.expand(
                            width: constraints.maxWidth / 3,
                          ),
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(Sort.buttons[0],
                                  style: Vals.textStyle(context,
                                      color: Col.ltblue)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(Sort.buttons[1],
                                  style: Vals.textStyle(context,
                                      color: Col.ltblue)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(Sort.buttons[2],
                                  style: Vals.textStyle(context,
                                      color: Col.ltblue)),
                            ),
                          ],
                          isSelected: Sort.selected,
                          fillColor: Col.dkblue,
                          onPressed: (int val) {
                            Sort.setP(val);
                            setState(() {});
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        myItemList,
        Container(
          color: Col.dkblue,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Completed Items",
                  style: Vals.textStyle(context, color: Col.ltblue)),
              Switch(
                activeColor: Col.teal,
                inactiveTrackColor: Col.ltblue,
                activeTrackColor: Col.teal,
                inactiveThumbColor: Col.teal,
                value: showCompleted,
                onChanged: ((val) {
                  print("running on changed with val = $val");
                  setState(() {
                    showCompleted = val;
                    print("showCompleted is now $val");
                  });
                }),
              ),
            ],
          ),
        ),
        buildIfShown(myCompletedList, showCompleted),
      ],
    ));
  }

  Widget buildIfShown(Widget widget, bool show) {
    return Opacity(child: widget, opacity: show ? 1.0 : 0.0);
  }
}
