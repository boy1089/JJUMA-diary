import 'package:flutter/material.dart';
import 'package:test_location_2nd/DateHandler.dart';
import 'package:test_location_2nd/GooglePhotoDataManager.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';
import 'package:test_location_2nd/StateProvider.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/PolarSensorDataPlot.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
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
    update = updateUi();
    print("DayPage, after initState : ${googlePhotoDataForPlot}");
    readData = _fetchData();
    double leftPositionZoomIn = -graphBackgroundWidth * (3 / 4);
    left = leftPositionZoomOut;
    top = topPositionZoomOut;
  }

  Future<List<dynamic>> _fetchData() async {
    await updateUi();
    return googlePhotoLinks;
  }

  var left = 200.0;
  double top = 0;
  bool isZoomIn = false;
  double magnification = 1;
  double _angle = 0;
  int animationTime = 200;
  double leftPositionZoomOut = 30.7;
  double leftPositionZoomIn = -2000; // mag5 : -1400, mag7, -2000
  double topPositionZoomOut = 105.7;
  double topPositionZoomIn = 105.7;
  double magnificationZoomIn = 7;
  double magnificationZoomOut = 1;
  double angleZoomIn = 0;
  double angleZoomOut = 0;
  double firstContainerSize = 1000;
  double graphBackgroundWidth = 350;
  double graphBackgroundHeight = 350;
  double angleZoomInModify = 0;
  @override
  Widget build(BuildContext context) {
    var date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    print("date : $date");

    return FutureBuilder(
        future: readData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
            body: !snapshot.hasData
                ? Center(
                    child: SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          strokeWidth: 10,
                        )))
                : GestureDetector(
                    onTapUp: (details) {
                      var dx = details.globalPosition.dx - physicalWidth / 2;
                      var dy = details.globalPosition.dy - physicalHeight / 2;

                      angleZoomIn = isZoomIn

                      ? angleZoomIn - dy/4 / physicalHeight
                      :-atan2(dy / sqrt(dx * dx + dy * dy),
                          dx / sqrt(dx * dx + dy * dy)) /
                          (2 * pi) * 0.98;
                      print("$dx, $dy, $angleZoomIn");

                      isZoomIn = true;
                      left = leftPositionZoomIn ;
                      top = topPositionZoomIn ;
                      magnification = magnificationZoomIn;
                      _angle =  angleZoomIn;
                      Provider.of<NavigationIndexProvider>(context,
                              listen: false)
                          .setZoomInRotationAngle(_angle);
                      setState(() {});
                    },
                onDoubleTap: (){

                  isZoomIn = false;
                  left =
                  isZoomIn ? leftPositionZoomIn : leftPositionZoomOut;
                  top = isZoomIn ? topPositionZoomIn : topPositionZoomOut;
                  magnification =
                  isZoomIn ? magnificationZoomIn : magnificationZoomOut;
                  _angle = isZoomIn ? angleZoomIn : angleZoomOut;
                  Provider.of<NavigationIndexProvider>(context,
                      listen: false)
                      .setZoomInRotationAngle(_angle);
                  setState(() {});
                },


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
                              duration:
                                  Duration(milliseconds: animationTime - 100),
                              child: Stack(
                                children: [
                                  PolarSensorDataPlot(
                                          sensorDataForPlot[0].length == 0
                                              ? dummyData
                                              : sensorDataForPlot)
                                      .build(context),

                                  PolarPhotoDataPlot(googlePhotoDataForPlot)
                                      .build(context),
                                  // polarPhotoImageContainers(imagesForPlot).build(context),
                                  polarPhotoImageContainers(imagesForPlot)
                                      .build(context),

                                  Container(
                                    width: 3000,
                                    height: 3000,
                                    child: Card(
                                        color: Colors.transparent,
                                        elevation: 0.0),
                                  )
                                ],
                              )),
                        ),
                      ]),
                    ),
                  ),
          );
        });
  }

  Future updateUi() async {
    var date2 = DateTime.parse(
        Provider.of<NavigationIndexProvider>(context, listen: false).date);
    bool isGooglePhotoFileExists = await File(
            "/storage/emulated/0/Android/data/com.example.test_location_2nd/files/googlePhotoData/${formatDate(date2)}_googlePhoto.csv")
        .exists();
    bool isProcessedSensorFileExists = await File(
            "/storage/emulated/0/Android/data/com.example.test_location_2nd/files/processedSensorData/${formatDate(date2)}_processedSensor.csv")
        .exists();

    print("isFileExists $isGooglePhotoFileExists");
    googlePhotoLinks = [];
    imagesForPlot = [];
    googlePhotoDataForPlot = [[]];

    try {
      var a = await updatePhoto();
    } catch (e) {
      print("while updating Ui, error is occrued : $e");
    }

    updateSensorData();

    setState(() {});
    imagesForPlot = selectImagesForPlot();
    print("updateUi done");
  }

  List selectImagesForPlot() {
    if (googlePhotoDataForPlot[0].length == 0) {
      return [];
    }
    imagesForPlot = [googlePhotoDataForPlot.first, googlePhotoDataForPlot.last];
    int j = 0;
    for (int i = 0; i < googlePhotoDataForPlot.length; i++) {
      if ((googlePhotoDataForPlot[i][0] - imagesForPlot[j][0]).abs() >
          kMinimumTimeDifferenceBetweenImages) {
        imagesForPlot.add(googlePhotoDataForPlot[i]);
        j += 1;
      }
    }

    return imagesForPlot;
  }

  void openFile(filepath) async {
    File f = File(filepath);
    debugPrint("CSV to List");
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    print("open file");
    googlePhotoDataForPlot = modifyListForPlot(fields, filterTime: true);
    print("googlePhotoDataForPlot : $googlePhotoDataForPlot");
    googlePhotoLinks = transpose(googlePhotoDataForPlot).elementAt(1);
  }

  Future updatePhoto() async {
    String date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    response =
        await this.googlePhotoDataManager.getPhoto(photoLibraryApiClient, date);
    print("updatePhoto");
    photoResponseModified =
        modifyListForPlot(response, executeTranspose: true, filterTime: true);

    googlePhotoDataForPlot = photoResponseModified;
    print("dataForPlot : $googlePhotoDataForPlot");
    googlePhotoLinks = transpose(googlePhotoDataForPlot).elementAt(1);
    print("googlePhotoLinks : $googlePhotoLinks");
    googlePhotoDataManager.writePhotoResponse(date, response);
    dataManager.updateSummaryOfGooglePhotoData(date, googlePhotoLinks.length);
    return googlePhotoLinks;
  }

  void openSensorData(filepath) async {
    File f = File(filepath);
    debugPrint("CSV to List");
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    sensorDataForPlot = modifyListForPlot(fields);
    print("sensorDataForPlot : $sensorDataForPlot");
  }

  void updateSensorData() async {
    String date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    var sensorData = await this.sensorDataManager.openFile(date);
    sensorDataModified = modifyListForPlot(subsampleList(sensorData, 50));
    sensorDataForPlot = sensorDataModified;
    print("sensorDataForPlot : $sensorDataForPlot");

    // sensorDataManager.writeSensorData(date, sensorDataModified);
  }
}
