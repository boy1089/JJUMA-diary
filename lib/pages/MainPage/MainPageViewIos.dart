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
        Provider.of<YearPageStateProvider>(context, listen: false);

    return  CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            height : global.kBottomNavigationBarHeight,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.photo_camera_back_outlined)),
              BottomNavigationBarItem(icon: Icon(Icons.bookmark)),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings)),
            ],
          ),
          tabBuilder: (context, index) {
            if (index == 2) index = 3;
            return widget._widgetOptions.elementAt(index);
          });

    // return Scaffold(
    //   body: PageTransitionSwitcher(
    //     duration: const Duration(milliseconds: 1000),
    //     transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
    //         FadeThroughTransition(
    //           animation: primaryAnimation,
    //           secondaryAnimation: secondaryAnimation,
    //           child: child,
    //         ),
    //     child:
    //     widget._widgetOptions[navigationProvider.currentNavigationIndex.index],
    //   ),
    //   backgroundColor: global.kBackGroundColor,
    //
    //
    //   bottomNavigationBar: Container(
    //     height: global.kBottomNavigationBarHeight,
    //     // width : 200,
    //     color: Colors.red,
    //     child: Offstage(
    //       offstage: !navigationProvider.isBottomNavigationBarShown,
    //       child: BottomNavigationBar(
    //         selectedFontSize: 0,
    //         type: BottomNavigationBarType.fixed,
    //         items: const <BottomNavigationBarItem>[
    //           BottomNavigationBarItem(
    //               icon: Icon(Icons.photo_camera_back_outlined),
    //               label: "Photo"),
    //           BottomNavigationBarItem(
    //               icon: Icon(Icons.bookmark), label: "Diary"),
    //           BottomNavigationBarItem(
    //               icon: Icon(Icons.settings), label: "Settings"),
    //         ],
    //         currentIndex: navigationProvider.currentNavigationIndex.index,
    //         onTap: (index) {
    //           onTap(context, navigationIndex.values[index]);
    //         },
    //       ),
    //     ),
    //   ),
    // );
  }

  void onTap(BuildContext context, navigationIndex item) {
    debugPrint(item.toString());
    var provider = Provider.of<NavigationIndexProvider>(context, listen: false);
    switch (item) {
      case navigationIndex.year:
        provider.setNavigationIndex(navigationIndex.year);
        provider.setBottomNavigationBarShown(true);
        break;
      case navigationIndex.diary:
        provider.setNavigationIndex(navigationIndex.diary);
        break;
      case navigationIndex.day:
        Navigation.navigateTo(
            context: context,
            screen: AndroidSettingsScreen(),
            style: NavigationRouteStyle.material);
    }
  }
}

//
// class _MainPageViewIosState extends State<MainPageViewIos> {
//   var navigationProvider;
//   var dayPageStateProvider;
//   var yearPageStateProvider;
//
//
//   @override
//   Widget build(BuildContext context) {
//     navigationProvider =
//         Provider.of<NavigationIndexProvider>(context, listen: true);
//     dayPageStateProvider =
//         Provider.of<DayPageStateProvider>(context, listen: false);
//     yearPageStateProvider =
//         Provider.of<YearPageStateProvider>(context, listen: false);
//     return Scaffold(
//       body: PageTransitionSwitcher(
//         duration: const Duration(milliseconds: 1000),
//         transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
//             FadeThroughTransition(
//               animation: primaryAnimation,
//               secondaryAnimation: secondaryAnimation,
//               child: child,
//             ),
//         child:
//         widget._widgetOptions[navigationProvider.currentNavigationIndex.index],
//       ),
//       backgroundColor: global.kBackGroundColor,
//       bottomNavigationBar: Container(
//         height: global.kBottomNavigationBarHeight,
//         // width : 200,
//         color: Colors.red,
//         child: Offstage(
//           offstage: !navigationProvider.isBottomNavigationBarShown,
//           child: BottomNavigationBar(
//             selectedFontSize: 0,
//             type: BottomNavigationBarType.fixed,
//             items: const <BottomNavigationBarItem>[
//               BottomNavigationBarItem(
//                   icon: Icon(Icons.photo_camera_back_outlined),
//                   label: "Photo"),
//               BottomNavigationBarItem(
//                   icon: Icon(Icons.bookmark), label: "Diary"),
//               BottomNavigationBarItem(
//                   icon: Icon(Icons.settings), label: "Settings"),
//             ],
//             currentIndex: navigationProvider.currentNavigationIndex.index,
//             onTap: (index) {
//               onTap(context, navigationIndex.values[index]);
//             },
//           ),
//         ),
//       ),
//     );
//   }
//   void onTap(BuildContext context, navigationIndex item) {
//     debugPrint(item.toString());
//     var provider = Provider.of<NavigationIndexProvider>(context, listen: false);
//     switch (item) {
//       case navigationIndex.year:
//         provider.setNavigationIndex(navigationIndex.year);
//         provider.setBottomNavigationBarShown(true);
//         break;
//       case navigationIndex.diary:
//         provider.setNavigationIndex(navigationIndex.diary);
//         break;
//       case navigationIndex.day:
//         Navigation.navigateTo(
//             context: context,
//             screen: AndroidSettingsScreen(),
//             style: NavigationRouteStyle.material);
//     }
//   }
// }
