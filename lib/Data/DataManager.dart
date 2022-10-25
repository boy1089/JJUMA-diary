import 'dart:io';
import 'package:glob/list_local_fs.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:glob/glob.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/global.dart' as global;
import 'package:test_location_2nd/GooglePhotoDataManager.dart';
import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/DateHandler.dart';
import 'package:intl/intl.dart';

enum sensorType {
  longitude,
  latitude,
  accelX,
  accelY,
  accelZ,
  light,
  temperature,
  proximity,
  humidity,
}

class DataManager {
  var sensorDataAll;
  var photoDataAll;

  List<String> fileList = [];
  List<dynamic> dataAll = [];
  List<dynamic> processedSensorData = [];
  Map summaryOfPhotoData = {};
  bool isUpdateInProgress = false;
  String processedFileName = "sensor_processed.csv";
  List<DateTime> datesOfYear = [];
  int updateIndexOfPhotoSummary = 0;

  GooglePhotoDataManager googlePhotoDataManager;
  PhotoLibraryApiClient photoLibraryApiClient;

  DataManager(this.googlePhotoDataManager, this.photoLibraryApiClient){
    // processAllSensorFiles();
    // getProcessedSensorFile();
    print("DataManager instance in under creation");
    // init();
    print("DataManager instance is created");
  }

  Future<void> init() async {
    print("DataManager instance is initializing..");
    await readSummaryOfGooglePhotoData();
    await updateAllofSummary("20100101", formatDate(DateTime.now()));
  }


  Future<void> updateAllofSummary(startDate, endDate) async {
    var datesOfYear =
    getDaysInBetween(DateTime.parse(startDate), DateTime.parse(endDate)).reversed.toList();

    for (int i = 0; i < datesOfYear.length; i++) {
      String date = DateFormat("yyyyMMdd").format(datesOfYear[i]);
      if (summaryOfPhotoData.containsKey(date)) {
        // print("date $date is already contained in the dataManager");
        continue;
      }

      print("$date is under processing...");
      var photoResponse = await googlePhotoDataManager.getPhoto(photoLibraryApiClient, date);
      updateSummaryOfPhotoData(
          date, photoResponse[0].length - 1);
    }

  }

  void updateSummaryOfPhotoData(String date, int num){
    summaryOfPhotoData[date] = num;
    updateIndexOfPhotoSummary +=1;
    if(updateIndexOfPhotoSummary > 10){
      writeSummaryOfGooglePhotoData();
      global.summaryOfPhotoData = summaryOfPhotoData;
    }
  }


  Future<void> readSummaryOfGooglePhotoData() async {
    final Directory? directory = await getExternalStorageDirectory();
    // final File file = File('${directory?.path}/summary_googlePhoto.csv');
    final fileName = Glob('${directory?.path}/summary_googlePhoto.csv').listSync().elementAt(0);

    print("readSummaryOfGooglePhotoData ${fileName.path}");
    var data = await openFile(fileName.path);

    for( int i = 0; i< data.length; i++){
      try {
        summaryOfPhotoData[data[i][0].toString()] = data[i][1];
      } catch (e){
        print(e);
      }

    }
    global.summaryOfPhotoData = summaryOfPhotoData;
  }
  void writeSummaryOfGooglePhotoData() async{
    final Directory? directory = await getExternalStorageDirectory();
    final fileName = '${directory?.path}/summary_googlePhoto.csv';
    File file = File(fileName);
    bool isFileExists = await file.exists();

    print("write ${fileName}");
    await file.writeAsString(
        'date,numberOfImages\n',
        mode: FileMode.write);

    print("writing... ${summaryOfPhotoData}");
    for (int i = 1; i < summaryOfPhotoData.length; i++) {
      var line = summaryOfPhotoData.keys.elementAt(i);
      await file.writeAsString(
          '${line},${summaryOfPhotoData[line]}\n',
          mode: FileMode.append);
    }
  }

  Future<List> getSensorFileList() async {
    var directory = await getExternalStorageDirectories();
    Directory(directory!.first.path).create();
    var files = Glob("${directory.first.path}/sensorData/*_sensor.csv");
    fileList = List<String>.generate(
        files.listSync().length, (int index) => files.listSync()[index].path);
    return fileList;
  }

  void processAllSensorFiles() async {
    //subsample and write each sensor file to local

    final Directory? directory = await getExternalStorageDirectory();
    String fileName = Glob("${directory?.path}/$processedFileName").listSync().elementAt(0).path;
    File file = File(fileName);


    await file.writeAsString(
        'time, longitude, latitude, accelX, accelY, accelZ, light, temperature, proximity, humidity\n',
        mode: FileMode.write);

    await getSensorFileList();
    for (int i = 0; i < fileList.length; i++) {
      // for (int i = 0; i < 2; i++) {
      List data = await openFile(fileList[i]);
      List subsampledData = await subsampleList(data, 50);
      await writeDataToProcessedFile(subsampledData);

      // for(int i=0; i< 9; i++){
      //
      // }
    }
  }
  Future<List> getProcessedSensorFile() async{
    final Directory? directory = await getExternalStorageDirectory();
    String fileName = Glob('${directory?.path}/$processedFileName').listSync().elementAt(0).path;
    File file = File(fileName);

    List data = await openFile(file.path);
    processedSensorData = data;
    return data;

  }

  Future<int> writeDataToProcessedFile(List data) async {
    final Directory? directory = await getExternalStorageDirectory();
    String fileName = Glob('${directory?.path}/$processedFileName').listSync().elementAt(0).path;
    File file = File(fileName);
    print("write ${file.path}");

    for (int i = 1; i < data.length; i++) {
      var line = data[i];
      // print(line.length);
      while (line.length < 10) {
        line.add('0');
      }
      print(line);
      await file.writeAsString(
          '${line[0]}, ${line[1]}, ${line[2]}, ${line[3]}'
          ',${line[4]}, ${line[5]}}\n',
          mode: FileMode.append);
    }
    return 0;
  }

  Future<List> openFile(filePath) async {
    File f = File(filePath);
    debugPrint("CSV to List");
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    // print(slice(fields, [0, fields.shape[0]], [1]));
    return fields;
  }

  void appendToFile() {}

  void getSensorData(sensorDataReader) {
    sensorDataAll = sensorDataReader.dailyDataAll;
    print(sensorDataAll);
  }

}
