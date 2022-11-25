import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lateDiary/Util/global.dart' as global;
import '../navigation.dart';
import 'package:lateDiary/pages/SettingPage.dart';
import 'package:provider/provider.dart';
import 'DayPage.dart';
import 'package:lateDiary/Note/NoteManager.dart';
import 'DiaryPage.dart';
import 'YearPage.dart';
import 'DayPageView.dart';

import 'package:lateDiary/StateProvider/YearPageStateProvider.dart';
import 'package:lateDiary/StateProvider/DayPageStateProvider.dart';
import 'package:lateDiary/StateProvider/NavigationIndexStateProvider.dart';

class MainPage extends StatefulWidget {
  static String id = 'main';
  NoteManager noteManager;

  MainPage(this.noteManager, {Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  late NoteManager noteManager;

  Future readData = Future.delayed(const Duration(seconds: 1));

  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    readData = _fetchData();
    super.initState();
    noteManager = widget.noteManager;

    YearPage yearPageView = YearPage();
    DayPageView dayPageView = DayPageView();
    DiaryPage diaryPage = DiaryPage(noteManager);
    AndroidSettingsScreen androidSettingsScreen = AndroidSettingsScreen();

    _widgetOptions = <Widget>[
      yearPageView,
      diaryPage,
      dayPageView,
      androidSettingsScreen,
    ];
  }

  Future<int> _fetchData() async {
    while (!global.isInitializationDone) {
      print("initialization on going..");
      await Future.delayed(const Duration(seconds: 1));
    }
    await Future.delayed(const Duration(seconds: 1));
    return 0;
  }

  @override
  Widget build(BuildContext context) {
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
              });
            }
            break;
          case 1:
            provider.setNavigationIndex(0);
            break;
          case 2:
            //when zoomed in, make daypage zoom out
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
        bottomNavigationBar: SizedBox(
          height: global.kBottomNavigationBarHeight,
          // width : 200,
          child: Offstage(
            offstage: !provider.isBottomNavigationBarShown,
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
            screen: AndroidSettingsScreen(),
            style: NavigationRouteStyle.material);
    }
  }
}
