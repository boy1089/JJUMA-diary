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
  }) {
  }

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  String note = "";
  int index = 0;
  FocusNode focusNode = FocusNode();

  _PhotoCardState(){
    controller.text = "date, time, address\nLeave your note here!";
  }

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.isMagnified ? physicalWidth : widget.height,
          width: widget.isMagnified ? physicalWidth : widget.height,
          child: Padding(
            padding: widget.isMagnified ? EdgeInsets.all(8.0) : EdgeInsets.all(1.0),
            child: ExtendedImage.file(
              // File(filteredData.keys.toList().elementAt(index)),
              File(widget.event.entries.elementAt(index).key),
              compressionRatio: 0.5,
              fit: BoxFit.cover,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              width: widget.isMagnified ? physicalWidth / 2 : physicalWidth,
            ),
          ),
        ),
        if (widget.isMagnified)
          Container(
            height: 50,
            width: physicalWidth,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: ListWheelScrollView(
                      onSelectedItemChanged: (index){
                        this.index = index;
                        setState((){});
                        },
                      diameterRatio: 200,
                      itemExtent: 50,
                      children: List.generate(
                          10,
                          (index) => Center(
                            child: RotatedBox(
                                quarterTurns: 1,
                                child: ExtendedImage.file(
                                  File(widget.event.entries.elementAt(index).key),
                                  compressionRatio: 0.01,
                                  // loadStateChanged: (ExtendedImageState state) {
                                  //   switch (state.extendedImageLoadState) {
                                  //     case LoadState.loading:
                                  //       break;
                                  //     case LoadState.completed:
                                  //       return ExtendedRawImage(
                                  //         image: state.extendedImageInfo?.image,
                                  //       );
                                  //   }
                                  // },
                                )),
                          ))),
                )

                // child: ListView(
                //   scrollDirection: Axis.horizontal,
                //   children: List<Widget>.generate(event.length, (index) {
                //     return ExtendedImage.file(
                //       File(event.entries.elementAt(index).key),
                //       compressionRatio: 0.01,
                //       loadStateChanged: (ExtendedImageState state) {
                //         switch (state.extendedImageLoadState) {
                //           case LoadState.loading:
                //             break;
                //           case LoadState.completed:
                //             return ExtendedRawImage(
                //               image: state.extendedImageInfo?.image,
                //             );
                //         }
                //       },
                //     );
                //   }),
                // ),
                ),
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
