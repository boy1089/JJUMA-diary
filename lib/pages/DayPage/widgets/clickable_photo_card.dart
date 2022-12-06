import 'package:flutter/material.dart';
import 'photo_card.dart';


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
