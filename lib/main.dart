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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          backgroundColor: Colors.blue,
          accentColor: Colors.orange,
          appBarTheme: AppBarTheme(color: Colors.green),
          buttonTheme: ButtonThemeData(
              buttonColor: Colors.blue, disabledColor: Colors.amber)),
      title: 'Items',
      home: ItemList(),
    );
  }
}

class ItemList extends StatefulWidget {
  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  StreamController<int> itemController = StreamController();
  StreamController<int> completedController = StreamController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final itemDbInstance = ItemDatabaseHelper.instance;
  final completedItemDbInstance = CompletedItemDatabaseHelper.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items'),
        actions: [
          IconButton(icon: Icon(Icons.settings), onPressed: manage),
          IconButton(icon: Icon(Icons.delete), onPressed: clearAll),
          IconButton(icon: Icon(Icons.add), onPressed: _addItem, iconSize: 40)
        ],
      ),
      body: BuildLists(
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
        appBar: AppBar(
          title: Text('Manage Classes'),
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
    final _inputTextStyle = TextStyle(
        color: Theme.of(context).appBarTheme.color,
        fontWeight: FontWeight.bold,
        fontSize: 18.0);
    final myTextController = TextEditingController();
    final myDateTimePicker = DateTimeWidget();
    final myPriorityDropdown = MyDropdown(
        Vals.priorityDropdownStrings,
        MyFlutterApp.exclamation_circle,
        Vals.priorityDropdownColors,
        Vals.priorityDropdownStrings[0]);

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
                      style: _inputTextStyle,
                      decoration: InputDecoration(
                          //border:OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
                          //labelText: "Title",
                          ),
                      controller: myTextController,
                    ),
                  ),
                  FlatButton(
                      child: Text('ADD', style: _inputTextStyle),
                      onPressed: () {
                        Item item = new Item();
                        item.name = myTextController.text;
                        item.due = myDateTimePicker.getDateTime();
                        item.priority = 0;
                        item.typeKey = 4;

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
      //controller: _controller,
      children: <Widget>[
        myItemList,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Completed Items"),
            Switch(
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
        buildIfShown(myCompletedList, showCompleted),
      ],
    ));
  }

  Widget buildIfShown(Widget widget, bool show) {
    return Opacity(child: widget, opacity: show ? 1.0 : 0.0);
  }
}
