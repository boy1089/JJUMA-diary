import 'package:flutter/material.dart';
import 'package:lateDiary/Data/infoFromFile.dart';
import 'package:lateDiary/Util/Util.dart';
import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'clickable_photo_card.dart';
import 'photo_card.dart';

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