import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mob_project/colors.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'my_entry.dart';
import 'note.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final _homeworkController = TextEditingController();
  final _courseController = TextEditingController();
  final _dateController = TextEditingController();
  final _noteHWController = TextEditingController();
  final _noteSController = TextEditingController();

  final List<String> _labelOnes = ['Homework', 'Subscription'];
  final List<String> _labelTwos = ['Course name',  'Cost'];
  final List<String> _labelThrees = ['Due date', 'Starting'];

  int _selectedIndex = 0;
  String _column = "id";

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: springGreen,
        title: const Text(
            'An App of Tables'
        ),
      ),
      body: ListView(
        children: [
          FutureBuilder<List<MyEntry>>(
            future: DatabaseHelper.instance.getEntries(_selectedIndex, _column),
            builder: (BuildContext context, AsyncSnapshot<List<MyEntry>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: Text('No entries'));
              }
              return DataTable(
                decoration: BoxDecoration(
                  color: teaGreen,
                  border: Border.all(width: 10,color: Colors.white,),
                ),
                columnSpacing: _selectedIndex == 0 ?  6 : 15,
                columns: [
                  DataColumn(
                    label: TextButton(
                      child: Text(
                        _selectedIndex == 0 ? _labelOnes[0] : _labelOnes[1],
                        style: const TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        setState(() {
                          if(_column.endsWith('desc')){
                            _column = 'descr';
                          }
                          else{
                            _column = 'descr desc';
                          }
                        });
                      },
                    ),
                  ),
                  DataColumn(
                    label: TextButton(
                      child: Text(
                        _selectedIndex == 0 ? _labelTwos[0] : _labelTwos[1],
                        style: const TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        setState(() {
                          if(_column.endsWith('desc')){
                            if(_selectedIndex==1){
                              _column = 'source+1';
                            } else {
                              _column = 'source';
                            }
                            //_selectedIndex == 1 ? _column = 'source+1' : 'source';
                            //doesnt work as intended when ternary. why?
                          }
                          else{
                            if(_selectedIndex==1){
                              _column = 'source+1 desc';
                            } else {
                              _column = 'source desc';
                            }
                            //_selectedIndex == 1 ? _column = 'source+1 desc' : '$_column desc';
                            //doesnt work as intended when ternary. why?
                          }
                        });
                      },
                    ),
                  ),
                  DataColumn(
                    label: TextButton(
                      child: Text(
                        _selectedIndex == 0 ? _labelThrees[0] : _labelThrees[1],
                        style: const TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        setState(() {
                          if(_column.endsWith('desc')){
                            _column = 'date';
                          }
                          else{
                            _column = 'date desc';
                          }
                        });
                      },
                    ),
                  ),
                  const DataColumn(
                    label: Text(''),
                  ),
                ],
                rows: snapshot.data!.map((entry) => DataRow(
                  cells: [
                    DataCell(
                      Center(
                        child: Text(entry.descr),
                      ),
                      //onLongPress
                    ),
                    DataCell(
                      Center(
                        child: Text(entry.source, textAlign: TextAlign.center),
                      )
                    ),
                    DataCell(
                      Center(
                        child: Text(entry.date.toString()),
                      ),
                      onTap: () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Edit date'),
                            content: TextField(
                                controller: _dateController,
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.calendar_today),
                                  labelText: _labelThrees[_selectedIndex],
                                ),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: _selectedIndex == 0 ? DateTime.now() : DateTime(2020),
                                    lastDate: DateTime(2030)
                                );
                                if (pickedDate != null) {
                                  String formattedDate = DateFormat('yyyy-MM-dd')
                                      .format(pickedDate);
                                  setState(() {
                                    _dateController.text = formattedDate;
                                  });
                                }
                              },
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 'Cancel');
                                },
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 'OK');
                                  setState(() {
                                    entry.date = _dateController.text;
                                    DatabaseHelper.instance.update(_selectedIndex, entry);
                                    _dateController.clear();
                                  });
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          )
                        );
                      }
                    ),
                    DataCell(
                      Center(
                        child: IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Are you sure you want to delete?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('No'),
                                      onPressed: () {
                                        Navigator.pop(context, 'Cancel');
                                      },
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'OK');
                                        setState(() {
                                          DatabaseHelper.instance.delete(_selectedIndex, entry.id);
                                        });
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      )
                    ),
                  ]
                )).toList(),
              );
            }
          ),
          if(_selectedIndex == 1) FutureBuilder<Object?>(
              future: DatabaseHelper.instance.getSum(),
              builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
                if (snapshot.hasData) {
                  return Center(
                    child: Text('Subscription Total: ${snapshot.data!}'),
                  );
                } else{
                  return const Center(
                    child: Text(''),
                  );
                }
              }
          ),
          TextButton(
            child: const Text(
              'SORT BY ADDED ORDER',
              style: TextStyle(color: polyGreen),
            ),
            onPressed: () {
              setState(() {
                _column = 'id';
              });
            },
          ),
          const SizedBox(height: 5.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: FutureBuilder<Object?>(
              future: DatabaseHelper.instance.getNote(_selectedIndex),
              builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
                return Column(
                  children: [
                    TextFormField(
                      controller: _selectedIndex == 0 ? _noteHWController : _noteSController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        hintText: snapshot.hasData ? snapshot.data.toString() : 'No note',
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: polyGreen),
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                    TextButton(
                      onPressed: () async {
                        TextEditingController selectedNote = _selectedIndex == 0 ? _noteHWController : _noteSController;
                        if(selectedNote.text.isEmpty){
                          selectedNote.text = ' ';
                        }
                        await DatabaseHelper.instance.editNote(
                          _selectedIndex,
                          Note(
                            type: _selectedIndex,
                            note: selectedNote.text,
                          ),
                        );
                        setState(() {
                          String text = selectedNote.text;
                          if(selectedNote.text.isNotEmpty){
                            selectedNote.clear();
                          }
                          selectedNote.value = selectedNote.value.copyWith(
                            text: text,
                            selection: TextSelection.collapsed(offset: text.length),
                          );
                        });
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: polyGreen,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                );
              }
            )
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Add new'),
              content: Column(
                children: <Widget>[
                  TextField(
                    controller: _homeworkController,
                    decoration: InputDecoration(
                        labelText: _labelOnes[_selectedIndex]
                    ),
                  ),
                  TextField(
                    controller: _courseController,
                    decoration: InputDecoration(
                        labelText: _labelTwos[_selectedIndex]
                    ),
                  ),
                  TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.calendar_today),
                        labelText: _labelThrees[_selectedIndex],
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: _selectedIndex == 0 ? DateTime.now() : DateTime(2020),
                            lastDate: DateTime(2030)
                        );
                        if(pickedDate != null ){
                          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                          setState(() {
                            _dateController.text = formattedDate;
                          });
                        }
                      }
                  )
                ]
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                    setState(()  {
                      _homeworkController.clear();
                      _courseController.clear();
                      _dateController.clear();
                    });
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context, 'OK');
                    await DatabaseHelper.instance.add(
                      _selectedIndex,
                      MyEntry(
                        descr: _homeworkController.text,
                        source: _courseController.text,
                        date: _dateController.text,
                      ),
                    );
                    setState(()  {
                      _homeworkController.clear();
                      _courseController.clear();
                      _dateController.clear();
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        backgroundColor: yellowGreen,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: springGreen,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.my_library_books,
              color: yellowGreen,
            ),
            label: 'Homeworks',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.currency_exchange,
              color: yellowGreen,
            ),
            label: 'Subscriptions',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

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

  Future<List<MyEntry>> getEntries(int type, String column) async {
    Database db = await instance.database;
    var entries = type == 0 ? await db.query('homeworks', orderBy: column)
        : await db.query('subscriptions', orderBy: column);

    List<MyEntry> entriesList = entries.isNotEmpty
        ? entries.map((c) => MyEntry.fromMap(c)).toList()
        : [];

    return entriesList;
  }

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

  Future<int> add(int type, MyEntry entry) async {
    Database db = await instance.database;
    var entries = type == 0 ?  await db.insert('homeworks', entry.toMap())
        : await db.insert('subscriptions', entry.toMap());
    return entries;
  }

  Future<int> editNote(int type, Note note) async {
    Database db = await instance.database;
    db.delete('note', where: 'type = ?', whereArgs: [type]);
    var addedNote = await db.insert('notes', note.toMap());
    return addedNote;
  }

  Future<int> update(int type, MyEntry entry) async {
    Database db = await instance.database;
    String table = type == 0 ? 'homeworks' : 'subscriptions';
    return await db.update(table, entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<int> delete(int type, int? id) async {
    Database db = await instance.database;
    String table = type == 0 ? 'homeworks' : 'subscriptions';
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

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
