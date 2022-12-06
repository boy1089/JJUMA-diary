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
              builder: (context) => SimpleDialog(

                insetPadding: EdgeInsets.zero,
                children: [photoCard..isMagnified = true],

              ));
        },
        child: photoCard);
  }
}
