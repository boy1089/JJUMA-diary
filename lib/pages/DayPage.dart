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
class DayPage extends StatefulWidget {
  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  PhotosLibraryApiClient photoLibraryApiClient;
  DataManager dataManager;
  GooglePhotoDataManager googlePhotoDataManager;
  SensorDataManager sensorDataManager;

  @override
  State<DayPage> createState() => _DayPageState();

  DayPage(
      this.googleAccountManager,
      this.permissionManager,
      this.photoLibraryApiClient,
      this.dataManager,
      this.googlePhotoDataManager,
      this.sensorDataManager,
      {Key? key})
      : super(key: key);
}

class _DayPageState extends State<DayPage> {
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
  Future<List<dynamic>> _fetchData() async {
    await Future.delayed(const Duration(microseconds: 100));
    await updateUi();
    return googlePhotoLinks;
  }

  @override
  void initState() {
    super.initState();
    googleAccountManager = widget.googleAccountManager;
    permissionManager = widget.permissionManager;
    photoLibraryApiClient = widget.photoLibraryApiClient;
    dataManager = widget.dataManager;
    googlePhotoDataManager = widget.googlePhotoDataManager;
    sensorDataManager = widget.sensorDataManager;
    readData = _fetchData();
    update = updateUi();
    print("DayPage, after initState : ${googlePhotoDataForPlot}");
  }

  @override
  Widget build(BuildContext context) {
    var date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    print("date : $date");
    return FutureBuilder(
        future: readData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: physicalHeight / 2 * 1.2,
                    width: physicalWidth,
                    child: !snapshot.hasData
                        ? Center(
                            child: SizedBox(
                                width: 140,
                                height: 140,
                                child: CircularProgressIndicator(
                                  strokeWidth: 10,
                                )))
                        : Stack(alignment: Alignment.center, children: [
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: kSecondPolarPlotSize,
                              height: kSecondPolarPlotSize,
                              child: PolarSensorDataPlot(
                                      sensorDataForPlot[0].length == 0
                                          ? dummyData
                                          : sensorDataForPlot)
                                  .build(context),
                            ),
                            polarPhotoImageContainers(imagesForPlot).build(),
                            PolarPhotoDataPlot(googlePhotoDataForPlot)
                                .build(context),
                          ])),
                Center(
                  child: SizedBox(
                      width: physicalWidth,
                      height: 50,
                      //reference : https://www.youtube.com/watch?v=wnTYKJEJ7f4&t=167s
                      child: ListWheelScrollView.useDelegate(
                          controller: FixedExtentScrollController(
                              initialItem:
                                  datesOfYear.indexOf(DateTime.parse(date))),
                          // magnification: 1,

                          squeeze: 1.8,
                          physics: const FixedExtentScrollPhysics(),
                          diameterRatio: 0.7,

                          onSelectedItemChanged: (index) => setState(() {
                                context
                                    .read<NavigationIndexProvider>()
                                    .setDate(datesOfYear[index]);

                                update = updateUi();
                              }),
                          itemExtent: 80,
                          restorationId: "aa",
                          childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) => Center(
                                    child: Text(
                                        DateFormat("yyyyMMdd")
                                            .format(datesOfYear[index]),
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black54)),
                                  ),
                              childCount: datesOfYear.length))),
                ),
              ],
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

    var a = await updatePhoto();
    // setState(() {
    //   if (isProcessedSensorFileExists) {
    //     openSensorData(
    //         "/storage/emulated/0/Android/data/com.example.test_location_2nd/files/processedSensorData/${formatDate(date2)}_processedSensor.csv");
    //   } else {
    //     updateSensorData();
    //   }
    // }
    // );
    print("updateUi");
    setState(() {});
    imagesForPlot = selectImagesForPlot();
  }

  List selectImagesForPlot() {
    if (googlePhotoDataForPlot[0].length == 0) {
      return [];
    }
    imagesForPlot = [googlePhotoDataForPlot.first, googlePhotoDataForPlot.last];
    int j = 0;
    for (int i = 0; i < googlePhotoDataForPlot.length; i++) {
      if ((googlePhotoDataForPlot[i][0] - imagesForPlot[j][0]).abs() > 1.7) {
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
    print("sensorDataForPlot : $googlePhotoDataForPlot");

    sensorDataManager.writeSensorData(date, sensorDataModified);
  }
}
