import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/StateProvider/StateProvider.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:intl/intl.dart';
import 'package:test_location_2nd/Note/NoteManager.dart';
import 'package:test_location_2nd/StateProvider/DayPageStateProvider.dart';
import 'package:test_location_2nd/StateProvider/NavigationIndexStateProvider.dart';

class DiaryPage extends StatefulWidget {
  DataManager dataManager;
  NoteManager noteManager;

  @override
  State<DiaryPage> createState() => _DiaryPageState();

  DiaryPage(this.dataManager, this.noteManager, {Key? key}) : super(key: key);
}

class _DiaryPageState extends State<DiaryPage> {
  late DataManager dataManager;
  late NoteManager noteManager;

  @override
  void initState() {
    this.dataManager = widget.dataManager;
    this.noteManager = widget.noteManager;
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      // backgroundColor: Colors.black12.withAlpha(10),
      body: Center(
        child: ListView.builder(
            itemCount: noteManager.notes.length,
            itemBuilder: (BuildContext buildContext, int index) {
              String date = noteManager.notes.keys.elementAt(index);
              return MaterialButton(
                onPressed: (){
                  buildContext
                      .read<NavigationIndexProvider>()
                      .setDate(formatDateString(date));
                  buildContext
                      .read<NavigationIndexProvider>()
                      .setNavigationIndex(2);
                },
                // padding: EdgeInsets.all(5),
                child: Container(
                  margin : EdgeInsets.all(5),
                  width: physicalWidth,
                  color: global.kColor_container, //Colors.black12.withAlpha(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                   children : [
                     Text("${formateDate2(formatDateString(date))}",
                     style: TextStyle( fontWeight: global.kFontWeight_diaryTitle, color : global.kColor_diaryText),),
                   Text("${noteManager.notes[date]}",
                     style: TextStyle( fontWeight: global.kFontWeight_diaryContents, color : global.kColor_diaryText),)],
                  ),
                ),
                );
            }),
      ),

    );
  }
}
