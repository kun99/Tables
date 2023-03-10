import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'my_entry.dart';
import 'note.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'entries.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  //didn't really know how to format all the commands together
  //creating all tables and adding preset notes to notes table on app init
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE homeworks(
        id INTEGER PRIMARY KEY,
        descr TEXT,
        source TEXT,
        date TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE subscriptions(
        id INTEGER PRIMARY KEY,
        descr TEXT,
        source TEXT,
        date TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY,
        type INTEGER,
        note BLOB
      );
    ''');
    await db.execute('''
      INSERT INTO notes (type, note)
      VALUES (0, 
        'HW Note 
        \n Tap on columns on the first row to sort
        \n Tap on date to change date');
    ''');
    await db.execute('''
      INSERT INTO notes (type, note)
      VALUES (1, 
        'Subs Note
        \n Tap on columns on the first row to sort
        \n Tap on date to change date');
    ''');
  }

  //returns entries from homeworks/subs entries
  Future<List<MyEntry>> getEntries(int type, String column) async {
    Database db = await instance.database;
    var entries = type == 0 ? await db.query('homeworks', orderBy: column)
        : await db.query('subscriptions', orderBy: column);

    List<MyEntry> entriesList = entries.isNotEmpty
        ? entries.map((c) => MyEntry.fromMap(c)).toList()
        : [];

    return entriesList;
  }

  //returns note depending on page index of app
  Future<Object?> getNote(int type) async {
    Database db = await instance.database;
    Object? retrievedNote = '';
    var getCostSum = await db.rawQuery(
        'SELECT note FROM notes WHERE type=$type');
    //just iterating through as i know there is only one unique note for that type
    for (var element in getCostSum) {
      for (var v in element.values){
        retrievedNote = v;
      }
    }
    return retrievedNote;
  }

  //adds new entry into either hw or subs table
  Future<int> add(int type, MyEntry entry) async {
    Database db = await instance.database;
    var entries = type == 0 ?  await db.insert('homeworks', entry.toMap())
        : await db.insert('subscriptions', entry.toMap());
    return entries;
  }

  //editing note - simply deleting preexisting note and adding a new one
  //so the notes table will always only have 2 entries
  //one note for hw and one note for subs
  Future<int> editNote(int type, Note note) async {
    Database db = await instance.database;
    db.delete('note', where: 'type = ?', whereArgs: [type]);
    var addedNote = await db.insert('notes', note.toMap());
    return addedNote;
  }

  //updating date of hw/subs entry
  Future<int> update(int type, MyEntry entry) async {
    Database db = await instance.database;
    String table = type == 0 ? 'homeworks' : 'subscriptions';
    return await db.update(table, entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  //deleting entry from table
  Future<int> delete(int type, int? id) async {
    Database db = await instance.database;
    String table = type == 0 ? 'homeworks' : 'subscriptions';
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  //returns sum of the cost column from subs table
  Future<Object?> getSum() async {
    Database db = await instance.database;
    Object? sum = '';
    var getCostSum = await db.rawQuery(
        'SELECT SUM(source) FROM subscriptions');
    //just iterating through as i know there is only one key and val in the map
    for (var element in getCostSum) {
      for (var v in element.values){
        sum = v;
      }
    }
    return sum;
  }
}