import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:graphic/graphic.dart';
import 'dart:async';
import 'package:test_location_2nd/DayPage.dart';
import 'package:test_location_2nd/CalendarPage.dart';

//TODO : seperate main, calendarview, dayview
//TODO : create calendar view
//TODO : manage audio files.

import 'package:test_location_2nd/SensorLogger.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final dayPage = DayPage();
  final calendarPage = CalendarPage();
  @override
  Widget build(BuildContext context) {

    final sensorLogger = SensorLogger();

    return MaterialApp(
      // initialRoute: '/loading',
      initialRoute: '/calendar',
      routes: {
        '/day': (context) => dayPage,
        '/calendar': (context) => calendarPage,

      },
      onGenerateRoute: (routeSettings) {
        if (routeSettings.name == '/day') {
          final args = routeSettings.arguments;
          return MaterialPageRoute(builder: (context) {
            return dayPage;
          });
        }
        if (routeSettings.name == '/calendar') {
          final args = routeSettings.arguments;
          return MaterialPageRoute(builder: (context) {
            return calendarPage;
          });
        }

      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
