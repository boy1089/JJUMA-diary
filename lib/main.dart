import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:test_location_2nd/NoteData.dart';

//TODO : identify events
//TODO : shot events in the UI

import 'package:test_location_2nd/SensorLogger.dart';
import 'package:test_location_2nd/NoteLogger.dart';
import 'package:test_location_2nd/Util.dart';
import 'package:test_location_2nd/DataAnalyzer.dart';
import 'package:test_location_2nd/NoteData.dart';
void main() {
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

  void saveNote() {
    noteLogger
        .writeCache(NoteData(DateTime.now(),myTextController.text));
    text = "${DateTime.now()} : note saved!";
    myTextController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // Text(dataAnalyzer.eventList[0].time.toString()),
          // Expanded(
          //   child: ListView.builder(
          //       // padding: const EdgeInsets.all(8),
          //       // itemCount: dataAnalyzer.eventList.length(),
          //       itemCount: 10,
          //
          //       itemBuilder: (BuildContext context, int index) {
          //         print(dataAnalyzer.eventList.eventList);
          //         DateTime date = dataAnalyzer.eventList.eventList[index].time;
          //         String note = dataAnalyzer.eventList.eventList[index].note.toString();
          //         Color color = (note == 'back home') ? event_color_backHome : event_color_goingOut;
          //         return TextButton(
          //           child: Align(
          //             alignment : Alignment.topLeft,
          //             child: Text(
          //                 '${DateTime(date.year, date.month, date.day, date.hour, date.minute).toString().substring(0, 16)}:'
          //                 ' ${note}'),
          //           ),
          //           style: ButtonStyle(
          //               padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
          //               foregroundColor: MaterialStateProperty.all<Color>(color),
          //               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //                   RoundedRectangleBorder(
          //                       borderRadius: BorderRadius.circular(18.0),
          //                       side: BorderSide(color: color)
          //                   )
          //               )
          //           ),
          //           onPressed: ()=> null,
          //         );
          //       }),
          // ),
          TextField(controller: myTextController,),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            OutlinedButton(
              onPressed: () {
                saveNote();
              },
              child: Text("leave note", style: TextStyle(color: Colors.grey)),
            ),
          ]),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          text = "data saved at: " +
              DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          setState(() {});
          sensorLogger.forceWrite();
          // dataAnalyzer.readFiles();
          // dataAnalyzer.printData();
        },
      ),
    ));
  }
}
