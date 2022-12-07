import 'package:flutter/material.dart';
import 'package:lateDiary/Util/Util.dart';
import 'photo_card.dart';

class ClickablePhotoCard extends StatelessWidget {
  PhotoCard photoCard;
  ClickablePhotoCard({required this.photoCard});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showDialog(
              useSafeArea: false,
              context: context,
              builder: (context) => Container(
                    width: physicalWidth - 16,
                    child: SimpleDialog(
                      insetPadding: EdgeInsets.all(8.0),
                      children: [
                        Container(child: photoCard..isMagnified = true)
                      ],
                    ),
                  ));
        },
        child: photoCard);
  }
}
