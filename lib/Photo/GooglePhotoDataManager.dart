import 'package:glob/list_local_fs.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:test_location_2nd/Util/responseParser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:glob/glob.dart';

//TODO : move getPhoto and updatePhoto of dayPage to googlePhotoDataManager

class GooglePhotoDataManager {
  Map photoResponseAll = {};
  var response;
  var photoResponse;
  List photoDataAll = [];
  List<String> dates = [];



  Future getPhoto(photoLibraryApiClient, date) async {
    response = await photoLibraryApiClient.getPhotosOfDate(
        date.substring(0, 4), date.substring(4, 6), date.substring(6, 8));
    photoResponse = parseResponse(response);
    photoResponseAll[date] = photoResponse;
    return photoResponse;
  }

  void writePhotoResponse(date, photoResponse) async {
    final Directory? directory = await getExternalStorageDirectory();

    final String folder = '${directory?.path}/googlePhotoData';
    bool isFolderExists = await Directory(folder).exists();
    if (!isFolderExists) {
      Directory(folder).create(recursive: true);
    }

    final File file =
        File('${directory?.path}/googlePhotoData/${date}_googlePhoto.csv');
    debugPrint("writing Cache to Local..");

    await file.writeAsString('', mode: FileMode.write);

    for (int i = 0; i < photoResponse[0].length; i++) {
      List<String> timeList = photoResponse[0];
      List<String> linkList = photoResponse[1];

      await file.writeAsString(
          '${timeList.elementAt(i)},${linkList.elementAt(i)}\n',
          mode: FileMode.append);
    }
  }

  Future<String?> get _localPath async {
    final directory2 = await getExternalStorageDirectories();
    var path = directory2?[0].path;
    return path;
  }

  Future<List<FileSystemEntity>> getFiles() async {
    String? kRoot = await _localPath;
    final files = await Glob("$kRoot/googlePhotoData/*.csv").listSync();

    return files;
  }

  Future<List<dynamic>> readFiles() async {
    List<FileSystemEntity> files = await getFiles();
    debugPrint("googlePhotoManager, readFiles : $files");
    photoDataAll = [];
    dates = [];
    for (int i = 0; i < files.length; i++) {
      var photoData = await openFile(files.elementAt(i).path);
      debugPrint('readFiles, $i th data');
      String date = files[i].path.split('/').last.substring(0, 8);
      photoDataAll.add(photoData);
      dates.add(date);
    }
    debugPrint("photoManager, readFiles done");
    return photoDataAll;
  }

  Future<List> openFile(filepath) async {
    File f = File(filepath);
    debugPrint("CSV to List");
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    return fields;
  }
}
