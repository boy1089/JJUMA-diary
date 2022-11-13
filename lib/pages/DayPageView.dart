import 'package:flutter/material.dart';
import 'DayPage.dart';
import 'package:test_location_2nd/Note/NoteManager.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:test_location_2nd/StateProvider/DayPageStateProvider.dart';
import 'package:test_location_2nd/StateProvider/NavigationIndexStateProvider.dart';

class DayPageView extends StatelessWidget {

  DayPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var dayPageStateProvider =
        Provider.of<DayPageStateProvider>(context, listen: false);
    var navigation =
        Provider.of<NavigationIndexProvider>(context, listen: false);
    return Scaffold(
        body: PageView.builder(
            controller: PageController(
                initialPage: dayPageStateProvider.availableDates
                    .indexOf(navigation.date)),
            itemCount: dayPageStateProvider.availableDates.length,
            reverse: false,
            itemBuilder: (BuildContext context, int index) {
              navigation.setDate(
                  formatDateString(dayPageStateProvider.availableDates[index]));
              return DayPage();
            }));
  }
}
