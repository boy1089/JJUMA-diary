import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:test_location_2nd/Location/AddressFinder.dart';
import 'package:test_location_2nd/Location/LocationDataManager.dart';
import 'package:test_location_2nd/Util/global.dart';
import '../navigation.dart';
import 'package:test_location_2nd/pages/SettingPage.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'MonthPage.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';
import 'DayPage.dart';
import 'package:test_location_2nd/Photo/PhotoDataManager.dart';
import 'package:test_location_2nd/Note/NoteManager.dart';
import 'package:path_provider/path_provider.dart';
import 'DiaryPage.dart';
import 'YearPage.dart';

class MainPage extends StatefulWidget {
  PermissionManager permissionManager;
  DataManager dataManager;
  SensorDataManager sensorDataManager;
  PhotoDataManager localPhotoDataManager;
  NoteManager noteManager;

  MainPage(this.permissionManager, this.dataManager, this.sensorDataManager,
      this.localPhotoDataManager, this.noteManager,
      {Key? key})
      : super(key: key);

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  late PermissionManager permissionManager;
  late DataManager dataManager;
  late SensorDataManager sensorDataManager;
  late PhotoDataManager localPhotoDataManager;
  late NoteManager noteManager;

  int dataIndex = 0;
  List<List<String>> responseResult = [];
  Future readData = Future.delayed(const Duration(seconds: 1));

  List<Widget> _widgetOptions = [];
  int a = 0;
  late DayPage dayPage;

  @override
  void initState() {
    readData = _fetchData();
    super.initState();
    permissionManager = widget.permissionManager;
    dataManager = widget.dataManager;
    sensorDataManager = widget.sensorDataManager;
    localPhotoDataManager = widget.localPhotoDataManager;
    noteManager = widget.noteManager;

    // YearPage yearPage = YearPage(dataManager);
    YearPage yearPage = YearPage();
    DayPage hourPage = DayPage(permissionManager, dataManager,
        sensorDataManager, localPhotoDataManager, noteManager);
    DiaryPage diaryPage = DiaryPage(dataManager, noteManager);
    AndroidSettingsScreen androidSettingsScreen =
        AndroidSettingsScreen(permissionManager);

    _widgetOptions = <Widget>[
      // monthPage,
      yearPage,
      diaryPage,
      hourPage,
      androidSettingsScreen,
    ];
  }

  Future<List<List<dynamic>>> _fetchData() async {
    await Future.delayed(const Duration(seconds: 2));
    // return dataReader.readFiles();
    return [[]];
  }

  @override
  Widget build(BuildContext context) {
    print("build MainPage");
    var provider = Provider.of<NavigationIndexProvider>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        switch (provider.navigationIndex) {
          case 0:
            if (provider.isZoomIn) {
              setState(() {
                provider.setZoomInState(false);
                provider.setZoomInRotationAngle(0);
                // provider.isZoomIn = false;
              });
            }
            break;
          case 1:
            provider.setNavigationIndex(0);
            break;
          case 2:
            //when zoomed in, make daypage zoom out
            // provider.setZoomInState(false);
            indexForZoomInImage = -1;
            isImageClicked = false;

            if (provider.isZoomIn) {
              setState(() {
                provider.setZoomInState(false);
                provider.setZoomInRotationAngle(0);
              });
            }

            if (provider.lastNavigationIndex == 1) {
              provider.setNavigationIndex(provider.lastNavigationIndex);
              break;
            }
            //when zoomed out, go to month page
            if (!provider.isZoomIn) {
              provider.setNavigationIndex(0);
              // provider.setZoomInState(true);
              setState((){});
              return Navigator.canPop(context);
            }

            break;
        }
        return Navigator.canPop(context);
      },
      child: Scaffold(
        backgroundColor: kBackGroundColor,
        bottomNavigationBar: Offstage(
          offstage: !provider.isBottomNavigationBarShown,
          child: SizedBox(
            height: 30,
            // width : 200,
            child: BottomNavigationBar(
              selectedFontSize: 0,
              type: BottomNavigationBarType.fixed,
              items: const <BottomNavigationBarItem>[
                const BottomNavigationBarItem(
                    icon: Icon(Icons.photo_camera_back_outlined),
                    label: "Photo"),
                const BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark), label: "Diary"),
                const BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: "Settings"),
                // BottomNavigationBarItem(
                //     icon: Icon(Icons.settings_accessibility, color: Colors.black,), label: "Settings")

                // BottomNavigationBarItem(
                //     icon: Icon(Icons.circle_outlined), label: "Circle"),
              ],
              currentIndex:
                  // 2,
              Provider.of<NavigationIndexProvider>(context, listen: true).navigationIndex,
              onTap: (index) {
                onTap(context, index);
              },
            ),
          ),
        ),

        body: FutureBuilder(
            future: readData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              // print(
              //     "value from provider : ${context.watch<NavigationIndexProvider>().navigationIndex}");
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
                  child:
                  // _widgetOptions[2]
                    _widgetOptions[
                    Provider.of<NavigationIndexProvider>(context, listen: false).navigationIndex],
                );
              }
            }),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () async {
        //     // await AddressFinder.getAddressFromExif(localPhotoDataManager.files[0]);
        //     // var locationDataManager = LocationDataManager();
        //     // await locationDataManager.init();
        //     // dataManager.init();
        //     // dataManager.locationDataManager.getCoordinatesOfDate("20221022");
        //     print(summaryOfLocationData);
        //   },
        // ),
      ),
    );
  }

  void onTap(BuildContext context, int item) {
    debugPrint(item.toString());
    var provider = Provider.of<NavigationIndexProvider>(context, listen: false);
    switch (item) {
      case 0:
        provider.setNavigationIndex(0);
        provider.setBottomNavigationBarShown(true);
        break;
      case 1:
        print('bottom navigation bar 1 clicked');
        provider.setNavigationIndex(1);
        break;
      case 2:
        Navigation.navigateTo(
            context: context,
            screen: AndroidSettingsScreen(permissionManager),
            style: NavigationRouteStyle.material);
    }
  }
}
