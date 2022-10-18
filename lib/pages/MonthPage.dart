import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/StateProvider.dart';
import 'package:test_location_2nd/Util/Util.dart';
import "package:test_location_2nd/DateHandler.dart";
import 'package:test_location_2nd/global.dart';
import 'DayPage.dart';
//TODO : make navigation to day page
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:test_location_2nd/global.dart';

class MonthPage extends StatefulWidget {
  int index = 0;
  DataManager dataManager;

  @override
  State<MonthPage> createState() => _MonthPageState();

  MonthPage(this.index, this.dataManager, {Key? key}) : super(key: key);
}

double _scaleFactor = 1.0;
double _baseScaleFactor = 1.0;

class _MonthPageState extends State<MonthPage> {
  int index = 0;
  late DataManager dataManager;

  @override
  void initState() {
    this.index = index;
    this.dataManager = widget.dataManager;
  }

  @override
  Widget build(BuildContext buildContext) {
    // MainPageState? mainPage = buildContext.findAncestorRenderObjectOfType();
    // Matrix4 matrix = Matrix4.identity();

    return Scaffold(
      body: Center(
        child: GestureDetector(
            onScaleStart: (details) {
              _scaleFactor = _baseScaleFactor;
            },
            onScaleUpdate: (details) {
              setState(() {
                print(_scaleFactor);
                _scaleFactor = _baseScaleFactor * details.scale;
              });
            },
            onDoubleTap: () {
              print(_scaleFactor);
              print(_baseScaleFactor);
              setState(() {
                if (_scaleFactor > _baseScaleFactor * 4) {
                  _scaleFactor = _baseScaleFactor;
                } else {
                  _scaleFactor = _scaleFactor * 1.5;
                }
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
      width: width,
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

  DayButton(
    @required month,
    @required weekIndex,
    @required day,
  ) {
    this.month = month;
    this.weekIndex = weekIndex;
    this.day = day;

    this.start = DateTime(2022, month, 1).weekday;
    this.today = DateTime(2022, month, (weekIndex) * 7 + day + 1 - start);
  }

  double width = physicalHeight / 70.0;
  double height = physicalHeight / 70.0;

  Future animation() async {
    return await Future.delayed(const Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext buildContext) {
    print(today);
    bool isValidDate = today.month == month;
    return isValidDate
        ? SizedBox(
            width: width * _scaleFactor,
            height: height * _scaleFactor,
            child: RawMaterialButton(
              onPressed: () async {
                selectedDate = today;
                buildContext
                    .read<NavigationIndexProvider>()
                    .setNavigationIndex(0);
                buildContext
                    .read<NavigationIndexProvider>()
                    .setDate(selectedDate);
              },
              constraints: BoxConstraints(
                  minWidth: width * _scaleFactor,
                  minHeight: height * _scaleFactor,
                  maxWidth: width * _scaleFactor + 1.0,
                  maxHeight: height * _scaleFactor + 1.0),
              elevation: 1.0,
              fillColor: summaryOfGooglePhotoData.containsKey(formatDate(today))
                  // ? Color.lerp(Colors.white, Colors.yellowAccent,
                  //     (summaryOfGooglePhotoData[formatDate(today)] ) / 50)
                  ? Color.lerp(Colors.white, Colors.deepOrangeAccent,
                  (summaryOfGooglePhotoData[formatDate(today)] ) / 50)
                  : Colors.white,
              shape: CircleBorder(),
            ),
          )
        : SizedBox(
            width: width * _scaleFactor,
            height: height * _scaleFactor,
            child: RawMaterialButton(
              onPressed: () {},
              constraints: BoxConstraints(
                  minWidth: width * _scaleFactor,
                  minHeight: height * _scaleFactor,
                  maxWidth: width * _scaleFactor + 1.0,
                  maxHeight: height * _scaleFactor + 1.0),
            ));
  }
}
