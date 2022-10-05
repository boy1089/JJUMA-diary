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

void main() {
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
    noteLogger.writeCache2(NoteData(DateTime.now(), myTextController.text));
    text = "${DateTime.now()} : note saved!";
    myTextController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
          future: dataReader.readFiles(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData == false) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('error');
            } else {
              print("snap shot data : ${snapshot.data}");
              print("snap shot data : ${snapshot.data.isEmpty}");
              if (snapshot.data.isEmpty) return Center(child : Text('no data found'));
              return TestPolarPage(dataReader);
            }
          }),
    );
  }
}
