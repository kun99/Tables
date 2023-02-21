import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'my_entry.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

final _homeworkController = TextEditingController();
final _courseController = TextEditingController();
final _dateController = TextEditingController();

List<String> _labelOnes = ['Homework', 'Subscription'];
List<String> _labelTwos = ['Course name',  'Cost'];
List<String> _labelThrees = ['Due date', 'Starting'];

int _selectedIndex = 0;

class _HomePageState extends State<HomePage> {

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          'An App of Tables'
        ),
      ),
      body: FutureBuilder<List<MyEntry>>(
        future: DatabaseHelper.instance.getEntries(_selectedIndex),
        builder: (BuildContext context, AsyncSnapshot<List<MyEntry>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text('Loading...'));
          }
          return //snapshot.data!.isEmpty ? const Center(child: Text('No entries in list')):
            DataTable(
              columnSpacing: _selectedIndex == 0 ? 23 : 37,
              columns: [
                DataColumn(
                  label: Text(_selectedIndex == 0 ? _labelOnes[0] : _labelOnes[1]),
                ),
                DataColumn(
                  label: Text(_selectedIndex == 0 ? _labelTwos[0] : _labelTwos[1]),
                ),
                DataColumn(
                  label: Text(_selectedIndex == 0 ? _labelThrees[0] : _labelThrees[1]),
                ),
                const DataColumn(
                  label: Text(''),
                ),
              ],
              rows: snapshot.data!.map((entry) => DataRow(
                cells: [
                  DataCell(Text(entry.desc)),
                  DataCell(Text(entry.source)),
                  DataCell(Text(entry.date.toString())),
                  DataCell(IconButton(
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
                  )),
                ]
              )).toList(),
            );
        }
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
                            firstDate: DateTime.now(),
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
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context, 'OK');
                    await DatabaseHelper.instance.add(
                      _selectedIndex,
                      MyEntry(
                        desc: _homeworkController.text,
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
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.amber,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.my_library_books ),
            label: 'Homeworks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange),
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
        desc TEXT,
        source TEXT,
        date TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE subscriptions(
        id INTEGER PRIMARY KEY,
        desc TEXT,
        source TEXT,
        date TEXT
      );
    ''');
  }

  Future<List<MyEntry>> getEntries(int type) async {
    Database db = await instance.database;
    var entries = type == 0 ? await db.query('homeworks', orderBy: 'id')
        : await db.query('subscriptions', orderBy: 'id');

    List<MyEntry> entriesList = entries.isNotEmpty
        ? entries.map((c) => MyEntry.fromMap(c)).toList()
        : [];

    return entriesList;
  }

  Future<int> add(int type, MyEntry entry) async {
    Database db = await instance.database;
    var entries = type == 0 ?  await db.insert('homeworks', entry.toMap())
        : await db.insert('subscriptions', entry.toMap());
    return entries;
  }

  Future<void> addSQL(int type, MyEntry entry) async {
    Database db = await instance.database;
    String sqlStatementHomeworks = '''
      INSERT INTO homeworks  (desc,source,date)
      VALUES ('${entry.desc}', ${entry.source}', '${entry.date});
    ''';
    String sqlStatementSubscriptions = '''
      INSERT INTO subscriptions  (desc,source,date)
      VALUES ('${entry.desc}', ${entry.source}', '${entry.date});
    ''';
    var statement = type == 0 ? sqlStatementHomeworks : sqlStatementSubscriptions;
    await db.execute(statement);
  }

  Future<int> delete(int type, int? id) async {
    Database db = await instance.database;
    String table = type == 0 ? 'homeworks' : 'subscriptions';
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }


}

