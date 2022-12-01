import 'package:glob/list_local_fs.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:glob/glob.dart';

class SensorDataManager {
  Map sensorDataAll = {};
  List<String> dates = [];
  SensorDataManager() {}


  Future<List> openFile(String date) async {
    final Directory? directory = await getApplicationDocumentsDirectory();
    File f = File("${directory?.path}/sensorData/${date}_sensor.csv");

    if (!await f.exists()) {
      return [[]];
    }

    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    return fields;
  }
}
