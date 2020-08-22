import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import './ImageData.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class DatabaseHelper {

  static final _databaseName = "data.db";
  static final _databaseVersion = 1;

  static final table = 'places';

  static final columnId = '_id';
  static final columnName = 'name';
  static final columnAge = 'image';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {

    String path = "";
    try{
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, _databaseName);
      ByteData data = await rootBundle.load(join("assets", "data.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await new File(path).writeAsBytes(bytes);
    } catch (e) {
      print(e.toString());
    }
    return await openDatabase(path);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnAge BLOB NOT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<List<Imagedata>> getMyImage() async {
    List<Imagedata> images = new List();
    try{
      _database = await _initDatabase();
      List<Map> list = await _database.query(table);
      for (int i = 0; i < list.length; i++) {
        images.add(new Imagedata(list[i]["id"], list[i]["name"], list[i]["image"]));
      }
    }catch(e){
      print(e.toString());
    }
    return images;
  }

  Object getOnlyImage() async {
    List<Map> list = new List();
    try{
      _database = await _initDatabase();
      list = await _database.query(table);
    }catch(e){
      print(e.toString());
    }
    return list[0]["image"];
  }
}