import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/StateProvider.dart';
import 'package:test_location_2nd/Util/Util.dart';
import "package:test_location_2nd/DateHandler.dart";
import 'package:test_location_2nd/global.dart';
//TODO : make navigation to day page
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:intl/intl.dart';

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
            child: AllWheelScrollView(2022, startYear).build(buildContext)),
      ),
    );
  }
}

class AllWheelScrollView {
  int endYear = DateTime.now().year;
  int startYear = DateTime.now().year;
  int numberOfYears = 1;
  AllWheelScrollView(@required int endYear, @required int startYear) {
    this.endYear = endYear;
    this.startYear = startYear;
    this.numberOfYears = endYear - startYear + 1;
  }

  @override
  Widget build(BuildContext buildContext) {
    return ListView.builder(
        key: PageStorageKey<String>("month page"),
        itemCount: numberOfYears,
        itemBuilder :(context, index){
                return YearArray(endYear - index).build(buildContext);} );
  }
}

class YearArray {
  int year = DateTime.now().year;
  int numberOfYears = 1;
  YearArray(@required int year) {
    this.year = year;
    this.numberOfYears = year + 1;
  }

  final ScrollController _controller = ScrollController(keepScrollOffset: true
      // initialScrollOffset: monthPageScrollOffset,
      );
  @override
  void initState() {
    _controller.addListener(() {
      print(_controller.offset);
    });
  }

  @override
  void dispose() {
    monthPageScrollOffset = _controller.offset;
    print("monthPageScrollOffset : $monthPageScrollOffset");
    _controller.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    return Stack(
      children: [
        Positioned(
          left: physicalWidth / 6,
          top: physicalHeight / 3,
          child: RotatedBox(
              quarterTurns: 3,
              child: _scaleFactor > 1
                  ? Text("")
                  : Text(
                      DateFormat("yyyy").format(DateTime(year)),
                      style: TextStyle(fontSize: 25),
                    )),
        ),
        Column(
            children: List.generate(
                DateTime.monthsPerYear,
                (int index) =>
                    MonthArray(year, (DateTime.december - index - 1) % 12)
                        .build(buildContext)))
      ],
    );
  }
}

class MonthArray {
  int month = 1;
  int numberOfWeek = 4;
  int year = DateTime.now().year;
  MonthArray(@required int year, @required int month) {
    this.year = year;
    this.month = month + 1;
    this.numberOfWeek = weekNumber(DateTime(year, this.month + 1, 0)) -
        weekNumber(DateTime(year, this.month, 1));
  }

  @override
  Widget build(BuildContext buildContext) {
    return Stack(children: [
      Positioned(
        left: physicalWidth / 4,
        top: physicalHeight / 70 * 3,
        child: RotatedBox(
            quarterTurns: 3,
            child: _scaleFactor < 1
                ? Text("")
                : Text(DateFormat("MMM").format(DateTime(year, month)))),
      ),
      Column(
          // children : [],
          children: List.generate(
              numberOfWeek + 1,
              (int index) => WeekRow(year, month, numberOfWeek - index)
                  .build(buildContext))),
    ]);
  }
}

class WeekRow {
  int year = DateTime.now().year;
  int month = 1;
  int weekIndex = 1;
  WeekRow(@required int year, @required month, @required index) {
    this.year = year;
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
                  DayButton(year, month, weekIndex, index).build(buildContext))
          // Text('a', textScaleFactor: _scaleFactor))
          ),
    );
  }
}

class DayButton {
  int year = DateTime.now().year;
  int day = 1;
  int weekIndex = 1;
  int month = 1;
  int start = 1;
  late DateTime today;

  DayButton(
    @required year,
    @required month,
    @required weekIndex,
    @required day,
  ) {
    this.year = year;
    this.month = month;
    this.weekIndex = weekIndex;
    this.day = day;

    this.start = DateTime(year, month, 1).weekday;
    this.today = DateTime(year, month, (weekIndex) * 7 + day + 1 - start);
  }

  double width = physicalHeight / 70.0;
  double height = physicalHeight / 70.0;

  Future animation() async {
    return await Future.delayed(const Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext buildContext) {
    bool isValidDate = today.month == month;
    return isValidDate
        ? SizedBox(
            width: width * _scaleFactor,
            height: height * _scaleFactor,
            child: RawMaterialButton(
              onPressed: () async {
                selectedDate = today;
                print("selectedDate : $selectedDate");
                buildContext
                    .read<NavigationIndexProvider>()
                    .setNavigationIndex(1);
                buildContext
                    .read<NavigationIndexProvider>()
                    .setDate(selectedDate);
                // Provider.of<NavigationIndexProvider>(buildContext, listen: false).date = DateFormat("yyyyMMdd").format(today);
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
                      (summaryOfGooglePhotoData[formatDate(today)]) / 50)
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
