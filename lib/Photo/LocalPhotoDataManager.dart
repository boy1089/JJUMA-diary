import 'package:exif/exif.dart';
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
import 'package:test_location_2nd/Util/global.dart';

String _pathToLocalPhotoGallery1 = "/storage/emulated/0/DCIM/Camera";
String _pathToLocalPhotoGallery2 = "/storage/emulated/0/Pictures";
String _pathToLocalPhotoGallery3 = "/storage/emulated/0/Pictures/*";


enum filetypes {
  jpg,
  png,
}

class LocalPhotoDataManager {
  List photoDataAll = [];
  List<String> dates = [];
  List<String> files = [];
  List modifiedDatesOfFiles = [];

  LocalPhotoDataManager() {
    init();
  }
  void init() async {
    files = await getAllFiles();
    modifiedDatesOfFiles = getModifiedDatesOfFiles(files);
  }

  static Future getPhotoOfDate_static(String date) async {
    List files = [];
    List cTimes = [];
    final filesFromPath1_png =
        await Glob("$_pathToLocalPhotoGallery1/*${date}*.png").listSync();
    final filesFromPath2_png =
        await Glob("$_pathToLocalPhotoGallery2/*${date}*.png").listSync();
    final filesFromPath1_jpg =
        await Glob("$_pathToLocalPhotoGallery1/*${date}*.jpg").listSync();
    final filesFromPath2_jpg =
        await Glob("$_pathToLocalPhotoGallery2/*${date}*.jpg").listSync();
    final filesFromPath3_jpg =
    await Glob("$_pathToLocalPhotoGallery3/*${date}*.jpg").listSync();

    //delyay is introduced to avoid slow down in ui
    await Future.delayed(Duration(milliseconds: 100));
    files.addAll(filesFromPath1_png);
    files.addAll(filesFromPath2_png);
    files.addAll(filesFromPath1_jpg);
    files.addAll(filesFromPath2_jpg);
    files.addAll(filesFromPath3_jpg);

    //cTime of DateTime is converted to string
    cTimes.addAll(List.generate(
        files.length,
        (index) => DateFormat("yyyyMMdd_HHmmss")
            .format(FileStat.statSync(files.elementAt(index).path).accessed)));
    print("files during GetPhotoOfDate : $files");
    files = List.generate(files.length, (index) => files.elementAt(index).path);
    return [cTimes, files];
  }

  Future getPhotoOfDate(String date) async {
    List files = [];
    List cTimes = [];
    List files_new = [];
    final filesFromPath1_png =
        await Glob("$_pathToLocalPhotoGallery1/*${date}*.png").listSync();
    final filesFromPath2_png =
        await Glob("$_pathToLocalPhotoGallery2/*${date}*.png").listSync();
    final filesFromPath1_jpg =
        await Glob("$_pathToLocalPhotoGallery1/*${date}*.jpg").listSync();
    final filesFromPath2_jpg =
        await Glob("$_pathToLocalPhotoGallery2/*${date}*.jpg").listSync();
    final filesFromPath3_jpg =
    await Glob("$_pathToLocalPhotoGallery3/*${date}*.jpg").listSync();

    files.addAll(filesFromPath1_png);
    files.addAll(filesFromPath2_png);
    files.addAll(filesFromPath1_jpg);
    files.addAll(filesFromPath2_jpg);
    files.addAll(filesFromPath3_jpg);

    //cTime of DateTime is converted to string
    for (int i = 0; i < files.length; i++) {
      var bytes = await File(files.elementAt(i).path).readAsBytes();
      var data = await readExifFromBytes(bytes);
      // print("date of photo : ${data['Image DateTime'].toString().replaceAll(":", "")}");
      String dateInExif = data['Image DateTime'].toString().replaceAll(":", "");

      //exclude the images without exif data
      if (dateInExif == "null") continue;

      String date =
          DateFormat("yyyyMMdd_HHmmss").format(DateTime.parse(dateInExif));
      cTimes.add(date);
      files_new.add(files.elementAt(i).path);
    }
    print("files during GetPhotoOfDate : $cTimes");
    // files = List.generate(files.length, (index)=> files.elementAt(index).path);
    return [cTimes, files_new];
  }

  Future<String> getExifDateOfFile(String file) async {
    var bytes = await File(file).readAsBytes();
    var data = await readExifFromBytes(bytes);
    // print("date of photo : ${data['Image DateTime'].toString().replaceAll(":", "")}");
    String dateInExif = data['Image DateTime'].toString().replaceAll(":", "");
    return dateInExif;
  }


  Future getAllFiles() async {
    List<String> files = [];
    final filesFromPath1_png =
        await Glob("$_pathToLocalPhotoGallery1/*.png").listSync();
    final filesFromPath2_png =
        await Glob("$_pathToLocalPhotoGallery2/*.png").listSync();
    final filesFromPath1_jpg =
        await Glob("$_pathToLocalPhotoGallery1/*.jpg").listSync();
    final filesFromPath2_jpg =
        await Glob("$_pathToLocalPhotoGallery2/*.jpg").listSync();
    final filesFromPath3_jpg =
    await Glob("$_pathToLocalPhotoGallery3/*.jpg").listSync();

    files.addAll(List.generate(filesFromPath1_png.length,
        (index) => filesFromPath1_png.elementAt(index).path));
    files.addAll(List.generate(filesFromPath2_png.length,
        (index) => filesFromPath2_png.elementAt(index).path));
    files.addAll(List.generate(filesFromPath1_jpg.length,
        (index) => filesFromPath1_jpg.elementAt(index).path));
    files.addAll(List.generate(filesFromPath2_jpg.length,
        (index) => filesFromPath2_jpg.elementAt(index).path));
    files.addAll(List.generate(filesFromPath3_jpg.length,
            (index) => filesFromPath3_jpg.elementAt(index).path));

    print(files);
    print(_pathToLocalPhotoGallery2);
    return files;
  }



  List getModifiedDatesOfFiles(files) {


    List modifiedDatesOfFiles = List.generate(
        files.length, (index) => FileStat.statSync(files[index]).modified);

    // List exifDateOfFiles = List.generate(files.length, (index) => getExifDateOfFile(files[index]));
    // exifDateOfFiles.where((e) => e==null? e )

    modifiedDatesOfFiles.sort((a, b) => a.compareTo(b));
    // exifDateOfFiles.sort((a, b) => a.comparedTo(b));
    this.modifiedDatesOfFiles = modifiedDatesOfFiles;
    // this.modifiedDatesOfFiles = exifDateOfFiles;
    return modifiedDatesOfFiles;
  }
}
