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

List<Widget> _tablePages = <Widget> [
  const HomeworksPage(),
  const SubscriptionsPage(),
];

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
      body: Container(
        child: _tablePages.elementAt(_selectedIndex),
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
                  onPressed: () {
                    setState(() async {
                      Navigator.pop(context, 'OK');
                      await DatabaseHelper.instance.add(
                        MyEntry(
                          desc: _homeworkController.text,
                          source: _courseController.text,
                          date: _dateController.text,
                        ),
                      );
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

class HomeworksPage extends StatefulWidget {
  const HomeworksPage({Key? key}) : super(key: key);

  @override
  State<HomeworksPage> createState() => _HomeworksPageState();
}

class _HomeworksPageState extends State<HomeworksPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MyEntry>>(
      future: DatabaseHelper.instance.getEntries(),
      builder: (BuildContext context, AsyncSnapshot<List<MyEntry>> snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: Text('Loading...'));
      }
      return //snapshot.data!.isEmpty ? const Center(child: Text('No entries in list')):
        DataTable(
          columnSpacing: 44.0,
          columns: const [
            DataColumn(
              label: Text('Homework'),
            ),
            DataColumn(
              label: Text('Course'),
            ),
            DataColumn(
              label: Text('Due date'),
            ),
            DataColumn(
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
                  setState(() {
                    DatabaseHelper.instance.delete(entry.id);
                  });
                },
              )),
            ]
          )).toList(),
        );
      }
    );
  }
}

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MyEntry>>(
      future: DatabaseHelper.instance.getEntries(),
      builder: (BuildContext context, AsyncSnapshot<List<MyEntry>> snapshot) {
      if(!snapshot.hasData) {
        return const Center(child: Text('Loading...'));
      }
      return //snapshot.data!.isEmpty ? const Center(child: Text('No entries in list')):
        DataTable(
          columnSpacing: 35.0,
          columns: const [
            DataColumn(
              label: Text('Subscription'),
            ),
            DataColumn(
              label: Text('Company'),
            ),
            DataColumn(
              label: Text('From'),
            ),
            DataColumn(
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
                  setState(() {
                    DatabaseHelper.instance.delete(entry.id);
                  });
                },
              )),
            ]
          )).toList(),
        );
      },
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
      CREATE TABLE entries(
        id INTEGER PRIMARY KEY,
        desc TEXT,
        source TEXT,
        date TEXT
      )
    ''');
  }

  Future<List<MyEntry>> getEntries() async {
    Database db = await instance.database;
    var records = await db.query('entries', orderBy: 'id');

    List<MyEntry> entriesList = records.isNotEmpty
        ? records.map((c) => MyEntry.fromMap(c)).toList()
        : [];

    return entriesList;
  }

  Future<int> add(MyEntry entry) async {
    Database db = await instance.database;
    return await db.insert('entries', entry.toMap());
  }

  Future<void> addSQL(MyEntry entry) async {
    Database db = await instance.database;
    String sqlStatement = '''
      INSERT INTO entries  (desc,source,date)
      VALUES ('${entry.desc}', '${entry.source}', '${entry.date});
    ''';
    await db.execute(sqlStatement);
  }

  Future<int> delete(int? id) async {
    Database db = await instance.database;
    return await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }


}

