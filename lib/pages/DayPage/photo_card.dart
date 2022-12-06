import 'package:flutter/material.dart';
import 'package:lateDiary/Data/infoFromFile.dart';
import 'package:lateDiary/Util/Util.dart';
import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'dart:math';

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
            height: 100,
            width: physicalWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              // child: ListWheelScrollView(
              //     diameterRatio: 100,
              //     itemExtent: 100.0,
              //     children: List<Widget>.generate(event.length, (index) {
              //       return Container(
              //         height : 100,
              //         child: ExtendedImage.file(
              //           File(event.entries.elementAt(index).key),
              //           compressionRatio: 0.01,
              //           loadStateChanged: (ExtendedImageState state) {
              //             switch (state.extendedImageLoadState) {
              //               case LoadState.loading:
              //                 break;
              //               case LoadState.completed:
              //                 return ExtendedRawImage(
              //                   image: state.extendedImageInfo?.image,
              //                 );
              //             }
              //           },
              //           fit: BoxFit.fitHeight,
              //         ),
              //       );
              //     })),

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
