import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/androidenterprise/v1.dart';
import 'package:googleapis/vision/v1.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Util/global.dart';
import 'package:test_location_2nd/Util/responseParser.dart';
import '../navigation.dart';
import 'package:test_location_2nd/pages/SettingPage.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'MonthPage.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:test_location_2nd/Photo/GooglePhotoDataManager.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';
import 'DayPage.dart';
//TODO : make consistency on datetime handling - datetime or date?
//TODO : formatting list for chart data
import 'package:test_location_2nd/Photo/LocalPhotoDataManager.dart';
import 'CirclePage.dart';
import 'package:test_location_2nd/Note/NoteManager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart' as PermissionHandler;

class MainPage extends StatefulWidget {
  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  PhotoLibraryApiClient photoLibraryApiClient;
  DataManager dataManager;
  GooglePhotoDataManager googlePhotoDataManager;
  SensorDataManager sensorDataManager;
  LocalPhotoDataManager localPhotoDataManager;
  NoteManager noteManager;

  MainPage(
      this.googleAccountManager,
      this.permissionManager,
      this.photoLibraryApiClient,
      this.dataManager,
      this.googlePhotoDataManager,
      this.sensorDataManager,
      this.localPhotoDataManager,
      this.noteManager,
      {Key? key})
      : super(key: key);

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  var response;
  late GoogleAccountManager googleAccountManager;
  late PermissionManager permissionManager;
  late PhotoLibraryApiClient photoLibraryApiClient;
  late DataManager dataManager;
  late GooglePhotoDataManager googlePhotoDataManager;
  late SensorDataManager sensorDataManager;
  late LocalPhotoDataManager localPhotoDataManager;
  late NoteManager noteManager;

  int dataIndex = 0;
  List<List<String>> responseResult = [];
  Future readData = Future.delayed(const Duration(seconds: 1));

  List<Widget> _widgetOptions = [];
  int a = 0;
  late MonthPage monthPage;
  late DayPage dayPage;

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
    localPhotoDataManager = widget.localPhotoDataManager;
    noteManager = widget.noteManager;

    MonthPage monthPage = MonthPage(a, dataManager);
    DayPage hourPage = DayPage(
        googleAccountManager,
        permissionManager,
        photoLibraryApiClient,
        dataManager,
        googlePhotoDataManager,
        sensorDataManager,
        localPhotoDataManager,
        noteManager);
    CirclePage circlePage = CirclePage();

    _widgetOptions = <Widget>[
      monthPage,
      hourPage,
      circlePage,
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
        var provider =
            Provider.of<NavigationIndexProvider>(context, listen: false);
        //when zoomed out, go to month page
        indexForZoomInImage = -1;
        isImageClicked = false;
        if (!provider.isZoomIn) {
          provider.setNavigationIndex(0);
          return Navigator.canPop(context);
        }

        //when zoomed in, make daypage zoom out
        // provider.setZoomInState(false);
        setState(() {
          provider.setZoomInState(false);
          provider.setZoomInRotationAngle(0);
          provider.isZoomIn = false;
        });
        return Navigator.canPop(context);
      },
      child: Scaffold(
        backgroundColor: kBackGroundColor,
        // appBar: AppBar(
        //   title: const Center(
        //     child: Text(
        //       "         Late Diary",
        //       style: TextStyle(color: Colors.black54),
        //     ),
        //   ),
        //   backgroundColor: Colors.white,
        //   actions: [
        //     Padding(
        //         padding: const EdgeInsets.only(right: 20.0),
        //         child: GestureDetector(
        //             onTap: () {
        //               Navigator.pushNamed(context, '/settings');
        //             },
        //             child: const Icon(Icons.settings_outlined,
        //                 color: Colors.black54)))
        //   ],
        // ),
        bottomNavigationBar: Offstage(
          offstage: true,
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined), label: "Month"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined), label: "Day"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.circle_outlined), label: "Circle"),
            ],
            currentIndex:
                context.watch<NavigationIndexProvider>().navigationIndex,
            onTap: (index) {
              Provider.of<NavigationIndexProvider>(context, listen: false)
                  .setNavigationIndex(index);
            },
          ),
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
            dataManager.updateSummaryFromLocal2();
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
