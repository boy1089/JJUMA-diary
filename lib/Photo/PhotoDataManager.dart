import 'package:exif/exif.dart';
import 'package:glob/list_local_fs.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:glob/glob.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Data/infoFromFile.dart';

List<String> pathsToPhoto = [
  "/storage/emulated/0/DCIM",
  "/storage/emulated/0/DCIM/Camera",
  "/storage/emulated/0/Pictures",
  "/storage/emulated/0/Pictures/*",
];

class PhotoDataManager {
  List datetimes = [];
  List dates = [];
  List<String> files = [];

  PhotoDataManager() {
    // init();
  }

  Future<void> init() async {
    // files = await getAllFiles();
    print("PhotoDataManager, getALlFiles done");
    // datetimes = getDatetimesFromFilnames(files);
    // setDataAsGlobal();
    print("PhotoDataManager, intialization done");
  }

  Future<List<String>> getAllFiles() async {
    List<String> files = [];
    List newFiles = [];
    for (int i = 0; i < pathsToPhoto.length; i++) {
      String path = pathsToPhoto.elementAt(i);

      newFiles = await Glob("$path/*.jpg").listSync();
      files.addAll(List.generate(
          newFiles.length, (index) => newFiles.elementAt(index).path));

      newFiles = await Glob("$path/*.png").listSync();
      files.addAll(List.generate(
          newFiles.length, (index) => newFiles.elementAt(index).path));
    }
    files = files.where((element)=>!element.contains('thumbnail')).toList();
    return files;
  }

  List getDatetimesFromFilnames(files) {
    print("getDatesFromFilenames : $files");
    List inferredDatetimesOfFiles = List.generate(files.length,
        (index) => inferDatetimeFromFilename(files.elementAt(index)));

    print("getDatesFromFilenames : $inferredDatetimesOfFiles");
    inferredDatetimesOfFiles = List.generate(
        inferredDatetimesOfFiles.length,
        (index) =>
            inferredDatetimesOfFiles.elementAt(index) ??
            formatDate(FileStat.statSync(files[index]).changed));

    print("getDatesFromFilenames : $inferredDatetimesOfFiles");
    this.datetimes = inferredDatetimesOfFiles;
    this.dates = List.generate(inferredDatetimesOfFiles.length,
        (i) => inferredDatetimesOfFiles.elementAt(i).substring(0, 8));
    return inferredDatetimesOfFiles;
  }

  List filterInvalidFiles(files){
    return files;
  }

  Future getPhotoOfDate(String date) async {
    Set indexOfDate = List.generate(
        datetimes.length,
        (i) => (datetimes.elementAt(i).substring(0, 8).contains(date) & (datetimes.elementAt(i).length>8))
            ? i
            : null).toSet();
    indexOfDate.remove(null);

    List filesOfDate = List.generate(
        indexOfDate.length, (i) => files.elementAt(indexOfDate.elementAt(i)));
    List dateOfDate = List.generate(indexOfDate.length,
        (i) => datetimes.elementAt(indexOfDate.elementAt(i)));

          for(int i = 0; i<indexOfDate.length; i++){
        print("${dateOfDate[i]}, ${filesOfDate[i]}");
    }

    return [dateOfDate, filesOfDate];
  }


  void setDataAsGlobal() {
    global.files = this.files;
    global.dates = this.dates;
    global.datetimes = this.datetimes;
  }

}
