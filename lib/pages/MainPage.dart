import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import '../navigation.dart';
import 'package:test_location_2nd/pages/SettingPage.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'MonthPage.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/StateProvider.dart';
import 'package:test_location_2nd/GooglePhotoDataManager.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';
import 'HourPage.dart';
import 'package:glob/glob.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
//TODO : make consistency on datetime handling - datetime or date?
//TODO : formatting list for chart data

class MainPage extends StatefulWidget {
  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  PhotosLibraryApiClient photoLibraryApiClient;
  DataManager dataManager;
  GooglePhotoDataManager googlePhotoDataManager;
  SensorDataManager sensorDataManager;

  MainPage(
      this.googleAccountManager,
      this.permissionManager,
      this.photoLibraryApiClient,
      this.dataManager,
      this.googlePhotoDataManager,
      this.sensorDataManager,
      {Key? key})
      : super(key: key);

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  var response;
  late GoogleAccountManager googleAccountManager;
  late PermissionManager permissionManager;
  late PhotosLibraryApiClient photoLibraryApiClient;
  late DataManager dataManager;
  late GooglePhotoDataManager googlePhotoDataManager;
  late SensorDataManager sensorDataManager;

  int dataIndex = 0;
  List<List<String>> responseResult = [];
  Future readData = Future.delayed(const Duration(seconds: 1));

  List<Widget> _widgetOptions = [];
  int a = 0;
  late MonthPage monthPage;
  late HourPage hourPage;

  @override
  void initState() {
    readData = _fetchData();
    super.initState();
    googleAccountManager = widget.googleAccountManager;
    permissionManager = widget.permissionManager;
    photoLibraryApiClient = widget.photoLibraryApiClient;
    dataManager = widget.dataManager;
    googlePhotoDataManager = widget.googlePhotoDataManager;
    sensorDataManager = widget.sensorDataManager;

    MonthPage monthPage = MonthPage(a, dataManager);
    HourPage hourPage = HourPage(googleAccountManager,
        permissionManager,
        photoLibraryApiClient,
        dataManager,
        googlePhotoDataManager,
        sensorDataManager);

    _widgetOptions = <Widget>[
      monthPage,
      hourPage,
    ];
  }

  Future<List<List<dynamic>>> _fetchData() async {
    await Future.delayed(const Duration(seconds: 2));
    // return dataReader.readFiles();
    return [[]];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationIndexProvider>(context, listen: false)
            .setNavigationIndex(0);
        return Navigator.canPop(context);
      },
      child: Scaffold(
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
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    child: const Icon(Icons.settings_outlined,
                        color: Colors.black54)))
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined), label: "Month"),
            // BottomNavigationBarItem(
            //     icon: Icon(Icons.calendar_today), label: "Day"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: "Day"),
          ],
          currentIndex:
              context.watch<NavigationIndexProvider>().navigationIndex,
          onTap: (index) {
            Provider.of<NavigationIndexProvider>(context, listen: false)
                .setNavigationIndex(index);
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
                return PageTransitionSwitcher(
                  duration: Duration(milliseconds: 1000),
                  transitionBuilder:
                      (child, primaryAnimation, secondaryAnimation) =>
                          FadeThroughTransition(
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  ),
                  child: _widgetOptions[
                      context.watch<NavigationIndexProvider>().navigationIndex],
                );
              }
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // permissionManager.getStoragePermission();
            permissionManager.getAudioPermission();
            permissionManager.getStoragePermission();
            permissionManager.getLocationPermission();

          },
        ),
      ),
    );
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
