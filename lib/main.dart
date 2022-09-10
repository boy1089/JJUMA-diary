import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:test_location_2nd/HappinessData.dart';

//TODO : identify events
//TODO : shot events in the UI

import 'package:test_location_2nd/SensorLogger.dart';
import 'package:test_location_2nd/HappinessLogger.dart';
import 'package:test_location_2nd/Util.dart';
import 'package:test_location_2nd/DataAnalyzer.dart';

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
  final happinessLogger = HappinessLogger();
  final happiness = Happiness();
  final dataAnalyzer = DataAnalyzer();
  final myTextController = TextEditingController();

  void saveHappiness(int i) {
    happinessLogger
        .writeCache(HappinessData(DateTime.now(), i, myTextController.text));
    text = "${i} happiness saved!";
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
          Expanded(
            child: ListView.builder(
                // padding: const EdgeInsets.all(8),
                itemCount: dataAnalyzer.eventList.length,
                itemBuilder: (BuildContext context, int index) {
                  DateTime date = dataAnalyzer.eventList[index].time;
                  String note = dataAnalyzer.eventList[index].note.toString();
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
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            OutlinedButton(
                onPressed: () {
                  saveHappiness(happiness.fantastic);
                },
                child: Text("Fantastic",
                    style: TextStyle(color: Colors.redAccent))),
            OutlinedButton(
                onPressed: () {
                  saveHappiness(happiness.good);
                },
                child: Text("good", style: TextStyle(color: Colors.lightBlue))),
            OutlinedButton(
                onPressed: () {
                  saveHappiness(happiness.notbad);
                },
                child: Text("not bad", style: TextStyle(color: Colors.green))),
            OutlinedButton(
                onPressed: () {
                  saveHappiness(happiness.soso);
                },
                child:
                Text("soso", style: TextStyle(color: Colors.orangeAccent))),
            OutlinedButton(
              onPressed: () {
                saveHappiness(happiness.bad);
              },
              child: Text("bad", style: TextStyle(color: Colors.grey)),
            ),
          ]),
          TextField(controller: myTextController),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // text = "data saved at: " +
          //     DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          // setState(() {});
          // sensorLogger.forceWrite();
          dataAnalyzer.readFiles();
          dataAnalyzer.printData();
        },
      ),
    ));
  }
}
