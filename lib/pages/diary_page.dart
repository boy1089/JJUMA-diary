import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jjuma.d/Util/Util.dart';
import 'package:jjuma.d/Util/DateHandler.dart';
import 'package:jjuma.d/Util/global.dart' as global;
import 'package:jjuma.d/Note/note_manager.dart';
import 'package:jjuma.d/StateProvider/navigation_index_state_provider.dart';
import 'package:jjuma.d/StateProvider/year_page_state_provider.dart';

class DiaryPage extends StatefulWidget {
  NoteManager noteManager;

  @override
  State<DiaryPage> createState() => _DiaryPageState();

  DiaryPage(this.noteManager, {Key? key}) : super(key: key);
}

class _DiaryPageState extends State<DiaryPage> {
  late NoteManager noteManager;

  @override
  void initState() {
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
                onPressed: () {
                  var provider = Provider.of<NavigationIndexProvider>(context,
                      listen: false);
                  var yearPageStateProvider =
                      Provider.of<YearPageStateProvider>(context,
                          listen: false);

                  provider.setNavigationIndex(navigationIndex.day);
                  provider.setDate(formatDateString(date));
                  // yearPageStateProvider
                  //     .setAvailableDates(int.parse(date.substring(0, 4)));

                },
                // padding: EdgeInsets.all(5),
                child: Container(
                  margin: EdgeInsets.all(5),
                  width: physicalWidth,
                  color:
                      global.kColor_container, //Colors.black12.withAlpha(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${formatDate2(formatDateString(date))}",
                        style: Theme.of(context).textTheme.subtitle1),
                      Text(
                        "${noteManager.notes[date]}",
                        style: Theme.of(context).textTheme.bodyText1
                      )
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
