import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/Note/NoteManager.dart';
import 'package:lateDiary/StateProvider/navigation_index_state_provider.dart';
import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/StateProvider/day_page_state_provider.dart';

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
                  yearPageStateProvider
                      .setAvailableDates(int.parse(date.substring(0, 4)));
                  Provider.of<DayPageStateProvider>(context, listen: false)
                      .setAvailableDates(yearPageStateProvider.availableDates);
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
                        "${formateDate2(formatDateString(date))}",
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
