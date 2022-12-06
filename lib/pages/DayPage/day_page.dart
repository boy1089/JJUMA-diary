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
        duration : Duration(milliseconds: 600),
        curve : Curves.easeInOut,
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

    // body: CustomScrollView(
    //   controller: provider.scrollController,
    //   slivers: [
    //     SliverList(
    //         delegate: SliverChildBuilderDelegate(
    //       childCount: provider.listOfEventsInDay.entries.length,
    //       (BuildContext context, int index) {
    //         String date =
    //             provider.listOfEventsInDay.entries.elementAt(index).key;
    //         return Stack(
    //             key : keyList[index],
    //             children: [
    //           CardContainer(
    //               listOfEvents: provider.listOfEventsInDay.entries
    //                   .elementAt(index)
    //                   .value),
    //           Text(
    //               "${DateFormat('EEEE').format(DateTime.parse(date))}/"
    //               "${DateFormat('MMM').format(DateTime.parse(date))} "
    //               "${DateFormat('dd').format(DateTime.parse(date))}",
    //               style: TextStyle(
    //                   color: Colors.white,
    //                   fontWeight: FontWeight.w300,
    //                   fontSize: 25))
    //         ]);
  }
}

class PhotoCard extends StatelessWidget {
  Map<dynamic, InfoFromFile> event;
  bool isMagnified = false;
  double height = 100;
  PhotoCard({
    this.isMagnified = false,
    this.height = 100,
    required this.event,
  }) {
    controller.text = "date, time, address\nLeave your note here!";
  }
  int index = 0;
  FocusNode focusNode = FocusNode();
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisSize: MainAxisSize.max,
      // mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: isMagnified ? physicalWidth : height,
          width: isMagnified ? physicalWidth : height,
          child: Padding(
            padding: isMagnified ? EdgeInsets.all(8.0) : EdgeInsets.all(1.0),
            child: ExtendedImage.file(
              // File(filteredData.keys.toList().elementAt(index)),
              File(event.entries.elementAt(index).key),
              compressionRatio: 0.5,
              fit: BoxFit.cover,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              width: isMagnified ? physicalWidth / 2 : physicalWidth,
            ),
          ),
        ),
        if (isMagnified)
          Container(
            height: 50,
            width: physicalWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List<Widget>.generate(event.length, (index) {
                  return ExtendedImage.file(
                    File(event.entries.elementAt(index).key),
                    compressionRatio: 0.01,
                    loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          break;
                        case LoadState.completed:
                          return ExtendedRawImage(
                            image: state.extendedImageInfo?.image,
                          );
                      }
                    },
                  );
                }),
                // itemExtent: 3.0,
              ),
            ),
          ),
        if (isMagnified)
          Container(
            height: 200,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: EditableText(
                  controller: controller,
                  focusNode: focusNode,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  cursorColor: Colors.black,
                  backgroundCursorColor: Colors.grey),
            ),
          )
      ],
    );
  }
}

class CardContainer extends StatelessWidget {
  List<Map<dynamic, InfoFromFile>> listOfEvents;
  CardContainer({required this.listOfEvents});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: physicalWidth,
        // height: physicalWidth,
        color: Colors.black,
        child: Column(children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: (listOfEvents.length < 4)
                  ? List.generate(
                      listOfEvents.length,
                      (index) => ClickablePhotoCard(
                          photoCard: PhotoCard(
                              event: listOfEvents.elementAt(index),
                              isMagnified: false,
                              height: physicalWidth / listOfEvents.length)))
                  : [
                      Column(
                        children: [
                          ClickablePhotoCard(
                            photoCard: PhotoCard(
                                event: listOfEvents[0],
                                isMagnified: false,
                                height: physicalWidth / 4),
                          ),
                          ClickablePhotoCard(
                            photoCard: PhotoCard(
                                event: listOfEvents[1],
                                isMagnified: false,
                                height: physicalWidth / 4),
                          ),
                          ClickablePhotoCard(
                            photoCard: PhotoCard(
                                event: listOfEvents[2],
                                isMagnified: false,
                                height: physicalWidth / 4),
                          ),
                        ],
                      ),
                      ClickablePhotoCard(
                        photoCard: PhotoCard(
                            event: listOfEvents[3],
                            isMagnified: false,
                            height: physicalWidth / 4 * 3),
                      ),
                    ]),
          if (listOfEvents.length > 4)
            Row(
                children: List.generate(
              listOfEvents.length - 4,
              (index) => ClickablePhotoCard(
                photoCard: PhotoCard(
                    event: listOfEvents[index + 4],
                    isMagnified: false,
                    height: physicalWidth / 4),
              ),
            ))
        ]));
  }
}

class ClickablePhotoCard extends StatelessWidget {
  PhotoCard photoCard;
  ClickablePhotoCard({required this.photoCard});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                    children: [photoCard..isMagnified = true],
                  ));
        },
        child: photoCard);
  }
}
