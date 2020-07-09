import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'item_widget.dart';
import 'todo_item_widget.dart';
import 'saved_vals.dart';

// database table and column names
final String tableItems = 'items';
final String completedItems = 'completed';
final String schoolClasses = 'school_classes';
final String assignTypes = 'assign_types';
final String columnId = '_id';
final String columnName = 'word';
final String columnDue = 'due';
final String columnPriority = 'priority';
final String columnClassKey = 'class_key';
final String columnTypeKey = 'type_key';
final String columnColor = 'color';

abstract class DatabaseHelper {
  Future<int> insert(Entry entry);
  Future<Entry> queryEntry(int id);
  Future<List<Entry>> queryAllEntries();
  Future<void> deleteAllEntries();
  Future<void> deleteEntry(int id);
  Future<void> update(Entry entry);
}

abstract class Entry {
  int id;
  Entry();
  Entry.fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap();
  String toString();
}

class DatabaseMethods {
  static read(DatabaseHelper helper, int rowId) async {
    Entry entry = await helper.queryEntry(rowId);

    if (entry == null) {
    } else {}
  }

  static Future<List<Entry>> readAll(DatabaseHelper helper) async {
    List<Entry> entries = await helper.queryAllEntries();

    if (entries != null) {
      for (int i = 0; i < entries.length; i++) {}

      return entries;
    } else {}

    return [];
  }

  static Future<List<ItemWidget>> readAllAsWidget(
      DatabaseHelper helper, int type) async {
    List<Entry> entriesDatabaseType = await readAll(helper);
    List<ItemWidget> widgets = [];

    if (type == DatabaseTypes.itemDatabase) {
      TodoItemWidget nextItem;

      for (int i = 0; i < entriesDatabaseType.length; i++) {
        Map<String, dynamic> params = entriesDatabaseType[i].toMap();
        nextItem = new TodoItemWidget(
            title: params[columnName],
            due: DateTime.parse(params[columnDue]),
            priority: params[columnPriority],
            id: params[columnId],
            typeKey: params[columnTypeKey]);
        widgets.add(nextItem);
      }
    }

    if (type == DatabaseTypes.classDatabase) {
      SchoolClassWidget nextWidget;

      for (int i = 0; i < entriesDatabaseType.length; i++) {
        Map<String, dynamic> params = entriesDatabaseType[i].toMap();
        nextWidget = new SchoolClassWidget(
            name: params[columnName],
            id: params[columnId],
            color: Color(params[columnColor]));
        widgets.add(nextWidget);
      }
    }

    if (type == DatabaseTypes.typeDatabase) {
      AssignTypeWidget nextWidget;

      for (int i = 0; i < entriesDatabaseType.length; i++) {
        Map<String, dynamic> params = entriesDatabaseType[i].toMap();
        nextWidget = new AssignTypeWidget(
            name: params[columnName],
            id: params[columnId],
            classKey: params[columnClassKey]);
        widgets.add(nextWidget);
      }
    }
    return widgets;
  }

  static save(Entry entry, DatabaseHelper helper) async {
    int id = await helper.insert(entry);
  }

  static clearAll(DatabaseHelper helper) async {
    helper.deleteAllEntries();
  }

  static deleteItem(int index, DatabaseHelper helper) async {
    await helper.deleteEntry(index);

    await readAll(helper);
  }

  static editItem(DatabaseHelper helper, Entry entry) async {
    await helper.update(entry);
    await readAll(helper);
  }

  static Future<int> getId(DatabaseHelper helper, TodoItemWidget item) async {
    List<Entry> entries = await readAll(helper);
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].toMap()[columnName] == item.title &&
          entries[i].toMap()[columnDue] == item.due.toString() &&
          entries[i].toMap()[columnPriority] == item.priority) {
        return entries[i].id;
      }
    }
    return 10000;
  }
}

//******************************************************************************\\
//ITEM CLASS
//******************************************************************************\\

class Item extends Entry {
  int id;
  String name;
  DateTime due;
  int priority;
  int typeKey;

  Item();

  // convenience constructor to create a Word object
  Item.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    due = DateTime.parse(map[columnDue]);
    priority = map[columnPriority];
    typeKey = map[columnTypeKey];
  }

  // convenience method to create a Map from this Word object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnName: name,
      columnDue: due.toString(),
      columnPriority: priority,
      columnTypeKey: typeKey
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  @override
  String toString() {
    return '$id ' + name + ' Due $due, priority $priority, typeKey $typeKey';
  }
}

//************************************************************************************************\\
//SCHOOLCLASS CLASS
//************************************************************************************************\\

class SchoolClass extends Entry {
  int id;
  String name;
  Color color;
  SchoolClass();

  SchoolClass.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    color = Color(map[columnColor]);
  }
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{columnName: name, columnColor: color.value};
    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }

  String toString() {
    return '$id $name';
  }
}
//************************************************************************************************\\
//ASSIGNTYPE CLASS
//************************************************************************************************\\

class AssignType extends Entry {
  int id;
  String name;
  int classKey;
  AssignType();

  AssignType.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    classKey = map[columnClassKey];
  }
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{columnName: name, columnClassKey: classKey};
    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }

  String toString() {
    return '$id $name tied to class with id $classKey';
  }
}

//************************************************************************************************\\
//HELPER FOR ITEM DATABASE
//************************************************************************************************\\

// singleton class to manage the database
class ItemDatabaseHelper extends DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "ItemDatabase2.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  ItemDatabaseHelper._privateConstructor();
  static final ItemDatabaseHelper instance =
      ItemDatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) _database.close();
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tableItems (
                $columnId INTEGER PRIMARY KEY,
                $columnName TEXT NOT NULL,
                $columnDue STRING NOT NULL,
                $columnPriority INT NOT NULL,
                $columnTypeKey INT NOT NULL
              )
              ''');
  }

  // Database helper methods:

  Future<int> insert(Entry item) async {
    Database db = await database;
    int id = await db.insert(tableItems, item.toMap());
    return id;
  }

  Future<Item> queryEntry(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(tableItems,
        columns: [
          columnId,
          columnName,
          columnDue,
          columnPriority,
          columnTypeKey
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Item.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Item>> queryAllEntries() async {
    Database db = await database;
    List<Map> maps = await db.query(tableItems);

    if (maps.length == 0) {
      return [];
    }

    List<Item> items = [Item.fromMap(maps.first)];

    for (int i = 1; i < maps.length; i++) {
      items.add(Item.fromMap(maps[i]));
    }

    return items;
  }

  Future<void> deleteAllEntries() async {
    List<Item> items = await queryAllEntries();

    if (items != null) {
      items.forEach((item) {
        deleteEntry(item.id);
      });
    }

    await queryAllEntries();
  }

  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete(tableItems, where: "$columnId = ?", whereArgs: [id]);
  }

  Future<void> update(Entry entry) async {
    final db = await database;
    await db.update(tableItems, entry.toMap(),
        where: "$columnId = ?", whereArgs: [entry.id]);
  }
}

//************************************************************************************************\\
//HELPER FOR COMPLETED ITEM DATABASE
//************************************************************************************************\\

// singleton class to manage the database
class CompletedItemDatabaseHelper extends DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "CompletedItemDatabase3.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  CompletedItemDatabaseHelper._privateConstructor();
  static final CompletedItemDatabaseHelper instance =
      CompletedItemDatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) _database.close();
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $completedItems (
                $columnId INTEGER PRIMARY KEY,
                $columnName TEXT NOT NULL,
                $columnDue STRING NOT NULL,
                $columnPriority INT NOT NULL,
                $columnTypeKey INT NOT NULL
              )
              ''');
  }

  // Database helper methods:
  Future<int> insert(Entry item) async {
    Database db = await database;
    int id = await db.insert(completedItems, item.toMap());
    return id;
  }

  Future<Item> queryEntry(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(completedItems,
        columns: [
          columnId,
          columnName,
          columnDue,
          columnPriority,
          columnTypeKey
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Item.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Item>> queryAllEntries() async {
    Database db = await database;
    List<Map> maps = await db.query(completedItems);

    if (maps.length == 0) {
      return [];
    }

    List<Item> items = [Item.fromMap(maps.first)];

    for (int i = 1; i < maps.length; i++) {
      items.add(Item.fromMap(maps[i]));
    }

    return items;
  }

  Future<void> deleteAllEntries() async {
    List<Item> items = await queryAllEntries();

    if (items != null) {
      items.forEach((item) {
        deleteEntry(item.id);
      });
    }
    await queryAllEntries();
  }

  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete(completedItems, where: "$columnId = ?", whereArgs: [id]);
  }

  Future<void> update(Entry entry) async {
    final db = await database;
    await db.update(completedItems, entry.toMap(),
        where: "$columnId = ?", whereArgs: [entry.id]);
  }
}

//************************************************************************************************\\
//HELPER FOR SCHOOLCLASS DATABASE
//************************************************************************************************\\

// singleton class to manage the database
class SchoolClassDatabaseHelper extends DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "SchoolClassDatabase2.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  SchoolClassDatabaseHelper._privateConstructor();
  static final SchoolClassDatabaseHelper instance =
      SchoolClassDatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) _database.close();
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $schoolClasses (
                $columnId INTEGER PRIMARY KEY,
                $columnName TEXT NOT NULL,
                $columnColor INT NOT NULL
              )
              ''');
  }

  // Database helper methods:
  Future<int> insert(Entry item) async {
    Database db = await database;
    int id = await db.insert(schoolClasses, item.toMap());
    return id;
  }

  Future<SchoolClass> queryEntry(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(schoolClasses,
        columns: [columnId, columnName],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return SchoolClass.fromMap(maps.first);
    }
    return null;
  }

  Future<List<SchoolClass>> queryAllEntries() async {
    Database db = await database;
    List<Map> maps = await db.query(schoolClasses);

    if (maps.length == 0) {
      return [];
    }

    List<SchoolClass> listClasses = [SchoolClass.fromMap(maps.first)];

    for (int i = 1; i < maps.length; i++) {
      listClasses.add(SchoolClass.fromMap(maps[i]));
    }

    return listClasses;
  }

  Future<void> deleteAllEntries() async {
    List<SchoolClass> items = await queryAllEntries();

    if (items != null) {
      items.forEach((item) {
        deleteEntry(item.id);
      });
    }
    await queryAllEntries();
  }

  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete(schoolClasses, where: "$columnId = ?", whereArgs: [id]);
  }

  Future<void> update(Entry entry) async {
    final db = await database;
    await db.update(schoolClasses, entry.toMap(),
        where: "$columnId = ?", whereArgs: [entry.id]);
  }
}

//************************************************************************************************\\
//HELPER FOR ASSIGNTYPE DATABASE
//************************************************************************************************\\

// singleton class to manage the database
class AssignTypeDatabaseHelper extends DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "AssignTypeDatabase.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  AssignTypeDatabaseHelper._privateConstructor();
  static final AssignTypeDatabaseHelper instance =
      AssignTypeDatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) _database.close();
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $assignTypes (
                $columnId INTEGER PRIMARY KEY,
                $columnName TEXT NOT NULL,
                $columnClassKey INT NOT NULL
              )
              ''');
  }

  // Database helper methods:
  Future<int> insert(Entry item) async {
    Database db = await database;
    int id = await db.insert(assignTypes, item.toMap());
    return id;
  }

  Future<AssignType> queryEntry(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(assignTypes,
        columns: [columnId, columnName],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return AssignType.fromMap(maps.first);
    }
    return null;
  }

  Future<List<AssignType>> queryAllEntries() async {
    Database db = await database;
    List<Map> maps = await db.query(assignTypes);

    if (maps.length == 0) {
      return [];
    }

    List<AssignType> listTypes = [AssignType.fromMap(maps.first)];

    for (int i = 1; i < maps.length; i++) {
      listTypes.add(AssignType.fromMap(maps[i]));
    }

    return listTypes;
  }

  Future<void> deleteAllEntries() async {
    List<AssignType> items = await queryAllEntries();

    if (items != null) {
      items.forEach((item) {
        deleteEntry(item.id);
      });
    }
    await queryAllEntries();
  }

  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete(assignTypes, where: "$columnId = ?", whereArgs: [id]);
  }

  Future<void> update(Entry entry) async {
    final db = await database;
    await db.update(assignTypes, entry.toMap(),
        where: "$columnId = ?", whereArgs: [entry.id]);
  }
}
