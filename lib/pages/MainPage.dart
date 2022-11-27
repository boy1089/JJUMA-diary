import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lateDiary/Util/global.dart' as global;
import '../navigation.dart';
import 'package:lateDiary/pages/SettingPage.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/Note/NoteManager.dart';
import 'DiaryPage.dart';
import 'YearPage/YearPage.dart';
import 'DayPage/DayPage.dart';

import 'package:lateDiary/StateProvider/YearPageStateProvider.dart';
import 'package:lateDiary/StateProvider/DayPageStateProvider.dart';
import 'package:lateDiary/StateProvider/NavigationIndexStateProvider.dart';

class MainPage extends StatefulWidget {
  static String id = 'main';

  MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  NoteManager noteManager = NoteManager();
  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();

    YearPage yearPageView = YearPage();
    DayPage dayPageView = DayPage();
    DiaryPage diaryPage = DiaryPage(noteManager);
    AndroidSettingsScreen androidSettingsScreen = AndroidSettingsScreen();

    _widgetOptions = <Widget>[
      yearPageView,
      diaryPage,
      dayPageView,
      androidSettingsScreen,
    ];
  }

  @override
  Widget build(BuildContext context) {
    var navigationProvider =
        Provider.of<NavigationIndexProvider>(context, listen: true);
    var dayPageStateProvider =
        Provider.of<DayPageStateProvider>(context, listen: false);
    var yearPageStateProvider =
        Provider.of<YearPageStateProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        print("back button pressed : ${navigationProvider.navigationIndex}");
        switch (navigationProvider.navigationIndex) {
          case 0:
            if (yearPageStateProvider.isZoomIn) {
              setState(() {
                yearPageStateProvider.setZoomInState(false);
                yearPageStateProvider.setZoomInRotationAngle(0);
              });
            }
            break;
          case 1:
            navigationProvider.setNavigationIndex(0);
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

            if (navigationProvider.lastNavigationIndex == 1) {
              navigationProvider
                  .setNavigationIndex(navigationProvider.lastNavigationIndex);
              break;
            }
            //when zoomed out, go to month page
            if (!dayPageStateProvider.isZoomIn) {
              navigationProvider.setNavigationIndex(0);
              return Navigator.canPop(context);
            }
            break;
        }
        return Navigator.canPop(context);
      },
      child: Scaffold(
        body: PageTransitionSwitcher(
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
                      _widgetOptions[navigationProvider.navigationIndex],
                ),
        backgroundColor: global.kBackGroundColor,
        bottomNavigationBar: SizedBox(
          height: global.kBottomNavigationBarHeight,
          // width : 200,
          child: Offstage(
            offstage: !navigationProvider.isBottomNavigationBarShown,
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
              currentIndex: navigationProvider.navigationIndex,
              onTap: (index) {
                onTap(context, index);
              },
            ),
          ),
        ),
      ),
    );
  }

  void onBackButton(event) {}

  void onTap(BuildContext context, int item) {
    debugPrint(item.toString());
    var provider = Provider.of<NavigationIndexProvider>(context, listen: false);
    switch (item) {
      case 0:
        provider.setNavigationIndex(0);
        provider.setBottomNavigationBarShown(true);
        break;
      case 1:
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

class MainPageView {
  @override
  Widget build(BuildContext context) {
    return Text('a');
  }
}
