import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lateDiary/Data/infoFromFile.dart';
import 'package:lateDiary/Util/Util.dart';
import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

import '../../../Util/DateHandler.dart';
import '../model/event.dart';

class PhotoCard extends StatefulWidget {
  Event event;
  bool isMagnified = false;
  double height = 100;
  int scrollIndex = 0;

  PhotoCard({
    this.isMagnified = false,
    this.height = 100,
    this.scrollIndex = 0,
    required this.event,
  });
  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  String note = "";

  int scrollIndex = 0;
  FocusNode focusNode = FocusNode();
  DateTime dateTime = DateTime.now();
  TextEditingController controller = TextEditingController();

  _PhotoCardState() {
    // scrollIndex = widget.scrollIndex;
  }

  @override
  Widget build(BuildContext context) {
    FixedExtentScrollController scrollController1 =
        FixedExtentScrollController();
    FixedExtentScrollController scrollController2 =
        FixedExtentScrollController();

    dateTime = widget.event.images.entries.first.value.datetime!;

    return Column(
      children: [
        SizedBox(
            height: widget.isMagnified ? physicalWidth : widget.height,
            width: widget.isMagnified ? physicalWidth : widget.height,
            child: Padding(
                padding:
                    widget.isMagnified ? EdgeInsets.zero : EdgeInsets.all(1.0),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: ListWheelScrollView(
                      onSelectedItemChanged: (index) {
                        if (this.scrollIndex == index) return;
                        scrollController2.animateToItem(index,
                            duration: Duration(milliseconds: 100),
                            curve: Curves.easeIn);
                        this.scrollIndex = index;
                        setState(() {});
                        // scrollController2.jumpToItem(index);
                      },
                      controller: scrollController1,
                      physics: PageScrollPhysics(),
                      diameterRatio: 200,
                      itemExtent:
                          widget.isMagnified ? physicalWidth : widget.height,
                      children: List.generate(
                          widget.event.images.entries.length,
                          (index) => Center(
                                child: RotatedBox(
                                    quarterTurns: 1,
                                    child: SizedBox(
                                      height: widget.isMagnified
                                          ? physicalWidth
                                          : widget.height - 2,
                                      width: widget.isMagnified
                                          ? physicalWidth
                                          : widget.height - 2,
                                      child: ExtendedImage.file(
                                        File(widget.event.images.entries
                                            .elementAt(index)
                                            .key),
                                        cacheRawData: true,
                                        compressionRatio: 0.1,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                              ))),
                ))),
        if (widget.isMagnified)
          Container(
            height: 50,
            width: physicalWidth,
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
                                      compressionRatio: 0.01,
                                    )),
                              ))),
                )),
          ),
        //
        if (widget.isMagnified)
          Container(
              width: physicalWidth,
              height: 18,
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      DateText(dateTime: dateTime),
                    ],
                  ))),
        if (widget.isMagnified)
          Container(
            height: 100,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: EditableText(
                  maxLines: 5,
                  controller: controller,
                  focusNode: focusNode,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  // onChanged: (value){controller.text = value;},
                  cursorColor: Colors.black,
                  backgroundCursorColor: Colors.grey),
            ),
          )
      ],
    );
  }

  @override
  void dispose() async {
    if (!widget.isMagnified) {
      super.dispose();
      return;
    }
    super.dispose();

    Directory directory = await getApplicationDocumentsDirectory();
    String path = "${directory.path}/event/event.json";
    File file = File(path);

    //to write
    // id, date, info Of files, note
    if (!await file.exists()) await file.create(recursive: true);

    var a = Map.fromIterables(
        widget.event.images.keys,
        List.generate(widget.event.images.values.length,
            (index) => widget.event.images.values.elementAt(index).toString()));
    Map b = {
      '$dateTime': {'infoFromFile': a, 'note': controller.text}
    };
    await file.writeAsString(jsonEncode(b));
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
      "${DateFormat('yyyy').format(dateTime)} "
      "${DateFormat('h a').format(dateTime)}",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}
