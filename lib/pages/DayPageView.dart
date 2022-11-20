import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'DayPage.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/StateProvider/DayPageStateProvider.dart';
import 'package:lateDiary/StateProvider/NavigationIndexStateProvider.dart';

class DayPageView extends StatelessWidget {

  DayPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var dayPageStateProvider =
        Provider.of<DayPageStateProvider>(context, listen: true);
    var navigation =
        Provider.of<NavigationIndexProvider>(context, listen: false);
    return Scaffold(
        body: PageView.builder(
          dragStartBehavior: DragStartBehavior.down,
            physics:
              dayPageStateProvider.isZoomIn
                ?NeverScrollableScrollPhysics():
              BouncingScrollPhysics(),
            controller: PageController(
                initialPage: dayPageStateProvider.availableDates
                    .indexOf(navigation.date)),
            itemCount: dayPageStateProvider.availableDates.length,
            reverse: false,
            itemBuilder: (BuildContext context, int index) {
              // navigation.setDate(
              //     formatDateString(dayPageStateProvider.availableDates[index]));
              String date = dayPageStateProvider.availableDates[index];
              return DayPage(date);
            }));
  }
}
