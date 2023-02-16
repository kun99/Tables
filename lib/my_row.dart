import 'package:flutter/material.dart';

class MyRow extends StatelessWidget {

  MyRow(
    {required this.number, required this.homework, required this.course, required this.date, required this.priority});

  final String number;
  final String homework;
  final String course;
  final int date;
  final String priority;


  @override
  Widget build(BuildContext context) {
    return Row(
        children: <Widget> [
          SizedBox(width: 20,),
          Text(number),
          SizedBox(width: 20,),
          Text(homework),
          SizedBox(width: 20,),
          Text(course),
          SizedBox(width: 20,),
          SizedBox(width: 20,),
          Text('Priority'),
        ]
    );
  }
}
