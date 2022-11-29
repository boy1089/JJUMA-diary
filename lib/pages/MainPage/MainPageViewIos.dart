import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lateDiary/Util/global.dart' as global;
import '../../navigation.dart';
import 'package:lateDiary/pages/SettingPage.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/StateProvider/YearPageStateProvider.dart';
import 'package:lateDiary/StateProvider/DayPageStateProvider.dart';
import 'package:lateDiary/StateProvider/NavigationIndexStateProvider.dart';

class MainPageViewIos extends StatefulWidget {
  var context;
  var _widgetOptions;
  MainPageViewIos(this.context, this._widgetOptions);

  @override
  State<MainPageViewIos> createState() => _MainPageViewIosState();
}

class _MainPageViewIosState extends State<MainPageViewIos> {
  var navigationProvider;
  var dayPageStateProvider;
  var yearPageStateProvider;

  @override
  Widget build(BuildContext context) {
    navigationProvider =
        Provider.of<NavigationIndexProvider>(context, listen: true);
    dayPageStateProvider =
        Provider.of<DayPageStateProvider>(context, listen: false);
    yearPageStateProvider =
        Provider.of<YearPageStateProvider>(context, listen: true);

    bool offstage = offstageLogicForBackbutton();

    return Scaffold(
      floatingActionButton: Offstage(
        offstage: offstage,
        child: IconButton(
          icon: Icon(CupertinoIcons.arrow_left),
          onPressed: () => onBackButton(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      body: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            height: global.kBottomNavigationBarHeight,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.photo_camera_back_outlined)),
              BottomNavigationBarItem(icon: Icon(Icons.bookmark)),
              BottomNavigationBarItem(icon: Icon(Icons.settings)),
            ],
            onTap: (item) => onTap(context, navigationIndex.values[item]),
          ),
          tabBuilder: (context, index) {
            if (index == 2) index = 3;
            return  CupertinoTabView(
              builder : (context)=>widget._widgetOptions[
                        navigationProvider.currentNavigationIndex.index],
            );
          }),
    );
  }

  void onTap(BuildContext context, navigationIndex item) async {
    switch (item) {
      case navigationIndex.year:
        navigationProvider.setNavigationIndex(navigationIndex.year);
        break;
      case navigationIndex.diary:
        navigationProvider.setNavigationIndex(navigationIndex.diary);
        break;
      case navigationIndex.day:
        navigationProvider.setNavigationIndex(navigationIndex.setting);
        break;
    }
  }

  void onBackButton() {
    switch (navigationProvider.currentNavigationIndex) {
      case navigationIndex.year:
        if (yearPageStateProvider.isZoomIn) {
          setState(() {
            yearPageStateProvider.setZoomInState(false);
            yearPageStateProvider.setZoomInRotationAngle(0);
          });
        }
        break;
      case navigationIndex.diary:
        navigationProvider.setNavigationIndex(navigationIndex.year);
        break;
      case navigationIndex.day:
        //when zoomed in, make daypage zoom out
        global.indexForZoomInImage = -1;
        global.isImageClicked = false;

        if (dayPageStateProvider.isZoomIn) {
          setState(() {
            dayPageStateProvider.setZoomInState(false);
            dayPageStateProvider.setZoomInRotationAngle(0);
          });
        }

        if (navigationProvider.lastNavigationIndex == navigationIndex.diary) {
          navigationProvider
              .setNavigationIndex(navigationProvider.lastNavigationIndex);
          break;
        }
        //when zoomed out, go to month page
        if (!dayPageStateProvider.isZoomIn) {
          navigationProvider.setNavigationIndex(navigationIndex.year);
        }
        break;
    }
  }

  bool offstageLogicForBackbutton() {
    print(yearPageStateProvider.isZoomIn);
    if (navigationProvider.isZoomIn) return false;
    if (yearPageStateProvider.isZoomIn) return false;
    if (navigationProvider.currentNavigationIndex == navigationIndex.day)
      return false;
    return true;
  }
}
