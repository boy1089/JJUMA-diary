import 'package:flutter/material.dart';
import 'package:test_location_2nd/ImageReader.dart';

import 'dart:math';
import 'dart:async';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  var imageReader;

  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Text('loggging'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("${imageReader.dates}");
          setState(() {});
        },
      ),
    ));
  }
}
