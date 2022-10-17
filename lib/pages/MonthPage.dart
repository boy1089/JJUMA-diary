import 'package:flutter/material.dart';
import 'package:googleapis/cloudbuild/v1.dart';
import 'package:googleapis/drive/v2.dart';
import 'package:googleapis/shared.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import 'package:test_location_2nd/StateProvider.dart';
import 'package:test_location_2nd/Util/Util.dart';
import "package:test_location_2nd/DateHandler.dart";
import 'package:test_location_2nd/global.dart';
import 'MainPage.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'DayPage.dart';
//TODO : make navigation to day page

class MonthPage extends StatefulWidget {
  int index = 0;

  MonthPage(int index) {
    this.index = index;
  }

  @override
  State<MonthPage> createState() => _MonthPageState();
}

double _scaleFactor = 1.0;
double _baseScaleFactor = 1.0;
class _MonthPageState extends State<MonthPage> {
  int index = 0;

  @override
  void initState() {
    this.index = index;
  }

  @override
  Widget build(BuildContext buildContext) {
    // MainPageState? mainPage = buildContext.findAncestorRenderObjectOfType();
    // Matrix4 matrix = Matrix4.identity();

    return Scaffold(
      body: Center(
        child: GestureDetector(
            onScaleStart: (details) {
              _baseScaleFactor = _scaleFactor;
            },
            onScaleUpdate: (details) {
              setState(() {
                print(_scaleFactor);
                _scaleFactor = _baseScaleFactor * details.scale;
              });
            },
            child: YearWheelScrollView().build(buildContext)),
      ),
    );
  }





}

class YearWheelScrollView {
  @override
  Widget build(BuildContext buildContext) {
    return ListView(
        children: List.generate(
            DateTime.now().month,
            (int index) => MonthArray(DateTime.now().month - index - 1)
                .build(buildContext)));
  }
}

class MonthArray {
  int month = 1;
  int numberOfWeek = 4;
  MonthArray(@required month) {
    this.month = month + 1;
    this.numberOfWeek = weekNumber(DateTime(2022, this.month + 1, 0)) -
        weekNumber(DateTime(2022, this.month, 1));
  }

  @override
  Widget build(BuildContext buildContext) {
    return Column(children: [
      Column(
          // children : [],
          children: List.generate(
              numberOfWeek + 1,
              (int index) =>
                  WeekRow(month, numberOfWeek - index).build(buildContext))),
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

  double width = physicalWidth * 1;
  // double height = physicalWi;

  @override
  Widget build(BuildContext buildContext) {
    return SizedBox(
      width: width ,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              7,
              (int index) =>
                  DayButton(month, weekIndex, index).build(buildContext))
                  // Text('a', textScaleFactor: _scaleFactor))
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
    this.today = DateTime(2022, month, (weekIndex) * 7 + day + 1 - start);
  }

  double width = physicalHeight/70.0;
  double height = physicalHeight/70.0;

  @override
  Widget build(BuildContext buildContext) {

    bool isValidDate = today.month == month;
    return isValidDate
        ? SizedBox(
          width : width * _scaleFactor,
          height : height * _scaleFactor,
          child: RawMaterialButton(

              onPressed: () {
                selectedDate = today;
                buildContext.read<NavigationIndexProvider>().setNavigationIndex(0);
                buildContext
                    .read<NavigationIndexProvider>()
                    .setDate(selectedDate);

              },
              constraints:
                  BoxConstraints(minWidth: width*_scaleFactor, minHeight: height*_scaleFactor,
                  maxWidth : width*_scaleFactor + 1.0, maxHeight: height*_scaleFactor + 1.0),
              elevation: 4.0,
              fillColor: Colors.white,
              shape: CircleBorder(),
            ),
    )
        : SizedBox(
        width : width * _scaleFactor,
        height : height * _scaleFactor,
        child: RawMaterialButton(
            onPressed: () {},
            constraints:
            BoxConstraints(minWidth: width*_scaleFactor, minHeight: height*_scaleFactor,
                maxWidth : width*_scaleFactor + 1.0, maxHeight: height*_scaleFactor + 1.0),
          ));
  }
}
