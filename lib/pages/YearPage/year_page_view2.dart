import 'package:flutter/material.dart';


class YearPageView2 extends StatelessWidget {
  int year;
  YearPageView2 ({required this.year,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child : Text(year.toString()));
  }
}
