import 'package:flutter/material.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Util/Util.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class NoteEditor {
  Map layout = {};
  FocusNode focusNode = FocusNode();
  var product;
  NoteEditor(this.layout, this.focusNode, this.product, this.textController);

  var textController = TextEditingController();

  void dismissKeyboard(product) async {
    product.setNote(textController.text);
    focusNode.unfocus();
    await product.writeNote();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      print("isKeyboardVisible : $isKeyboardVisible");
      print(MediaQuery.of(context).viewInsets.top - 100);
      return Positioned(
        width: physicalWidth,
        // height: isKeyboardVisible
        //     ? physicalHeight - 200 - 200
        //     : layout['textHeight'][product.isZoomIn],
        bottom: global.kMarginOfBottomOnDayPage,
        child: AnimatedContainer(
          duration: Duration(milliseconds: global.animationTime),
          curve : global.animationCurve,
          margin: EdgeInsets.all(10),
          height: isKeyboardVisible
              ? physicalHeight - 200 - 200
              : layout['textHeight'][product.isZoomIn],
          color: focusNode.hasFocus
              ? global.kColor_containerFocused
              : global.kColor_container,
          child: EditableText(
            // readOnly: isZoomIn ? true : false,
            maxLines: 15,
            controller: textController,
            onSelectionChanged: (a, b) {
              if (!focusNode.hasFocus) ;
            },

            onEditingComplete: () {
              print("editing completed");
              dismissKeyboard(product);
            },

            focusNode: focusNode,
            style: TextStyle(color: global.kColor_diaryText),
            cursorColor: Colors.black12,
            backgroundCursorColor: Colors.black12,
            textAlign: TextAlign.left,
          ),
        ),
      );
    });
  }
}
