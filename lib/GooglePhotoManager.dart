import 'package:test_location_2nd/DateHandler.dart';
import 'package:test_location_2nd/Util/responseParser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:csv/csv.dart';
import 'dart:convert';


class GooglePhotoManager {
  Map photoResponseAll = {};
  var response;
  var photoResponse;
  List photoDataAll = [];
  List<String> dates = [];

  void getAndSaveAllPhoto(photoLibraryApiClient, startDate, endDate) async {
    var datesOfYear = getDaysInBetween(DateTime.parse(startDate), DateTime.parse(endDate));

    for (int i = 0; i < datesOfYear.length; i++) {
      String date = DateFormat("yyyyMMdd").format(datesOfYear[i]);
      var photoResponse = await getPhoto(
          photoLibraryApiClient, date);
      writePhotoResponse(date, photoResponse);
    }
  }

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
    print(folder);
    if (!isFolderExists) {
      Directory(folder).create(recursive: true);
    }

    final File file =
        File('${directory?.path}/googlePhotoData/${date}_googlePhoto.csv');
    bool isExists = await file.exists();
    debugPrint("writing Cache to Local..");

    if (!isExists)
      await file.writeAsString('time, link\n', mode: FileMode.write);

    for (int i = 0; i < photoResponse[0].length; i++) {
      List<String> timeList = photoResponse[0];
      List<String> linkList = photoResponse[1];

      await file.writeAsString(
          '${timeList.elementAt(i)}, ${linkList.elementAt(i)} \n',
          mode: FileMode.append);
    }
  }

  Future<String?> get _localPath async {
    final directory2 = await getExternalStorageDirectories();
    var path = directory2?[0].path;
    return path;
  }

  Future<List<File>> getFiles() async {
    String? kRoot = await _localPath;

    FileManager fm = FileManager(root: Directory('$kRoot/googlePhotoData')); //
    Future<List<File>> files = fm.filesTree(
      extensions: [".csv"],
    );

    return files;
  }

  Future<List<dynamic>> readFiles() async {
    List<File> files = await getFiles();
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

  List<List<dynamic>> subsampleList(List list, int factor) {
    List<List<dynamic>> newList = [];
    for (int i = 0; i < list.length; i++) {
      if (i % factor == 0) newList.add(list[i]);
    }
    return newList;
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