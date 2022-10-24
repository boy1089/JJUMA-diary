import 'package:glob/list_local_fs.dart';
import 'package:test_location_2nd/DateHandler.dart';
import 'package:test_location_2nd/Util/responseParser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:glob/glob.dart';
import 'package:test_location_2nd/global.dart';



String pathToLocalPhotoGallery1 = "/storage/emulated/0/DCIM/Camera";
String pathToLocalPhotoGallery2 = "/storage/emulated/0/Pictures";

enum filetypes {
  jpg, png,
}

class LocalPhotoDataManager {
  List photoDataAll = [];
  List<String> dates = [];

  void getAndSaveAllPhoto(startDate, endDate) async {
    DataManager dataManager = DataManager();
    var datesOfYear =
    getDaysInBetween(DateTime.parse(startDate), DateTime.parse(endDate));

    for (int i = 0; i < datesOfYear.length; i++) {
      String date = DateFormat("yyyyMMdd").format(datesOfYear[i]);
      print("$date is under processing...");
      var photoResponse = await getPhoto(date);
      print(photoResponse);
      dataManager.updateSummaryOfGooglePhotoData(date, photoResponse[0].length-1);
    }

  }

  Future getPhoto(date) async {

  }

  Future getFilesOfDate(String date) async {

    List files = [];
    final filesFromPath1_png = await Glob("$pathToLocalPhotoGallery1/*${date}*.png").listSync();
    final filesFromPath2_png = await Glob("$pathToLocalPhotoGallery2/*${date}*.png").listSync();
    final filesFromPath1_jpg = await Glob("$pathToLocalPhotoGallery1/*${date}*.jpg").listSync();
    final filesFromPath2_jpg = await Glob("$pathToLocalPhotoGallery2/*${date}*.jpg").listSync();

    files.addAll(filesFromPath1_png);
    files.addAll(filesFromPath2_png);
    files.addAll(filesFromPath1_jpg);
    files.addAll(filesFromPath2_jpg);

    print(files);
    return files;
  }

  Future getAllFiles() async {
    List files = [];
    final filesFromPath1_png = await Glob("$pathToLocalPhotoGallery1/*.png").listSync();
    final filesFromPath2_png = await Glob("$pathToLocalPhotoGallery2/*.png").listSync();
    final filesFromPath1_jpg = await Glob("$pathToLocalPhotoGallery1/*.jpg").listSync();
    final filesFromPath2_jpg = await Glob("$pathToLocalPhotoGallery2/*.jpg").listSync();

    files.addAll(filesFromPath1_png);
    files.addAll(filesFromPath2_png);
    files.addAll(filesFromPath1_jpg);
    files.addAll(filesFromPath2_jpg);

    print(files);
    print(pathToLocalPhotoGallery2);
    return files;
  }

  Future<List<dynamic>> readFiles() async {
    List<FileSystemEntity> files = await getAllFiles();
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
