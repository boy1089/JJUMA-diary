import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Util/Util.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class NoteEditor {
  Map layout = {};
  FocusNode focusNode = FocusNode();
  var product;
  double noteEditorHeight_hasFocus = 200;
  double keyboardHeight = 200;
  var viewInsets;
  double keyboardSize = 330;
  NoteEditor(this.layout, this.focusNode, this.product, this.textController) {
    viewInsets = EdgeInsets.fromWindowPadding(
        WidgetsBinding.instance.window.viewInsets,
        WidgetsBinding.instance.window.devicePixelRatio);
    // keyboardHeight = double.parse(viewInsets.bottom.toString());
    noteEditorHeight_hasFocus = physicalHeight -
        global.kBottomNavigationBarHeight -
        global.kHeightOfArbitraryWidgetOnBottom;
    // -keyboardHeight;
  }

  var textController = TextEditingController();

  void dismissKeyboard(product) async {
    product.setNote(textController.text);
    focusNode.unfocus();
    await product.writeNote();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Positioned(
        width: physicalWidth,
        bottom: global.kMarginOfBottomOnDayPage,
        // height : layout['graphSize'][false],
        child:
           AnimatedContainer(
            duration: Duration(milliseconds: global.animationTime),
            curve: global.animationCurve,
            margin: EdgeInsets.all(10),
            // height : noteEditorHeight_hasFocus - global.kKeyboardSize,
            height: isKeyboardVisible
                ? noteEditorHeight_hasFocus - product.keyboardSize
                : layout['textHeight'][product.isZoomIn],

            onEnd: (){
              if(isKeyboardVisible)
              product.setKeyboardSize();
            },

            color: focusNode.hasFocus
                ? global.kColor_containerFocused
                : global.kColor_container,
            // child: EditableText(
            //   // readOnly: isZoomIn ? true : false,
            //   maxLines: 15,
            //   controller: textController,
            //   onChanged: (a) {
            //     print(
            //         "keyboard size now : ${global.kKeyboardSize}, ${keyboardSize}");
            //   },
            //   onEditingComplete: () {
            //     print("editing completed");
            //     dismissKeyboard(product);
            //   },
            //   focusNode: focusNode,
            //   style: TextStyle(color: global.kColor_diaryText),
            //   cursorColor: Colors.black12,
            //   backgroundCursorColor: Colors.black12,
            //   textAlign: TextAlign.left,
            // ),
            //
             child : TextField(
               maxLines : 15,
               controller: textController,

                 onEditingComplete: () {
                   print("editing completed");
                   dismissKeyboard(product);
                 },
                 focusNode: focusNode,
                 style: TextStyle(color: global.kColor_diaryText),
                 cursorColor: Colors.black12,
                 // backgroundCursorColor: Colors.black12,
                 textAlign: TextAlign.left,

             )

          )

      );
    });
  }
}
