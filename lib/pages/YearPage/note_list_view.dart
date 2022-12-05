import 'package:flutter/material.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/Util/layouts.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/StateProvider/NavigationIndexStateProvider.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/StateProvider/DayPageStateProvider.dart';

import '../../StateProvider/YearPageStateProvider.dart';

class NoteListView extends StatelessWidget {
  bool isZoomIn;
  Map<String, String> notes;
  NoteListView({required this.isZoomIn, required this.notes});

  @override
  Widget build(BuildContext context) {

    return AnimatedContainer(
        duration: Duration(milliseconds: global.animationTime),
        curve: global.animationCurve,
        height: layout_yearPage['textHeight'][isZoomIn],
        child: ListView.builder(
            itemCount: notes.length,
            itemBuilder: (BuildContext buildContext, int index) {
              String date = notes.keys.elementAt(index);
              return MaterialButton(
                onPressed: () {
                  var provider = Provider.of<NavigationIndexProvider>(context,
                      listen: false);
                  YearPageStateProvider product =
                  Provider.of<YearPageStateProvider>(context, listen: false);
                  provider.setNavigationIndex(navigationIndex.day);
                  provider.setDate(formatDateString(date));
                  Provider.of<DayPageStateProvider>(context, listen: false)
                      .setAvailableDates(product.availableDates);
                },
                child: Container(
                  margin: EdgeInsets.all(5),
                  width: physicalWidth,
                  color: global.kColor_container,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${formateDate2(formatDateString(date))}",
                          style: Theme.of(context).textTheme.subtitle1),
                      Text("${notes[date]}",
                          style: Theme.of(context).textTheme.bodyText1)
                    ],
                  ),
                ),
              );
            }));
  }
}
