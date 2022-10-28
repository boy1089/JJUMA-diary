import 'package:flutter/material.dart';
import 'package:googleapis/cloudbuild/v1.dart';
import 'package:graphic/graphic.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:test_location_2nd/Util/global.dart';
//TODO : make navigation to day page
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:intl/intl.dart';
import 'package:circular_motion/circular_motion.dart';
import 'dart:ui' as ui;

class MonthPage extends StatefulWidget {
  int index = 0;
  DataManager dataManager;

  @override
  State<MonthPage> createState() => _MonthPageState();

  MonthPage(this.index, this.dataManager, {Key? key}) : super(key: key);
}

double _scaleFactor = 2.0;
double _baseScaleFactor = 2.0;

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
      // backgroundColor: kBackGroundColor,
      body: Center(
        child: Container(
            // color: kBackGroundColor,
            child: GestureDetector(
                onScaleStart: (details) {
                  _scaleFactor = _baseScaleFactor;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    print(_scaleFactor);
                    if(_scaleFactor > 0.18)
                      _scaleFactor = _baseScaleFactor * details.scale/5;
                  });
                },
                onDoubleTap: () {
                  setState(() {
                    if (_scaleFactor > _baseScaleFactor * 4) {
                      _scaleFactor = _baseScaleFactor;
                    } else {
                      _scaleFactor = _scaleFactor * 1.5;
                    }
                  });
                },
                child:
                    AllWheelScrollView(2022, startYear).build(buildContext)

            )),
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
    // return CircularMotion.builder(
    //       key: PageStorageKey<String>("month page"),
    //       itemCount: numberOfYears,
    //       builder: (context, index) {
    //         return YearArray(endYear - index).build(buildContext);
    //       });
    // );
    //
    return ListView.builder(
        key: PageStorageKey<String>("month page"),
        itemCount: numberOfYears,
        itemBuilder: (context, index) {
          return YearArray(endYear - index).build(buildContext);
        });
    //

    // return ListWheelScrollView.useDelegate(
    //   itemExtent: 1200,
    //   perspective : 0.00001,
    //   squeeze: 1.2,
    //   offAxisFraction: 5.0,
    //   childDelegate: ListWheelChildBuilderDelegate(
    //       childCount: 5,
    //       builder: (BuildContext buildContext, int index) {
    //         // return YearArray(endYear - index).build(buildContext);
    //         return YearArray(endYear - index).build(buildContext);
    //       }),
    // );
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
    return Stack(alignment: Alignment.center, children: [
      // Positioned(
      //   // left: physicalWidth / 4 - physicalHeight / 70.0 * _scaleFactor*3 + 50,
      //   left: physicalWidth / 4 - physicalHeight / 70.0 * _scaleFactor*3 + 50,
      //   // top: physicalHeight / 70 * 3.5 - physicalHeight / 70.0 * _scaleFactor * 3 + 30,
      //   child: RotatedBox(
      //       quarterTurns: 3,
      //       child: _scaleFactor < 1
      //           ? Text("")
      //           : Text(DateFormat("MMM").format(DateTime(year, month)),
      //       textScaleFactor: _scaleFactor/4 +1),
      //   ),
      // ),
      Positioned(
        child: Text(DateFormat("MMM").format(DateTime(year, month)),
            textScaleFactor: _scaleFactor * 2,
            style:
                TextStyle(color: Colors.black54, fontStyle: FontStyle.normal)),
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
              child: Text("${today.day}", style: TextStyle(fontSize: 10),),
              constraints: BoxConstraints(
                  minWidth: width * _scaleFactor,
                  minHeight: height * _scaleFactor,
                  maxWidth: width * _scaleFactor + 1.0,
                  maxHeight: height * _scaleFactor + 1.0),
              elevation: 1.0,
              fillColor: summaryOfPhotoData.containsKey(formatDate(today))
                  // ? Color.lerp(Colors.white, Colors.yellowAccent,
                  //     (summaryOfGooglePhotoData[formatDate(today)] ) / 50)
                  ? Color.lerp(
                      kMainColor_cool.withAlpha(200),
                      kMainColor_warm.withAlpha(180),
                      // Color.fromARGB(150, 140, 192, 222),
                      // Color.fromARGB(150, 244, 191, 191),
                      // Color.fromARGB(150, 242, 215, 217),
                      // Color.fromARGB(150, 156, 180, 204),
                      (summaryOfPhotoData[formatDate(today)]) / 50,
                    )
                  : Colors.white.withAlpha(150),
              shape: CircleBorder(

                  // side : BorderSide.lerp(BorderSide(color:kBackGroundColor, width : 5), BorderSide(color:Colors.blueGrey, width: 5),
                  //   summaryOfPhotoData.containsKey(formatDate(today))
                  //     ?(summaryOfPhotoData[formatDate(today)]) / 50
                  // : 1)
                  ),
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
