import 'package:flutter/material.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:test_location_2nd/NoteData.dart';


class NoteLogger {

  var _cacheCount = 0;

  NoteLogger() {
    debugPrint("sensorLogger instance created");
  }

  void writeCache(NoteData noteData) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(
        '${directory.path}/noteData/${DateFormat('yyyyMMdd').format(DateTime.now())}_note.csv');
    bool isExists = await file.exists();
    debugPrint("writing note to Local..");

    if (!isExists)
      await file.writeAsString(
          'time, note \n',
          mode: FileMode.append);

    await file.writeAsString(
        '${noteData.time.toString()},  ${noteData.note.toString()}  \n',
        mode: FileMode.append);


  }


}
