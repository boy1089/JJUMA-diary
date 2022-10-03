import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:test_location_2nd/Event.dart';
import 'package:test_location_2nd/EventList.dart';
import 'package:test_location_2nd/NoteData.dart';

import 'package:test_location_2nd/SensorLogger.dart';
import 'package:test_location_2nd/NoteLogger.dart';
import 'package:test_location_2nd/Util.dart';
import 'package:test_location_2nd/DataAnalyzer.dart';
import 'package:test_location_2nd/NoteData.dart';

import 'package:flutter_logs/flutter_logs.dart';
import 'package:test_location_2nd/DataReader.dart';

import 'package:test_location_2nd/daily_page.dart';

void main()  {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var text = "logging";
  final sensorLogger = SensorLogger();
  final noteLogger = NoteLogger();
  final dataAnalyzer = DataAnalyzer();
  final myTextController = TextEditingController();
  final dataReader = DataReader();



  void saveNote() {
    noteLogger
        .writeCache2(NoteData(DateTime.now(),myTextController.text));
    text = "${DateTime.now()} : note saved!";
    myTextController.clear();
    setState(() {});
  }

  Future<EventList> _fetch1() async {
    await Future.delayed(Duration(seconds: 25));
    return dataAnalyzer.eventList;
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        home : TestPolarPage(dataReader),

        // floatingActionButton: FloatingActionButton(
        // onPressed: () {
        //   // print(DateTime.parse(DateFormat('yyyyMMdd').format(DateTime.now())));
        //   // text = "data saved at: " +
        //   //     DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        //   // setState(() {});
        //   // sensorLogger.forceWrite();
        //   dataReader.readFiles();
        //   print(dataReader.dataAll);
        //   print(dataReader.files2);

          // print(DateTime.now().toString());

          // print(DateTime.now());
        // },
      );

  }
}