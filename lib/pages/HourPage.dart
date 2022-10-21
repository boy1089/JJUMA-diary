import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_location_2nd/DateHandler.dart';
import 'package:test_location_2nd/GooglePhotoDataManager.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';
import 'package:test_location_2nd/StateProvider.dart';
import 'package:test_location_2nd/Util/Util.dart';
import '../Sensor/SensorDataReader.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/Util/responseParser.dart';
import 'package:test_location_2nd/PolarSensorDataPlot.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:graphic/graphic.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:test_location_2nd/polarPhotoImageContainer.dart';
import 'package:test_location_2nd/PolarPhotoDataPlot.dart';
import 'package:test_location_2nd/global.dart';
import 'dart:math';

class HourPage extends StatefulWidget {
  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  PhotosLibraryApiClient photoLibraryApiClient;
  DataManager dataManager;
  GooglePhotoDataManager googlePhotoDataManager;
  SensorDataManager sensorDataManager;

  @override
  State<HourPage> createState() => _HourPageState();

  HourPage(
      this.googleAccountManager,
      this.permissionManager,
      this.photoLibraryApiClient,
      this.dataManager,
      this.googlePhotoDataManager,
      this.sensorDataManager,
      {Key? key})
      : super(key: key);
}

class _HourPageState extends State<HourPage> {
  late GoogleAccountManager googleAccountManager;
  late PermissionManager permissionManager;
  late PhotosLibraryApiClient photoLibraryApiClient;
  late DataManager dataManager;
  late GooglePhotoDataManager googlePhotoDataManager;
  late SensorDataManager sensorDataManager;

  List response = [];
  dynamic photoResponseModified = [];
  dynamic sensorDataModified = [];
  dynamic googlePhotoDataForPlot = [[]];
  dynamic sensorDataForPlot = [[]];

  List<dynamic> googlePhotoLinks = [];
  List<DateTime> datesOfYear =
      getDaysInBetween(DateTime.parse("${startYear}0101"), DateTime.now())
          .reversed
          .toList();
  Future readData = Future.delayed(const Duration(seconds: 1));
  Future update = Future.delayed(const Duration(seconds: 1));
  List imagesForPlot = [];

  @override
  void initState() {
    super.initState();
    googleAccountManager = widget.googleAccountManager;
    permissionManager = widget.permissionManager;
    photoLibraryApiClient = widget.photoLibraryApiClient;
    dataManager = widget.dataManager;
    googlePhotoDataManager = widget.googlePhotoDataManager;
    sensorDataManager = widget.sensorDataManager;
    // update = updateUi();
    print("DayPage, after initState : ${googlePhotoDataForPlot}");

    double leftPositionZoomIn = -graphBackgroundWidth * (3 / 4);
    left = leftPositionZoomOut;
    top = topPositionZoomOut;
  }

  var left = 200.0;
  double top = 0;
  bool isZoomIn = false;
  double magnification = 1;
  double _angle = 0;
  int animationTime = 200;
  double leftPositionZoomOut = 30.7;
  double leftPositionZoomIn = -700;
  double topPositionZoomOut = 105.7;
  double topPositionZoomIn = 105.7;
  double magnificationZoomIn = 3;
  double magnificationZoomOut = 1;
  double angleZoomIn = 0;
  double angleZoomOut = 0;
  double firstContainerSize = 1000;
  double graphBackgroundWidth = 350;
  double graphBackgroundHeight = 350;

  @override
  Widget build(BuildContext context) {
    var date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    print("date : $date");
    return Scaffold(
      body: GestureDetector(
        onTapUp: (details){
          // print(details.globalPosition);
          var dx = details.globalPosition.dx  - physicalWidth/2;
          var dy = details.globalPosition.dy - physicalHeight/2;

          angleZoomIn = - atan2(dy / sqrt(dx*dx + dy*dy) , dx/ sqrt(dx*dx + dy*dy)) / (2*pi);

          print("$dx, $dy, $angleZoomIn");

          isZoomIn = !isZoomIn;
          left = isZoomIn ? leftPositionZoomIn : leftPositionZoomOut;
          top = isZoomIn ? topPositionZoomIn : topPositionZoomOut;
          magnification =
          isZoomIn ? magnificationZoomIn : magnificationZoomOut;
          _angle = isZoomIn? angleZoomIn: angleZoomOut;
          setState((){});
          },
        // onTap: () {
        //   print('aaa');
        //   setState(() {
        //     print('tapped');
        //     isZoomIn = !isZoomIn;
        //     left = isZoomIn ? leftPositionZoomIn : leftPositionZoomOut;
        //     top = isZoomIn ? topPositionZoomIn : topPositionZoomOut;
        //     magnification =
        //         isZoomIn ? magnificationZoomIn : magnificationZoomOut;
        //     _angle = angleZoomOut;
        //   });
        // },
        child: Container(
          width: firstContainerSize,
          height: firstContainerSize,
          child: Stack(alignment: Alignment.center, children: [
            AnimatedPositioned(
              width: graphBackgroundWidth * magnification,
              height: graphBackgroundHeight * magnification,
              duration: Duration(milliseconds: animationTime),
              left: left,
              // top : top,
              curve: Curves.fastOutSlowIn,
              child: AnimatedRotation(
                  turns: _angle,
                  duration: Duration(milliseconds: animationTime-100),
                  child: Stack(
                    children: [
                      PolarSensorDataPlot(sensorDataForPlot[0].length == 0
                              ? dummyData
                              : sensorDataForPlot)
                          .build(context),
                      Container(
                        width: 1000,
                        height: 1000,
                        child:
                            Card(color: Colors.transparent, elevation: 0.0),
                      )
                    ],
                  )),
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(physicalScreenSize);
        },
      ),
    );
  }
}
