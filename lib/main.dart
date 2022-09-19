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


//TODO : add more channels to sensor ( light, motion, temp, humidity, battery)
//TODO : get all log from all application ( chrome - web page, events )
//TODO : note to label the situation.
//TODO : fix bug in usagestat


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



  void saveNote() {
    noteLogger
        .writeCache(NoteData(DateTime.now(),myTextController.text));
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
        home: Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
            future: _fetch1(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
            //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
            if (snapshot.hasData == false) {
            return CircularProgressIndicator();
            }//error가 발생하게 될 경우 반환하게 되는 부분
            else if (snapshot.hasError) {
            return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
            'Error: ${snapshot.error}',
            style: TextStyle(fontSize: 30),
            ),
            );
            }
          else {
          return Expanded(
            child: ListView.builder(
                // padding: const EdgeInsets.all(8),
                itemCount: dataAnalyzer.eventList.length(),
                // itemCount: 10,

                itemBuilder: (BuildContext context, int index) {
                  print(dataAnalyzer.eventList.eventList);
                  DateTime date = dataAnalyzer.eventList.eventList[index].time;
                  String note = dataAnalyzer.eventList.eventList[index].note.toString();
                  Color color = (note == 'back home') ? event_color_backHome : event_color_goingOut;
                  return TextButton(
                    child: Align(
                      alignment : Alignment.topLeft,
                      child: Text(
                          '${DateTime(date.year, date.month, date.day, date.hour, date.minute).toString().substring(0, 16)}:'
                          ' ${note}'),
                    ),
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                        foregroundColor: MaterialStateProperty.all<Color>(color),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: color)
                            )
                        )
                    ),
                    onPressed: ()=> null,
                  );
                }),
          );}}),
          TextField(controller: myTextController,),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(text),
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
          print(DateTime.parse(DateFormat('yyyyMMdd').format(DateTime.now())));
          text = "data saved at: " +
              DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          setState(() {});
          sensorLogger.forceWrite();

          // print(DateTime.now().toString());

          // print(DateTime.now());
        },
      ),
    ));
  }
}