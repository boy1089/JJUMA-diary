import 'package:flutter/material.dart';
import '../Util/StateProvider.dart';
import 'DayPage.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Note/NoteManager.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:test_location_2nd/Photo/PhotoDataManager.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';

class DayPageView extends StatelessWidget {
  DataManager dataManager;
  SensorDataManager sensorDataManager;
  PhotoDataManager localPhotoDataManager;
  NoteManager noteManager;

  DayPageView( this.dataManager, this.sensorDataManager,
      this.localPhotoDataManager, this.noteManager,
      {Key? key})
      : super(key: key);

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
              return DayPage(

                this.dataManager,
                this.sensorDataManager,
                this.localPhotoDataManager,
                this.noteManager,
              );
            }));
  }
}
