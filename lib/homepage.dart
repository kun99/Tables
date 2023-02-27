import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mob_project/colors.dart';
import 'my_entry.dart';
import 'note.dart';
import 'database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //controllers for respective text forms
  final _homeworkController = TextEditingController();
  final _courseController = TextEditingController();
  final _dateController = TextEditingController();
  final _noteHWController = TextEditingController();
  final _noteSController = TextEditingController();

  //to easily assign column names based on _selectedIndex
  final List<String> _labelOnes = ['Homework', 'Subscription'];
  final List<String> _labelTwos = ['Course name',  'Cost'];
  final List<String> _labelThrees = ['Due date', 'Starting'];

  //the app page the user is at
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
            'A Tale of Two Tables'
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
                  DataColumn(             //column for Homework/Subscription
                    label: TextButton(
                      child: Text(
                        _selectedIndex == 0 ? _labelOnes[0] : _labelOnes[1],
                        style: const TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        setState(() {
                          //if previous sorting was by descending, sort by ascending
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
                  DataColumn(             //column for course name/cost
                    label: TextButton(
                      child: Text(
                        _selectedIndex == 0 ? _labelTwos[0] : _labelTwos[1],
                        style: const TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        setState(() {
                          //as the same class is used for both tables and cost of subs is
                          //stored as TEXT in the table, performing a numerical operation
                          //allows it to be an INTEGER - i think
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
                  DataColumn(             //column for date
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
                  const DataColumn(             //column for delete button
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
                      onTap: () { //Option to edit date
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
                      Center(             //Delete button
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
          //to display total cost of subs - only displayed when index=1 (Subs page)
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
          //button to sort by added order
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
          //Note for respective pages
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: FutureBuilder<Object?>(
              future: DatabaseHelper.instance.getNote(_selectedIndex),
              builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
                return Column(
                  children: [
                    TextFormField(
                      //setting controller to take in and display note depending on index
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
                      //saving note depending on index
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
      //just a floating button to add new entries
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
      //bottom nav bar to switch between different pages
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
