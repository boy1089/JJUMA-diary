import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:ui' as ui;
class CustomButtonTest extends StatefulWidget {
  Function capture;
  CustomButtonTest(this.capture, {Key? key}) : super(key: key);

  @override
  State<CustomButtonTest> createState() => _CustomButtonTestState();
}

class _CustomButtonTestState extends State<CustomButtonTest> {


  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return
      Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            customButton: const Icon(
              Icons.list,
              size: 30,
              // color: Colors.red,
            ),
            customItemsHeights: [
              ...List<double>.filled(MenuItems.firstItems.length, 48),
              // 8,
              // ...List<double>.filled(MenuItems.secondItems.length, 48),
            ],
            items: [
              ...MenuItems.firstItems.map(
                (item) => DropdownMenuItem<MenuItem>(
                  value: item,
                  child: MenuItems.buildItem(item),
                ),
              ),
            ],
            onChanged: (value) {
              MenuItems.onChanged(context, value as MenuItem, widget.capture);
            },
            itemHeight: 48,
            itemPadding: const EdgeInsets.only(left: 16, right: 16),
            dropdownWidth: 160,
            dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
            dropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              // color: Colors.redAccent,
            ),
            dropdownElevation: 8,
            offset: const Offset(0, 8),
          ),
        ),

    );
  }
}

class MenuItem {
  final String text;
  final IconData icon;

  const MenuItem({
    required this.text,
    required this.icon,
  });
}

class MenuItems {
  // static const List<MenuItem> firstItems = [home, share, settings, export];
  static const List<MenuItem> firstItems = [
    share,
    settings];

  static const List<MenuItem> secondItems = [logout];

  static const home = MenuItem(text: 'Home', icon: Icons.home);
  static const export = MenuItem(text: 'export', icon: Icons.add);

  static const share = MenuItem(text: 'Share', icon: Icons.share);
  static const settings = MenuItem(text: 'Settings', icon: Icons.settings);
  static const logout = MenuItem(text: 'Log Out', icon: Icons.logout);

  static Widget buildItem(MenuItem item) {
    return Row(
      children: [
        Icon(item.icon, color: Colors.white, size: 22),
        const SizedBox(
          width: 10,
        ),
        Text(
          item.text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  static onChanged(BuildContext context, MenuItem item, capture) async {
    switch (item) {
      case MenuItems.home:
        //Do something
        break;
      case MenuItems.settings:
        //Do something
        context.push('/setting');
        break;
      case MenuItems.share:
        capture();
        //Do something
        break;
    }
  }


}
