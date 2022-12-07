import 'package:flutter/material.dart';
import 'package:lateDiary/Data/data_manager_interface.dart';
import 'package:lateDiary/Data/data_repository.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/pages/setting_page.dart';
import 'package:lateDiary/Note/note_manager.dart';
import '../diary_page.dart';
import '../YearPage/year_page_screen.dart';
import '../DayPage/day_page.dart';
import 'main_page_view_android.dart';
import 'main_page_view_ios.dart';

class MainPage extends StatefulWidget {
  static String id = 'main';

  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  NoteManager noteManager = NoteManager();
  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();

    YearPageScreen yearPageView = YearPageScreen();
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
  //
  @override
  Widget build(BuildContext context) {
    if (global.kOs == "android")
      return MainPageViewAndroid(context, _widgetOptions);
    else
      return MainPageViewIos(context, _widgetOptions);
  }

  // @override
  // Widget build(BuildContext context){
  //   return Scaffold(body : Center(child: Text("AA")),
  //   floatingActionButton: FloatingActionButton(
  //     onPressed: () async {
  //       var b = DataRepository();
  //       // var infoFromfiles = b.infoFromFiles;
  //       // print(infoFromfiles.entries.elementAt(0));
  //       var infoFromFiles = await b.readInfoFromJson();
  //
  //     },
  //   ),
  //   );
  // }

}
