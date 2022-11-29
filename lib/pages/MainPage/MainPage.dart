import 'package:flutter/material.dart';
import 'package:lateDiary/Util/global.dart' as global;
import '../../navigation.dart';
import 'package:lateDiary/pages/SettingPage.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/Note/NoteManager.dart';
import '../DiaryPage.dart';
import '../YearPage/YearPage.dart';
import '../DayPage/DayPage.dart';
import 'package:lateDiary/StateProvider/NavigationIndexStateProvider.dart';
import 'MainPageViewAndroid.dart';
import 'MainPageViewIos.dart';

class MainPage extends StatefulWidget {
  static String id = 'main';

  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  NoteManager noteManager = NoteManager();
  List<Widget> _widgetOptions = [];

  var navigationProvider;
  var dayPageStateProvider;
  var yearPageStateProvider;

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
    if(global.kOs=="android")
      return MainPageViewAndroid(context, _widgetOptions);
    else
      return MainPageViewIos(context, _widgetOptions);
  }

}

