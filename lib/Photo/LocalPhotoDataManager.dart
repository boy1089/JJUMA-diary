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



String _pathToLocalPhotoGallery1 = "/storage/emulated/0/DCIM/Camera";
String _pathToLocalPhotoGallery2 = "/storage/emulated/0/Pictures";

enum filetypes {
  jpg, png,
}

class LocalPhotoDataManager {
  List photoDataAll = [];
  List<String> dates = [];
  List<String> files = [];

  LocalPhotoDataManager(){
    init();
  }
  void init() async {
    files = await getAllFiles();

  }

  Future getPhotoOfDate(String date) async {

    List files = [];
    List cTimes = [];
    final filesFromPath1_png = await Glob("$_pathToLocalPhotoGallery1/*${date}*.png").listSync();
    final filesFromPath2_png = await Glob("$_pathToLocalPhotoGallery2/*${date}*.png").listSync();
    final filesFromPath1_jpg = await Glob("$_pathToLocalPhotoGallery1/*${date}*.jpg").listSync();
    final filesFromPath2_jpg = await Glob("$_pathToLocalPhotoGallery2/*${date}*.jpg").listSync();

    files.addAll(filesFromPath1_png);
    files.addAll(filesFromPath2_png);
    files.addAll(filesFromPath1_jpg);
    files.addAll(filesFromPath2_jpg);

    //cTime of DateTime is converted to string
    cTimes.addAll(List.generate(files.length, (index)=> DateFormat("yyyyMMdd_HHmmss").format(FileStat.statSync(files.elementAt(index).path).changed)));
    files = List.generate(files.length, (index)=> files.elementAt(index).path);
    return [cTimes, files];
  }

  Future getAllFiles() async {
    List<String> files = [];
    final filesFromPath1_png = await Glob("$_pathToLocalPhotoGallery1/*.png").listSync();
    final filesFromPath2_png = await Glob("$_pathToLocalPhotoGallery2/*.png").listSync();
    final filesFromPath1_jpg = await Glob("$_pathToLocalPhotoGallery1/*.jpg").listSync();
    final filesFromPath2_jpg = await Glob("$_pathToLocalPhotoGallery2/*.jpg").listSync();

    files.addAll(List.generate(filesFromPath1_png.length, (index)=>filesFromPath1_png.elementAt(index).path));
    files.addAll(List.generate(filesFromPath2_png.length, (index)=>filesFromPath2_png.elementAt(index).path));
    files.addAll(List.generate(filesFromPath1_jpg.length, (index)=>filesFromPath1_jpg.elementAt(index).path));
    files.addAll(List.generate(filesFromPath2_jpg.length, (index)=>filesFromPath2_jpg.elementAt(index).path));

    print(files);
    print(_pathToLocalPhotoGallery2);
    return files;
  }

}
