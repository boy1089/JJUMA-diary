// import 'package:flutter/material.dart';
// import 'package:jjuma.d/Util/global.dart' as global;
// import 'package:jjuma.d/Util/Util.dart';
// // import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
//
// class NoteEditor {
//   Map layout = {};
//   FocusNode focusNode = FocusNode();
//   var product;
//   double noteEditorHeight_hasFocus = 200;
//   double keyboardHeight = 200;
//   var viewInsets;
//   double keyboardSize = 330;
//   NoteEditor(this.layout, this.focusNode, this.product, this.textController) {
//     viewInsets = EdgeInsets.fromWindowPadding(
//         WidgetsBinding.instance.window.viewInsets,
//         WidgetsBinding.instance.window.devicePixelRatio);
//     noteEditorHeight_hasFocus = physicalHeight -
//         global.kBottomNavigationBarHeight -
//         global.kHeightOfArbitraryWidgetOnBottom;
//   }
//
//   var textController = TextEditingController();
//
//   void dismissKeyboard(product) async {
//     product.setNote(textController.text);
//     focusNode.unfocus();
//     await product.writeNote();
//   }
//
//   Widget build(BuildContext context) {
//     return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
//       return Positioned(
//           width: physicalWidth,
//           bottom: global.kMarginOfBottomOnDayPage,
//           child: AnimatedContainer(
//               duration: Duration(milliseconds: global.animationTime),
//               curve: global.animationCurve,
//               margin: const EdgeInsets.all(10),
//               // height : noteEditorHeight_hasFocus - global.kKeyboardSize,
//               height: isKeyboardVisible
//                   ? noteEditorHeight_hasFocus - product.keyboardSize
//                   : layout['textHeight'][product.isZoomIn],
//               onEnd: () {
//                 if (isKeyboardVisible) product.setKeyboardSize();
//               },
//               color: focusNode.hasFocus
//                   ? global.kColor_containerFocused
//                   : global.kColor_container,
//               child: TextField(
//                 maxLines: 15,
//                 controller: textController,
//
//                 onEditingComplete: () {
//                   print("editing completed");
//                   dismissKeyboard(product);
//                 },
//                 focusNode: focusNode,
//                 style: Theme.of(context).textTheme.bodyText1,
//                 cursorColor: Colors.black12,
//                 // backgroundCursorColor: Colors.black12,
//                 textAlign: TextAlign.left,
//               )));
//     });
//   }
// }
