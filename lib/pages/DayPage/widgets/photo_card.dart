import 'package:flutter/material.dart';
import 'package:lateDiary/Data/infoFromFile.dart';
import 'package:lateDiary/Util/Util.dart';
import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'dart:math';

class PhotoCard extends StatefulWidget {
  Map<dynamic, InfoFromFile> event;
  bool isMagnified = false;
  double height = 100;

  PhotoCard({
    this.isMagnified = false,
    this.height = 100,
    required this.event,
  }) {}

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  String note = "";
  int index = 0;
  FocusNode focusNode = FocusNode();

  _PhotoCardState() {
    controller.text = "date, time, address\nLeave your note here!";
  }

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FixedExtentScrollController scrollController1 =
        FixedExtentScrollController();
    FixedExtentScrollController scrollController2 =
    FixedExtentScrollController();

    return Column(
      children: [
        SizedBox(
            height: widget.isMagnified ? physicalWidth : widget.height,
            width: widget.isMagnified ? physicalWidth : widget.height,
            child: Padding(
                padding: widget.isMagnified
                    ? EdgeInsets.all(0)
                    : EdgeInsets.all(1.0),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: ListWheelScrollView(
                      onSelectedItemChanged: (index) {
                        if(this.index == index) return;
                        scrollController2.animateToItem(index,
                            duration: Duration(milliseconds: 100),
                            curve: Curves.easeIn);
                        this.index = index;
                        setState(() {});
                        // scrollController2.jumpToItem(index);
                      },
                      controller: scrollController1,
                      physics: PageScrollPhysics(),
                      diameterRatio: 200,
                      itemExtent: widget.isMagnified
                          ? physicalWidth
                          : widget.height - 2,
                      children: List.generate(
                          widget.event.entries.length,
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
                                        File(widget.event.entries
                                            .elementAt(index)
                                            .key),
                                        compressionRatio: 0.01,
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
                      controller: scrollController2,
                      onSelectedItemChanged: (index) {
                        print("$index, ${this.index}");

                        if(this.index == index) return;
                        this.index = index;
                        setState(() {});
                        scrollController1.jumpToItem(index);
                      },
                      diameterRatio: 200,
                      itemExtent: 40,
                      children: List.generate(
                          widget.event.entries.length,
                          (index) => Center(
                                child: RotatedBox(
                                    quarterTurns: 1,
                                    child: ExtendedImage.file(
                                      File(widget.event.entries
                                          .elementAt(index)
                                          .key),
                                      compressionRatio: 0.01,
                                    )),
                              ))),
                )),
          ),
        if (widget.isMagnified)
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
