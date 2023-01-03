// import 'package:flutter/material.dart';
// import 'package:jjuma.d/Data/info_from_file.dart';
// import 'package:jjuma.d/Util/Util.dart';
// import '../model/event.dart';
// import 'clickable_photo_card.dart';
// import 'photo_card.dart';
//
// class CardContainer extends StatelessWidget {
//   List<Event> listOfEvents;
//   bool isTickEnabled = false;
//   CardContainer({required this.listOfEvents, this.isTickEnabled = false});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         width: physicalWidth,
//         color: Colors.black,
//         child: Column(children: [
//           if (listOfEvents.length < 4) renderSomePhotoCards(),
//           if (listOfEvents.length > 3) renderFourPhotoCards(),
//           if (listOfEvents.length > 4) renderRowOfPhotoCards(),
//         ]));
//   }
//
//   renderFourPhotoCards() {
//     return Row(children: [
//       Column(
//         children: [
//           ClickablePhotoCard(
//             photoCard:
//                 PhotoCard(event: listOfEvents[0], height: physicalWidth / 4),
//           ),
//           ClickablePhotoCard(
//             photoCard:
//                 PhotoCard(event: listOfEvents[1], height: physicalWidth / 4),
//           ),
//           ClickablePhotoCard(
//             photoCard:
//                 PhotoCard(event: listOfEvents[2], height: physicalWidth / 4),
//           ),
//         ],
//       ),
//       ClickablePhotoCard(
//         photoCard: PhotoCard(
//             event: listOfEvents[3],
//             height: physicalWidth / 4 * 3,
//             isTickEnabled: isTickEnabled),
//       ),
//     ]);
//   }
//
//   renderRowOfPhotoCards() {
//     return Row(
//         children: List.generate(
//       listOfEvents.length - 4,
//       (index) => ClickablePhotoCard(
//         photoCard: PhotoCard(
//             event: listOfEvents[index + 4],
//             height: physicalWidth / 4,
//             isTickEnabled: index == 2 ? isTickEnabled : false),
//       ),
//     ));
//   }
//
//   renderSomePhotoCards() {
//     return Row(
//         children: List.generate(
//             listOfEvents.length,
//             (index) => ClickablePhotoCard(
//                 photoCard: PhotoCard(
//                     event: listOfEvents.elementAt(index),
//                     height: physicalWidth / listOfEvents.length,
//                     isTickEnabled: index==0? isTickEnabled : false,
//                 ))));
//   }
// }
