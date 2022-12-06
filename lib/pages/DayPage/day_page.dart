import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:lateDiary/Data/DataManagerInterface.dart';
import 'package:lateDiary/Data/infoFromFile.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/app.dart';
import 'package:lateDiary/pages/DayPage/photo_card.dart';
import 'card_container.dart';
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
    // print(keyList);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: 1000));
      // provider.scrollController.animateTo(1000,
      //     duration: Duration(milliseconds: 500), curve: Curves.bounceInOut);
      Scrollable.ensureVisible(keyList[provider.indexOfDate].currentContext!,
        duration : Duration(milliseconds: 300),
        curve : Curves.bounceInOut,
      );
    });

    return Scaffold(
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
            controller: provider.scrollController,
            child: Column(
                children: List.generate(
                    provider.listOfEventsInDay.entries.length, (index) {
              String date =
                  provider.listOfEventsInDay.entries.elementAt(index).key;
              return Stack(key: keyList[index], children: [
                CardContainer(
                    listOfEvents: provider.listOfEventsInDay.entries
                        .elementAt(index)
                        .value),
                Text(
                    "${DateFormat('EEEE').format(DateTime.parse(date))}/"
                    "${DateFormat('MMM').format(DateTime.parse(date))} "
                    "${DateFormat('dd').format(DateTime.parse(date))}",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 25))
              ]);
            }))));

  }
}

