import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'DayPageView.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/StateProvider/DayPageStateProvider.dart';
import 'package:lateDiary/StateProvider/NavigationIndexStateProvider.dart';

class DayPage extends StatelessWidget {
  DayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var dayPageStateProvider =
        Provider.of<DayPageStateProvider>(context, listen: true);
    var navigation =
        Provider.of<NavigationIndexProvider>(context, listen: false);
    return Scaffold(
        body: PageView.builder(
            dragStartBehavior: DragStartBehavior.down,
            physics: dayPageStateProvider.isZoomIn
                ? NeverScrollableScrollPhysics()
                : BouncingScrollPhysics(),
            controller: PageController(
                initialPage: dayPageStateProvider.availableDates
                    .indexOf(navigation.date)),
            itemCount: dayPageStateProvider.availableDates.length,
            reverse: false,
            itemBuilder: (BuildContext context, int index) {
              String date = dayPageStateProvider.availableDates[index];
              return DayPageView(date);
            }));
  }
}
