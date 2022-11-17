import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:test_location_2nd/Location/AddressFinder.dart';
import 'package:test_location_2nd/Location/LocationDataManager.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import '../navigation.dart';
import 'package:test_location_2nd/pages/SettingPage.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';
import 'DayPage.dart';
import 'package:test_location_2nd/Photo/PhotoDataManager.dart';
import 'package:test_location_2nd/Note/NoteManager.dart';
import 'DiaryPage.dart';
import 'YearPageView.dart';
import 'DayPageView.dart';

import 'package:test_location_2nd/StateProvider/YearPageStateProvider.dart';
import 'package:test_location_2nd/StateProvider/DayPageStateProvider.dart';
import 'package:test_location_2nd/StateProvider/NavigationIndexStateProvider.dart';
import 'package:test_location_2nd/Data/Directories.dart';

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
    noteManager = widget.noteManager;

    YearPageView yearPageView = YearPageView();
    DayPageView dayPageView = DayPageView();

    DiaryPage diaryPage = DiaryPage(noteManager);
    AndroidSettingsScreen androidSettingsScreen =
        AndroidSettingsScreen(permissionManager);

    _widgetOptions = <Widget>[
      yearPageView,
      diaryPage,
      dayPageView,
      androidSettingsScreen,
    ];
  }

  Future<int> _fetchData() async {
    print("initialization : ${global.isInitializationDone}");
    while (!global.isInitializationDone) {
      print("initialization on going..");
      await Future.delayed(const Duration(seconds: 1));
    }
    await Future.delayed(const Duration(seconds: 1));
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    print("build MainPage");
    var provider = Provider.of<NavigationIndexProvider>(context, listen: false);
    var dayPageStateProvider =
        Provider.of<DayPageStateProvider>(context, listen: false);
    var yearPageStateProvider =
        Provider.of<YearPageStateProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        print("back button pressed : ${provider.navigationIndex}");
        switch (provider.navigationIndex) {
          case 0:
            if (yearPageStateProvider.isZoomIn) {
              setState(() {
                yearPageStateProvider.setZoomInState(false);
                yearPageStateProvider.setZoomInRotationAngle(0);
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
            global.indexForZoomInImage = -1;
            global.isImageClicked = false;

            if (dayPageStateProvider.isZoomIn) {
              setState(() {
                dayPageStateProvider.setZoomInState(false);
                dayPageStateProvider.setZoomInRotationAngle(0);
              });
            }

            if (provider.lastNavigationIndex == 1) {
              provider.setNavigationIndex(provider.lastNavigationIndex);
              break;
            }
            //when zoomed out, go to month page
            if (!dayPageStateProvider.isZoomIn) {
              provider.setNavigationIndex(0);
              return Navigator.canPop(context);
            }
            break;
        }
        return Navigator.canPop(context);
      },
      child: Scaffold(
        body: FutureBuilder(
            future: readData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              print("building MAinPage.. ${snapshot.hasData}");
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
                      _widgetOptions[Provider.of<NavigationIndexProvider>(
                              context,
                              listen: false)
                          .navigationIndex],
                );
              }
            }),
        backgroundColor: global.kBackGroundColor,
        bottomNavigationBar: Offstage(
          offstage: !provider.isBottomNavigationBarShown,
          child: SizedBox(
            height: global.kBottomNavigationBarHeight,
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
              ],
              currentIndex:
                  Provider.of<NavigationIndexProvider>(context, listen: true)
                      .navigationIndex,
              onTap: (index) {
                onTap(context, index);
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Stopwatch stopwatch = Stopwatch()..start();
            print(Directories.selectedDirectories);
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

//
// Class testData {
//   String
// }