import 'package:flutter/material.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:test_location_2nd/HappinessData.dart';


class HappinessLogger {

  var _cacheCount = 0;

  HappinessLogger() {
    debugPrint("sensorLogger instance created");
  }

  void writeCache(HappinessData happinessData) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(
        '${directory.path}/${DateFormat('yyyyMMdd').format(DateTime.now())}_happiness.csv');
    bool isExists = await file.exists();
    debugPrint("writing happiness to Local..");

    if (!isExists)
      await file.writeAsString(
          'time, happiness, note \n',
          mode: FileMode.append);

    await file.writeAsString(
        '${happinessData.time.toString()}, ${happinessData.happiness.toString()}, ${happinessData.note.toString()}  \n',
        mode: FileMode.append);


  }


}
