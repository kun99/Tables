import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

int number = 1;
final _homeworkController = TextEditingController();
final _courseController = TextEditingController();
final _dateController = TextEditingController();

List<String> _labelOnes = ['Homework', 'Subscriptions'];
List<String> _labelTwos = ['Course name',  'Company name'];
List<String> _labelThrees = ['Due date', 'Starting'];

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
late Future<List> _table;

List<Widget> _tablePages = <Widget> [
  const HomeworksPage(),
  const SubscriptionsPage(),
];

var test = {};

int _selectedIndex = 0;

class _HomePageState extends State<HomePage> {

  Future<void> _addRow(String row) async {
    final SharedPreferences prefs = await _prefs;
    final List<String> table = prefs.getStringList('table') ?? [];
    table.add(row);

    setState(() {
      _table = prefs.setStringList('table', table).then((bool success) {
        return table;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _table = _prefs.then((SharedPreferences prefs) {
      //prefs.clear();
      return prefs.getStringList('table') ?? [];
    });
  }

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
      body: Center(
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
                            String formattedDate = DateFormat.yMMMd().format(pickedDate);
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
                    setState(() {
                      _addRow(_homeworkController.text+_courseController.text+_dateController.text);
                      Navigator.pop(context, 'OK');
                      print(_homeworkController.text+_courseController.text+_dateController.text);
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
    return Column(
      children: <Widget>[
        Row(
            children: <Widget> [
              Text('Number'),
              Text('Homework'),
              Text('Course'),
              Text('Due Date'),
              Text('Priority'),
            ]
        ),
        Row(
          children: [
            FutureBuilder(
              future: _table,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    else {
                      // List table = snapshot.data;
                      // String entries = "";
                      // for(int i=0; i < table.length; i++){
                      //   '${entries + table[i]}\n';
                      // }
                      return Text(
                          '${snapshot.data}\n\n'
                      );
                    }
                }
              },
            )
          ],
        )
      ],
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
    return Column(
      children: <Widget>[
        Row(
            children: const <Widget> [
              Text('Number'),
              Text('Subscription'),
              Text('Company'),
              Text('Since'),
              Text('Priority'),
            ]
        ),
      ],
    );
  }
}

