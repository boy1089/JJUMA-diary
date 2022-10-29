import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:test_location_2nd/Photo/GooglePhotoDataManager.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import 'package:test_location_2nd/Photo/LocalPhotoDataManager.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
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
import 'package:test_location_2nd/Util/global.dart';
import 'dart:math';
import 'package:test_location_2nd/Photo/LocalPhotoDataManager.dart';
import 'package:flutter/gestures.dart';

class DayPage extends StatefulWidget {
  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  PhotoLibraryApiClient photoLibraryApiClient;
  DataManager dataManager;
  GooglePhotoDataManager googlePhotoDataManager;
  SensorDataManager sensorDataManager;
  LocalPhotoDataManager localPhotoDataManager;

  @override
  State<DayPage> createState() => _DayPageState();

  DayPage(
      this.googleAccountManager,
      this.permissionManager,
      this.photoLibraryApiClient,
      this.dataManager,
      this.googlePhotoDataManager,
      this.sensorDataManager,
      this.localPhotoDataManager,
      {Key? key})
      : super(key: key);
}

class _DayPageState extends State<DayPage> {
  late GoogleAccountManager googleAccountManager;
  late PermissionManager permissionManager;
  late PhotoLibraryApiClient photoLibraryApiClient;
  late DataManager dataManager;
  late GooglePhotoDataManager googlePhotoDataManager;
  late SensorDataManager sensorDataManager;
  late LocalPhotoDataManager localPhotoDataManager;

  List response = [];
  dynamic photoResponseModified = [];
  dynamic sensorDataModified = [];
  dynamic localPhotoDataForPlot = [[]];
  dynamic sensorDataForPlot = [[]];

  List<dynamic> googlePhotoLinks = [];
  List<dynamic> localPhotoLinks = [];
  List<DateTime> datesOfYear =
      getDaysInBetween(DateTime.parse("${startYear}0101"), DateTime.now())
          .reversed
          .toList();
  Future readData = Future.delayed(const Duration(seconds: 1));
  Future update = Future.delayed(const Duration(seconds: 1));
  List imagesForPlot = [];
  List<List<dynamic>> photoDataForPlot = [[]];

  @override
  void initState() {
    super.initState();
    googleAccountManager = widget.googleAccountManager;
    permissionManager = widget.permissionManager;
    photoLibraryApiClient = widget.photoLibraryApiClient;
    dataManager = widget.dataManager;
    googlePhotoDataManager = widget.googlePhotoDataManager;
    sensorDataManager = widget.sensorDataManager;
    localPhotoDataManager = widget.localPhotoDataManager;
    update = updateUi();
    print("DayPage, after initState : ${photoDataForPlot}");
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
  bool isZoomInImageVisible = false;
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
            backgroundColor: kBackGroundColor,
            body: !snapshot.hasData
                ? Center(
                    child: SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          strokeWidth: 10,
                        )))
                : RawGestureDetector(
              behavior: HitTestBehavior.opaque,

              gestures: {
                      AllowMultipleGestureRecognizer:
                          GestureRecognizerFactoryWithHandlers<
                              AllowMultipleGestureRecognizer>(
                        () => AllowMultipleGestureRecognizer(),
                        (AllowMultipleGestureRecognizer instance) {
                          instance.onTapUp = (details) {
                            var dx = details.globalPosition.dx -
                                physicalWidth / 2 -
                                20;
                            var dy = details.globalPosition.dy -
                                physicalHeight / 2 -
                                50;

                            angleZoomIn = isZoomIn
                                ? angleZoomIn - dy / 6 / physicalHeight
                                : -atan2(dy / sqrt(dx * dx + dy * dy),
                                        dx / sqrt(dx * dx + dy * dy)) /
                                    (2 * pi) *
                                    0.96;
                            print("$dx, $dy, $angleZoomIn");

                            isZoomIn = true;
                            isZoomInImageVisible = true;
                            left = leftPositionZoomIn;
                            top = topPositionZoomIn;
                            magnification = magnificationZoomIn;
                            _angle = angleZoomIn;
                            Provider.of<NavigationIndexProvider>(context,
                                    listen: false)
                                .setZoomInRotationAngle(_angle);
                            setState(() {});
                            // indexForZoomInImage = -1;
                          };
                        },
                      )
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

                                  PolarPhotoDataPlot(photoDataForPlot)
                                      .build(context),
                                  // PolarPhotoDataPlot(imagesForPlot)
                                  //     .build(context),

                                  // polarPhotoImageContainers(imagesForPlot).build(context),
                                  polarPhotoImageContainers(imagesForPlot)
                                      .build(context),
                                  // ZoomInImageContainer(isZoomInImageVisible, imagesForPlot).build(context),

                                  // Container(
                                  //   width: 3000,
                                  //   height: 3000,
                                  //   child: Card(
                                  //       color: Colors.transparent,
                                  //       elevation: 0.0),
                                  // )
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

    bool isProcessedSensorFileExists = await File(
            "/storage/emulated/0/Android/data/com.example.test_location_2nd/files/processedSensorData/${formatDate(date2)}_processedSensor.csv")
        .exists();

    googlePhotoLinks = [];
    imagesForPlot = [];
    photoDataForPlot = [];
    localPhotoDataForPlot = [[]];

    try {
      var a = await updatePhoto();
      imagesForPlot = selectImagesForPlot(photoDataForPlot);
    } catch (e) {
      print("while updating Ui, error is occrued, google photo : $e");
    }
    try {
      var b = await updatePhotoFromLocal();
      imagesForPlot = selectImagesForPlot(localPhotoDataForPlot);
    } catch (e) {
      print("while updating Ui, error is occrued : $e");
    }

    updateSensorData();

    setState(() {});
    //convert data type..
    photoDataForPlot = List<List>.generate(
        imagesForPlot.length, (index) => imagesForPlot.elementAt(index));
    print("updateUi done");
  }

  List selectImagesForPlot(List input) {
    print("selectImageForPlot : ${input}");
    if (input[0] == null) {
      return imagesForPlot;
    }

    print(input);
    if (input[0].length == 0) {
      return imagesForPlot;
    }

    imagesForPlot.add(input.first);
    imagesForPlot.add(input.last);
    int j = 0;
    for (int i = 0; i < input.length; i++) {
      print("selectImagesForPlot, ${i}, ${imagesForPlot}, ${input}");
      if ((input[i][0] - imagesForPlot[j][0]).abs() >
          kMinimumTimeDifferenceBetweenImages) {
        imagesForPlot.add(input[i]);
        j += 1;
      }
    }
    print("selectImagesForPlot, $imagesForPlot}");

    return imagesForPlot;
  }

  Future updatePhoto() async {
    String date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    response =
        await this.googlePhotoDataManager.getPhoto(photoLibraryApiClient, date);
    print("updatePhoto");
    photoResponseModified =
        modifyListForPlot(response, executeTranspose: true, filterTime: true);

    photoDataForPlot = photoResponseModified;
    print("dataForPlot : $photoDataForPlot");
    googlePhotoLinks = transpose(photoDataForPlot).elementAt(1);
    print("googlePhotoLinks : $googlePhotoLinks");
    googlePhotoDataManager.writePhotoResponse(date, response);
    dataManager.updateSummaryOfPhotoData(date, googlePhotoLinks.length);
    return googlePhotoLinks;
  }

  Future updatePhotoFromLocal() async {
    String date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    List<List<dynamic>> files =
        await localPhotoDataManager.getPhotoOfDate(date);
    localPhotoDataForPlot = modifyListForPlot(transpose(files));
    localPhotoLinks = transpose(localPhotoDataForPlot);
    dataManager.updateSummaryOfPhotoData(date, localPhotoLinks.length);
    // photoDataForPlot.addAll(localPhotoDataForPlot);
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
