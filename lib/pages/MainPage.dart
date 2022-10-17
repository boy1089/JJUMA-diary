import 'package:flutter/material.dart';
import 'package:googleapis/cloudbuild/v1.dart';
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
import 'dart:ui';
import 'WeekPage.dart';
import 'MonthPage.dart';
import 'DayPage.dart';
import 'package:test_location_2nd/global.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/StateProvider.dart';
import 'package:test_location_2nd/GooglePhotoManager.dart';
//TODO : put scroll wheel to select the date.
//TODO : get images from google album

class MainPage extends StatefulWidget {
  SensorDataReader dataReader;

  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  PhotosLibraryApiClient photoLibraryApiClient;
  DataManager dataManager;
  GooglePhotoManager googlePhotoManager;

  MainPage(this.dataReader, this.googleAccountManager, this.permissionManager,
      this.photoLibraryApiClient, this.dataManager, this.googlePhotoManager,
      {Key? key})
      : super(key: key);

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var response;
  late SensorDataReader dataReader;
  late GoogleAccountManager googleAccountManager;
  late PermissionManager permissionManager;
  late PhotosLibraryApiClient photoLibraryApiClient;
  late DataManager dataManager;
  late GooglePhotoManager googlePhotoManager;

  int dataIndex = 0;
  List<List<String>> responseResult = [];
  Future readData = Future.delayed(const Duration(seconds: 1));
  // Future<List<List<dynamic>>> readData;

  List<Widget> _widgetOptions = [];
  int a = 0;
  late MonthPage monthPage;
  late DayPage dayPage;

  @override
  void initState() {
    readData = _fetchData();
    super.initState();
    dataReader = widget.dataReader;
    googleAccountManager = widget.googleAccountManager;
    permissionManager = widget.permissionManager;
    photoLibraryApiClient = widget.photoLibraryApiClient;
    dataManager = widget.dataManager;
    googlePhotoManager = widget.googlePhotoManager;

    DayPage dayPage = DayPage(dataReader, googleAccountManager,
        permissionManager, photoLibraryApiClient, dataManager);
    WeekPage weekPage = WeekPage(dataReader, googleAccountManager,
        permissionManager, photoLibraryApiClient, dataManager);
    MonthPage monthPage = MonthPage(a);

    _widgetOptions = <Widget>[
      dayPage,
      weekPage,
      monthPage,
    ];
  }

  Future<List<List<dynamic>>> _fetchData() async {
    await Future.delayed(const Duration(seconds: 2));
    return dataReader.readFiles();
  }

  @override
  Widget build(BuildContext context) {
    // updatePhoto();
    // int currentIndexFromProvider = context.watch();
    // print("value from provider : ${context.watch<NavigationIndexProvider>().navigationIndex}");
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "         Auto Diary",
            style: TextStyle(color: Colors.black54),
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.settings_outlined,
                      color: Colors.black54)))
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "Day"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_view_week), label: "Week"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_view_month), label: "Month"),
        ],
        currentIndex: context.watch<NavigationIndexProvider>().navigationIndex,
        onTap: (index) {
          Provider.of<NavigationIndexProvider>(context, listen: false)
              .setIndex(index);

          // context.watch<NavigationIndexProvider>().setIndex(index);
        },
      ),
      body: FutureBuilder(
          future: readData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            print(
                "value from provider : ${context.watch<NavigationIndexProvider>().navigationIndex}");
            if (snapshot.hasData == false) {
              return Center(child: CircularProgressIndicator());
            } else {
              return _widgetOptions[
                  context.watch<NavigationIndexProvider>().navigationIndex];
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // var photoResponse = await googlePhotoManager.getPhoto(photoLibraryApiClient, "20221004");
          googlePhotoManager.getAndSaveAllPhoto(photoLibraryApiClient, "20220601", "20220831");

          // print(googlePhotoManager.photoResponseAll.keys);
          // print(googlePhotoManager.photoResponseAll);

        },
      ),
    );
  }

  void updatePhoto() async {
    String date = dataReader.dates[dataIndex];
    // if(response
    debugPrint(date.substring(4, 6));
    response = await photoLibraryApiClient.getPhotosOfDate(
        date.substring(0, 4), date.substring(4, 6), date.substring(6, 8));
    responseResult = parseResponse(response);
    photoLibraryApiClient.writeCache3(responseResult[0], 'links');
    photoLibraryApiClient.writeCache3(responseResult[1], 'filename');
    setState(() {});
    debugPrint("googleAccount manager : ${googleAccountManager.currentUser}");
  }

  void onSelected(BuildContext context, int item) {
    debugPrint(item.toString());
    switch (item) {
      case 0:
        Navigation.navigateTo(
            context: context,
            screen:
                AndroidSettingsScreen(googleAccountManager, permissionManager),
            style: NavigationRouteStyle.material);
        break;
    }
  }


}
