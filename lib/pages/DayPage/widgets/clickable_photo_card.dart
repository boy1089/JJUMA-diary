import 'package:flutter/material.dart';
import 'package:lateDiary/Util/Util.dart';
import 'photo_card.dart';
import 'package:lateDiary/Util/global.dart' as global;
class ClickablePhotoCard extends StatelessWidget {
  PhotoCard photoCard;
  double height;
  double width;

  ClickablePhotoCard({required this.photoCard, this.height = 100, this.width = 100});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showDialog(
              useSafeArea: false,
              context: context,
              builder: (context) => Container(
                    width: physicalWidth - global.kDialogPadding*2,
                    child: SimpleDialog(
                      insetPadding: EdgeInsets.all(global.kDialogPadding),
                      children: [
                        Container(child: photoCard..isMagnified = true..isTickEnabled = false)
                      ],
                    ),
                  ));
        },
        child: photoCard..height = this.height);
  }
}
