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

      newFiles = Glob("$path/*.jpg").listSync();
      files.addAll(List.generate(
          newFiles.length, (index) => newFiles.elementAt(index).path));

      newFiles = Glob("$path/*.png").listSync();
      files.addAll(List.generate(
          newFiles.length, (index) => newFiles.elementAt(index).path));
    }
    files = files.where((element) => !element.contains('thumbnail')).toList();
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

  List filterInvalidFiles(files) {
    return files;
  }

  Future getPhotoOfDate(String date) async {
    Stopwatch stopwatch = Stopwatch()..start();

    List<int?> indexOfDate =
        List<int?>.generate(global.dates.length, (i) {
      if (global.dates.elementAt(i) == date) return i;
      return null;
    });

    print("time elapsed : ${stopwatch.elapsed}");
    indexOfDate = indexOfDate.whereType<int>().toList();
    print("time elapsed : ${stopwatch.elapsed}");
    List filesOfDate = List.generate(indexOfDate.length,
        (i) => global.infoFromFiles.keys.elementAt(indexOfDate.elementAt(i)!));
    print("time elapsed : ${stopwatch.elapsed}");
    List dateOfDate = List.generate(
        indexOfDate.length,
        (i) => formatDatetime(
            global.datetimes.elementAt(indexOfDate.elementAt(i)!)));
    print("time elapsed : ${stopwatch.elapsed}");
    for (int i = 0; i < indexOfDate.length; i++) {
      print("${dateOfDate[i]}, ${filesOfDate[i]}");
    }

    return [dateOfDate, filesOfDate];
  }

  void setDataAsGlobal() {
    global.files = this.files;
    global.setOfDates = this.dates;
    global.datetimes = this.datetimes;
  }
}
