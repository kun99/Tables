import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

int number = 1;
final _homeworkController = TextEditingController();
final _courseController = TextEditingController();
final _dateController = TextEditingController();

List<Widget> _tablePages = <Widget> [
  const HomeworksPage(),
  const SubscriptionsPage(),
];

var test = {};

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
      body: Center(
        child: _tablePages.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(_selectedIndex==0){
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Add a homework'),
                content: Column(
                    children: <Widget>[
                      TextField(
                        controller: _homeworkController,
                        decoration: const InputDecoration(
                            labelText: "Homework"
                        ),
                      ),
                      TextField(
                        controller: _courseController,
                        decoration: const InputDecoration(
                            labelText: "Course name"
                        ),
                      ),
                      TextField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.calendar_today),
                            labelText: "Due date",
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
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          else if(_selectedIndex==1){
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Add a subscription'),
                content: Column(
                    children: <Widget>[
                      TextField(
                        controller: _homeworkController,
                        decoration: const InputDecoration(
                            labelText: "Subscription"
                        ),
                      ),
                      TextField(
                        controller: _courseController,
                        decoration: const InputDecoration(
                            labelText: "Company name"
                        ),
                      ),
                      TextField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.calendar_today),
                            labelText: "Starting from",
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
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
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
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
            children: const <Widget> [
              Text('Number'),
              Text('Homework'),
              Text('Course'),
              Text('Due Date'),
              Text('Priority'),
            ]
        ),
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

