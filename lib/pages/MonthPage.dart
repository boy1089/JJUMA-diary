import 'package:flutter/material.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import 'package:test_location_2nd/Util/Util.dart';
import '../Sensor/SensorDataReader.dart';
import '../navigation.dart';
import 'package:test_location_2nd/pages/SettingPage.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/Util/responseParser.dart';
import 'package:test_location_2nd/PolarSensorDataPlot.dart';
import 'package:test_location_2nd/PolarPhotoDataPlot.dart';
import 'package:test_location_2nd/Data/DataManager.dart';

import 'package:flutter/material.dart';

class MonthPage extends StatefulWidget {
  int index = 0;

  MonthPage(int index){
    this.index = index;
  }

  @override
  State<MonthPage> createState() => _MonthPageState();
}

class _MonthPageState extends State<MonthPage> {
  int index = 0;

  // _MonthPageState(this.index){index = index;}

  @override
  void initState(){
    this.index = index;
  }

  @override
  Widget build(BuildContext buildContext){
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children : [
              Text(index.toString()),
              Text(widget.index.toString()),
              Text(widget.index.toString()),
              Text(widget.index.toString()),
              Text(widget.index.toString()),
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() async {
          a += 1;
          setState((){index +=1;});
          // print(dataReader.dailyDataAll[0]);
        }),
      ),
    );
  }
}