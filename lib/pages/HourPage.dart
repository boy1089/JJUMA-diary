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

  Future<List<dynamic>> _fetchData() async {
    // await updateUi();

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
    // update = updateUi();
    print("DayPage, after initState : ${googlePhotoDataForPlot}");
  }
  var scaleFactor = 1;
  bool selected = false;
  @override
  Widget build(BuildContext context) {
    var date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    print("date : $date");
    return FutureBuilder(
        future: readData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(

            body: GestureDetector(
              onTap: (){
                setState((){selected = !selected;});
              },
              child: Container(
                width : 1000,
                height : 1000,
                child: Stack(
                  children: [AnimatedPositioned(
                    duration : Duration(milliseconds:300),
                  // top : selected? physicalWidth/1.2:physicalWidth/2,
                  left : selected?-600.0:0,

                    child: AnimatedContainer(
                      child: Card(shape: CircleBorder(),),
                      duration : Duration(milliseconds : 300),
                        width : selected? physicalWidth*2:physicalWidth,
                        height : selected? physicalHeight/1.2:physicalHeight/1.2,
                        color: Colors.black),
                  ),]
                ),
              ),
            ),

            floatingActionButton: FloatingActionButton(
              onPressed: (){

              },
            ),
          );
        });
  }

}
