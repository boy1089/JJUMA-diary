import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lateDiary/Data/data_manager_interface.dart';
import 'package:lateDiary/Util/Util.dart';
import 'dart:io';
import 'package:extended_image/extended_image.dart';

import '../../../Util/DateHandler.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:clickable_list_wheel_view/clickable_list_wheel_widget.dart';

import '../../event.dart';

class PhotoCard extends StatefulWidget {
  Event event;
  bool isMagnified = false;
  double height = 200;
  int scrollIndex = 0;
  bool isTickEnabled = false;
  String tag;
  String? filenameOfFavoriteImage = null;
  PhotoCard({
    this.isMagnified = false,
    this.height = 200,
    this.scrollIndex = 0,
    this.isTickEnabled = false,
    required this.tag,
    required this.event,
    this.filenameOfFavoriteImage,
  });
  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  int scrollIndex = 0;
  FocusNode focusNode = FocusNode();
  DateTime dateTime = DateTime.now();
  TextEditingController controller = TextEditingController();
  FixedExtentScrollController scrollController1 = FixedExtentScrollController();
  FixedExtentScrollController scrollController2 = FixedExtentScrollController();

  String? filenameOfFavoriteImage = null;
  int? indexOfFavoriteImage = null;
  @override
  void initState() {
    dateTime = widget.event.images.entries.elementAt(0).value.datetime!;
    var dataManager = DataManagerInterface(global.kOs);
    print("numberOfImages : ${widget.event.images.length}");

    if (dataManager.noteForChart2[dateTime.year.toString()]
            ?[formatDate(dateTime)] !=
        null)
      controller.text = dataManager.noteForChart2[dateTime.year.toString()]
              ?[formatDate(dateTime)] ??
          "";

    if (dataManager.filenameOfFavoriteImages[dateTime.year.toString()]
            ?[formatDate(dateTime)] !=
        null)
      filenameOfFavoriteImage =
          dataManager.filenameOfFavoriteImages[dateTime.year.toString()]
              ?[formatDate(dateTime)];

    final keyList =
        List.generate(widget.event.images.length, (index) => GlobalKey());

    filenameOfFavoriteImage = widget.filenameOfFavoriteImage;
    print(
        "index : ${widget.event.images.keys.toList().indexOf(filenameOfFavoriteImage)}");
    indexOfFavoriteImage =
        widget.event.images.keys.toList().indexOf(filenameOfFavoriteImage);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: 2000));
      Scrollable.ensureVisible(
        keyList[indexOfFavoriteImage != -1 ? indexOfFavoriteImage! : 0]
            .currentContext!,
        duration: Duration(milliseconds: 300),
        curve: Curves.bounceInOut,
      );
    });

    if (filenameOfFavoriteImage != null) {
      scrollController1 =
          FixedExtentScrollController(initialItem: indexOfFavoriteImage!);
      scrollController2 =
          FixedExtentScrollController(initialItem: indexOfFavoriteImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    dateTime = widget.event.images.entries.first.value.datetime!;
    return Hero(
      tag: widget.tag,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                mainPhotoListView(),
                if (widget.isMagnified) subPhotoListView(),
                if (widget.isMagnified) dateText(),
                if (widget.isMagnified) noteView()
              ],
            ),
          ),
        ),
      ),
    );
  }

  mainPhotoListView() {
    return SizedBox(
        height: physicalWidth,
        width: physicalWidth,
        child: RotatedBox(
          quarterTurns: -1,
          child: Stack(children: [
            ClickableListWheelScrollView(
              itemCount: widget.event.images.length,
              itemHeight: physicalWidth,
              scrollController: scrollController1,
              onItemTapCallback: (index) {
                setState(() {
                  print("tap");
                  if (filenameOfFavoriteImage == null) {
                    filenameOfFavoriteImage =
                        widget.event.images.keys.elementAt(index);
                    indexOfFavoriteImage = index;
                    return;
                  }
                  indexOfFavoriteImage = null;
                  filenameOfFavoriteImage = null;
                });
              },
              child: ListWheelScrollView(
                  onSelectedItemChanged: (index) {
                    if (this.scrollIndex == index) return;
                    scrollController2.animateToItem(index,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeIn);
                    this.scrollIndex = index;
                    setState(() {});
                  },
                  controller: scrollController1,
                  physics: PageScrollPhysics(),
                  scrollBehavior: MaterialScrollBehavior(),
                  diameterRatio: 200,
                  itemExtent: physicalWidth,
                  children: List.generate(
                      widget.event.images.entries.length,
                      (index) => Center(
                            child: RotatedBox(
                                quarterTurns: 1,
                                child: Stack(children: [
                                  SizedBox(
                                    height: physicalWidth,
                                    width: physicalWidth,
                                    child: ExtendedImage.file(
                                      File(widget.event.images.entries
                                          .elementAt(index)
                                          .key),
                                      cacheRawData: true,
                                      compressionRatio: 0.1,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                      right: 10.0,
                                      bottom: 10.0,
                                      child: indexOfFavoriteImage == index
                                          ? Icon(
                                              Icons.favorite,
                                              size: 32.0,
                                              color: Colors.red,
                                            )
                                          : Icon(
                                              Icons.favorite_outline_outlined,
                                              size: 32.0,
                                              color: Colors.red)),
                                  Positioned(
                                    left: 10.0,
                                    top: 10.0,
                                    child: Text(
                                      "${DateFormat('Hm').format(widget.event.images.entries.elementAt(index).value.datetime ?? DateTime.now())}",
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                ])),
                          ))),
            ),
          ]),
        ));
  }

  subPhotoListView() {
    return Container(
      height: 50,
      width: physicalWidth,
      margin: EdgeInsets.only(top: 8.0),
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: RotatedBox(
            quarterTurns: -1,
            child: ListWheelScrollView(
                // useMagnifier: true,
                // magnification: 2,
                controller: scrollController2,
                onSelectedItemChanged: (index) {
                  print("$index, ${this.scrollIndex}");

                  if (this.scrollIndex == index) return;
                  this.scrollIndex = index;
                  setState(() {});
                  scrollController1.jumpToItem(index);
                },
                diameterRatio: 200,
                itemExtent: 40,
                children: List.generate(
                    widget.event.images.entries.length,
                    (index) => Center(
                          child: RotatedBox(
                              quarterTurns: 1,
                              child: ExtendedImage.file(
                                File(widget.event.images.entries
                                    .elementAt(index)
                                    .key),
                                compressionRatio: 0.0003,
                              )),
                        ))),
          )),
    );
  }

  dateText() {
    return Container(
        width: physicalWidth,
        height: 20,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                DateText(dateTime: dateTime),
              ],
            )));
  }

  noteView() {
    return SizedBox(
      height: 100,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: EditableText(
            maxLines: 5,
            controller: controller,
            focusNode: focusNode,
            onChanged: (a) {
              print(controller.text);
            },
            style: TextStyle(
              // color: Colors.black,
              fontSize: 16.0,
            ),
            // onChanged: (value){controller.text = value;},
            cursorColor: Colors.black,
            backgroundCursorColor: Colors.grey),
      ),
    );
  }

  @override
  void dispose() async {
    print("dispose cards");
    print("${controller.text}, ${widget.isMagnified}");
    // if (!widget.isMagnified | (controller.text == "")) {
    //   print('cc');
    //   super.dispose();
    //   if (widget.isTickEnabled) timer?.cancel();
    //   return;
    // }
    super.dispose();
    // timer?.cancel();
    // widget.event.setNote(controller.text);
    DataManagerInterface dataManager = DataManagerInterface(global.kOs);
    // dataManager.addEvent(widget.event);
    // var a = Provider.of<YearPageStateProvider>(context, listen : false);
    dataManager.setNote(this.dateTime, controller.text);
    dataManager.setFilenameOfFavoriteImage(
        this.dateTime, filenameOfFavoriteImage);
  }
}

class DateText extends StatelessWidget {
  DateTime dateTime;
  DateText({required this.dateTime});

  factory DateText.fromString({required date}) {
    return DateText(dateTime: formatDateString(date));
  }
  @override
  Widget build(BuildContext context) {
    return Text(
      "${DateFormat('EEEE').format(dateTime)}/"
      "${DateFormat('MMM').format(dateTime)} "
      "${DateFormat('dd').format(dateTime)}/"
      "${DateFormat('yyyy').format(dateTime)} ",
      // "${DateFormat('h a').format(dateTime)}",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}
