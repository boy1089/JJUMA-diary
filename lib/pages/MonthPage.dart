import 'package:flutter/material.dart';
import 'package:googleapis/cloudbuild/v1.dart';
import 'package:googleapis/shared.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import 'package:test_location_2nd/Util/Util.dart';
import '../Sensor/SensorDataReader.dart';
import '../navigation.dart';
import 'package:test_location_2nd/pages/SettingPage.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/Util/responseParser.dart';
import 'package:test_location_2nd/PolarSensorDataPlot.dart';
import 'package:test_location_2nd/PolarPhotoDataPlot.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import "package:test_location_2nd/DateHandler.dart";

//TODO : make navigation to day page

class MonthPage extends StatefulWidget {
  int index = 0;


  MonthPage(int index) {
    this.index = index;
  }

  @override
  State<MonthPage> createState() => _MonthPageState();
}

class _MonthPageState extends State<MonthPage> {
  int index = 0;

  @override
  void initState() {
    this.index = index;
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      body: Center(
        child: YearWheelScrollView().build(buildContext),
      ),
    );
  }
}

class YearWheelScrollView {
  @override
  Widget build(BuildContext buildContext) {
    return ListView(
        // physics: const FixedExtentScrollPhysics(),
        // itemExtent: 1,
        children: List.generate(
            DateTime.now().month,
            (int index) => MonthArray(DateTime.now().month - index - 1)
                .build(buildContext)));
    // children : List.generate(12, (int index)=> MonthArray(12-index-1).build(buildContext)));
  }
}

class MonthArray {
  int month = 1;
  int numberOfWeek = 4;
  MonthArray(@required month) {
    this.month = month + 1;
    this.numberOfWeek = weekNumber(DateTime(2022, this.month +1, 0)) -
        weekNumber(DateTime(2022, this.month, 1));
  }

  @override
  Widget build(BuildContext buildContext) {
    return Column(children: [
      Text("$month"),
      Column(
          // children : [],
          children: List.generate(
              numberOfWeek+1,
              (int index) => WeekRow(month, numberOfWeek-index).build(buildContext))),
    ]);
  }
}

class WeekRow {
  int month = 1;
  int weekIndex = 1;
  WeekRow(@required month, @required index) {
    this.month = month;
    this.weekIndex = index;
  }

  @override
  Widget build(BuildContext buildContext) {
    return SizedBox(
      width: physicalWidth,
      child: Row(
        children: [
          Text("$month, $weekIndex"),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  7,
                  (int index) =>
                      DayButton(month, weekIndex, index).build(buildContext))),
        ],
      ),
    );
  }
}

class DayButton {
  int day = 1;
  int weekIndex = 1;
  int month = 1;
  int start = 1;
  late DateTime today;
  DayButton(@required month, @required weekIndex, @required day) {
    this.month = month;
    this.weekIndex = weekIndex;
    this.day = day;

    this.start = DateTime(2022, month, 1).weekday;
    this.today = DateTime(2022, month, (weekIndex) * 7 + day +1 -start);
  }

  @override
  Widget build(BuildContext buildContext) {
    bool isValidDate = today.month== month;
    return
      isValidDate?
      RawMaterialButton(
      onPressed: () {},
      constraints: BoxConstraints(minWidth: physicalWidth / 8, minHeight: 36.0),
      elevation: 2.0,
      fillColor: Colors.white,
      child: Text(
          "${today.toString().substring(5, 10)}"),
      // padding: EdgeInsets.all(15.0),
      shape: CircleBorder(),
    ):
      RawMaterialButton(
        onPressed: () {

        },
        constraints: BoxConstraints(minWidth: physicalWidth / 8, minHeight: 36.0),
      );
  }
}
