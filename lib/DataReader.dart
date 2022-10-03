import 'package:path_provider/path_provider.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'dart:io';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:matrix2d/matrix2d.dart';

class DataReader {

  List<File> files2 = [];
  var data;
  List<List<List<dynamic>>> dataAll = [];
  bool permissionGranted = false;

  DataReader() {
    print('DataReader is reading Files');
    readFiles();
  }

  Future<String?> get _localPath async {
    final directory2 = await getExternalStorageDirectories();
    var path = directory2?[0].path;
    return path;
  }

  Future _getStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      permissionGranted = true;
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.storage.request().isDenied) {
      permissionGranted = false;
    }
  }

  Future<List<File>> getFiles() async {
    String? kRoot = await _localPath;
    _getStoragePermission();

    FileManager fm = FileManager(root: Directory('${kRoot}')); //
    // Future<List<File>> files = fm.filesTree(extensions: [".csv"],
    // excludedPaths : ["${kRoot}/usageData"]);
    Future<List<File>> files = fm.filesTree(extensions: [".csv"],);
    print("path : ${kRoot}/usageData");

    return files;
  }

  Future<List<List<List<dynamic>>>> readFiles() async {
    List<File> files = await getFiles();
    print(files);
    dataAll = [];
    files2 = files; //assigning files to class variable to later use.
    for (int i = 0; i < files.length; i++) {
      // data = await readFile(files
      //     .elementAt(i)
      //     .path);
      data = await openFile(files.elementAt(i).path);
      print('reaFiles, $i th data');

      dataAll.add(data);
    }
    return dataAll;
  }

  Future<DataFrame> readFile(path) async {
    var a = await _localPath;
    data = await fromCsv(path);
    return data;
  }

  // Future<List<List<dynamic>>> openFile(filepath) async
  Future<List> openFile(filepath) async
  {
    File f = new File(filepath);
    print("CSV to List");
    final input = f.openRead();
    final fields = await input.transform(utf8.decoder).transform(new CsvToListConverter(eol : '\n')).toList();
    List list = convertStringTimeToInt(fields);
    return list;
  }

  // List<List<dynamic>> convertStringTimeToInt(List fields){
  List<dynamic> convertStringTimeToInt(List fields){
    print(fields.toString());
    List listTime = slice(fields, [1, fields.shape[0]], [0, 1]).flatten;

    listTime = List<List<double>>.generate(listTime.length, (int index) => [convertStringTimeToDouble(listTime[index])] );
    List listSensor = slice(fields, [1, fields.shape[0]], [1, 5]);
    print(listTime.shape);
    print(listSensor.shape);
    List list = Matrix2d().concatenate(listTime, listSensor, axis : 1);

    return list;
  }

  double convertStringTimeToDouble(String time){

    List<String> timeSplit = time.substring(11, 19).split(':');
    double timeDouble = double.parse(timeSplit[0]) + double.parse(timeSplit[1])/60.0 + double.parse(timeSplit[2])/3600.0 ;

    return timeDouble;
  }
}



List slice(List<dynamic> array, List<int> row_index,
    [List<int>? column_index]) {
  var result = [];
  // convert List<dynamic> to List<List>
  var arr = array.map((e) => e is List ? e : [e]).toList();
  try {
    if (row_index.length > 2) {
      throw Exception(
          'row_index only containing the elements between start and end.');
    }
    int rowMin = row_index[0];
    int rowMax = row_index[1];
    int counter = 0;
    arr.forEach((List row) {
      if (rowMin <= counter && counter < rowMax) {
        if (column_index != null && column_index.length > 1) {
          result.add(row.getRange(column_index[0], column_index[1]).toList());
        } else if (column_index == null) {
          result.add(row);
        } else {
          if (result.isEmpty) {
            result = [row[column_index[0]]];
          } else {
            result.add(row[column_index[0]]);
          }
        }
      }
      counter++;
    });
    return result;
  } catch (e) {
    throw new Exception(e);
  }
}