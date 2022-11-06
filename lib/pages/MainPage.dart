import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
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
import 'package:test_location_2nd/Photo/LocalPhotoDataManager.dart';
import 'package:test_location_2nd/Note/NoteManager.dart';
import 'package:path_provider/path_provider.dart';
import 'DiaryPage.dart';
import 'YearPage.dart';

class MainPage extends StatefulWidget {
  PermissionManager permissionManager;
  DataManager dataManager;
  SensorDataManager sensorDataManager;
  LocalPhotoDataManager localPhotoDataManager;
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
    permissionManager = widget.permissionManager;
    dataManager = widget.dataManager;
    sensorDataManager = widget.sensorDataManager;
    localPhotoDataManager = widget.localPhotoDataManager;
    noteManager = widget.noteManager;

    MonthPage monthPage = MonthPage(a, dataManager);
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
                provider.isZoomIn = false;
              });
            }

            if (provider.lastNavigationIndex == 1) {
              provider.setNavigationIndex(provider.lastNavigationIndex);
              break;
            }
            //when zoomed out, go to month page
            if (!provider.isZoomIn) {
              provider.setNavigationIndex(0);
              return Navigator.canPop(context);
            }
            break;
        }
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
          offstage: !provider.isBottomNavigationBarShown,
          child: SizedBox(
            height: 30,
            // width : 200,
            child: BottomNavigationBar(
              selectedFontSize: 0,
              type: BottomNavigationBarType.fixed,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.photo_camera_back_outlined),
                    label: "Photo"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark), label: "Diary"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: "Settings"),
                // BottomNavigationBarItem(
                //     icon: Icon(Icons.settings_accessibility, color: Colors.black,), label: "Settings")

                // BottomNavigationBarItem(
                //     icon: Icon(Icons.circle_outlined), label: "Circle"),
              ],
              currentIndex:
                  context.watch<NavigationIndexProvider>().navigationIndex,
              onTap: (index) {
                onTap(context, index);
              },
            ),
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
            // localPhotoDataManager.test();
            await localPhotoDataManager.init();
            // dataManager.updateSummaryOfLocalPhoto2();
            // print(summaryOfPhotoData['20220312']);
            },
        ),
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
