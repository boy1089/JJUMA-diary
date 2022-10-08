import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:test_location_2nd/NoteData.dart';

import 'package:test_location_2nd/SensorLogger.dart';
import 'package:test_location_2nd/NoteLogger.dart';
import 'package:test_location_2nd/DataAnalyzer.dart';
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

  Future readData = Future.delayed(Duration(seconds : 1));

  Future<List<List<List<dynamic>>>> _fetchData() async{
    await Future.delayed(Duration(seconds : 10));
    return [[['Data']]];
  }

  @override
  void initState(){
    readData = _fetchData();
    super.initState();
  }

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
          future: readData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            print("snapshot : ${snapshot.data}");

            if (snapshot.hasData == false) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        backgroundColor: Colors.blue,
                        color : Colors.orange,
                        strokeWidth: 4.0,
                      ),

                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('error');
            } else {
              print("snap shot data : ${snapshot.data}");
              print("snap shot data : ${snapshot.data.isEmpty}");
              if (snapshot.data.isEmpty) {
                // sensorLogger.forceWrite();
                return Center(child: Text('no data found'));
              }

              return TestPolarPage(dataReader);
            }
          }),
    );
  }
}
