import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:lateDiary/Data/data_manager_interface.dart';
import 'package:lateDiary/Data/data_repository.dart';
import 'package:lateDiary/Data/info_from_file.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/app.dart';
import 'package:lateDiary/pages/DayPage/widgets/photo_card.dart';
import 'widgets/card_container.dart';
import 'day_page_view.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/StateProvider/day_page_state_provider.dart';
import 'package:lateDiary/StateProvider/navigation_index_state_provider.dart';
import 'package:lateDiary/Util/global.dart' as global;

class DayPage extends StatefulWidget {
  DayPage({Key? key}) : super(key: key);

  @override
  State<DayPage> createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {
  double width = 100;
  String pathToClickedImage = "";

  @override
  Widget build(BuildContext context) {
    DayPageStateProvider provider =
        Provider.of<DayPageStateProvider>(context, listen: true);
    final keyList = List.generate(
        provider.listOfEventsInDay.entries.length, (index) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: 1000));
      Scrollable.ensureVisible(

        keyList[provider.indexOfDate>1? provider.indexOfDate-1:0].currentContext!,
        duration: Duration(milliseconds: 300),
        curve: Curves.bounceInOut,
      );
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
          controller: provider.scrollController,
          child: Column(
              children: List.generate(provider.listOfEventsInDay.entries.length,
                  (index) {
            String date =
                provider.listOfEventsInDay.entries.elementAt(index).key;
            return Stack(key: keyList[index], children: [
              CardContainer(
                  listOfEvents: provider.listOfEventsInDay.entries
                      .elementAt(index)
                      .value,
              isTickEnabled: index%5==0? true : false,),
              Text(
                  "${DateFormat('EEEE').format(DateTime.parse(date))}/"
                  "${DateFormat('MMM').format(DateTime.parse(date))} "
                  "${DateFormat('dd').format(DateTime.parse(date))}",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 25))
            ]);
          }))),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     var b = DataRepository();
      //     var c = await b.readEventList();
      //     // print(c.for);
      //   },
      // ),
    );
  }
  @override
  void dispose() {
    print("Disposing second route");
    super.dispose();
  }
}
