import 'package:exif/exif.dart';
import 'package:glob/list_local_fs.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:glob/glob.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Data/infoFromFile.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Data/Directories.dart';
//
// List<String> Directories.selectedDirectories = [
//   "/storage/emulated/0/DCIM",
//   "/storage/emulated/0/DCIM/Camera",
//   "/storage/emulated/0getApplicationDocumentsDirectory()s",
//   "/storage/emulated/0getApplicationDocumentsDirectory()s/*",
// ];

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
    for (int i = 0; i < Directories.selectedDirectories.length; i++) {
      String path = Directories.selectedDirectories.elementAt(i);

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

    print("time elapsed1 : ${stopwatch.elapsed}");
    indexOfDate = indexOfDate.whereType<int>().toList();
    print("time elapsed2 : ${stopwatch.elapsed}");
    List files = global.infoFromFiles.keys.toList();
    List filesOfDate = List.generate(indexOfDate.length,
        (i) => files.elementAt(indexOfDate.elementAt(i)!));

    print("time elapsed3 : ${stopwatch.elapsed}");
    List dateOfDate = List.generate(
        indexOfDate.length,
        (i) => formatDatetime(
            global.datetimes.elementAt(indexOfDate.elementAt(i)!)));
    print("time elapsed4 : ${stopwatch.elapsed}");
    // for (int i = 0; i < indexOfDate.length; i++) {
    //   print("${dateOfDate[i]}, ${filesOfDate[i]}");
    // }

    List list = transpose([dateOfDate, filesOfDate]);
    list.sort((a, b) =>int.parse(a[0].substring(9, 13)).compareTo(int.parse(b[0].substring(9, 13))));
    // list.sort((a, b) =>int.parse(a[0].substring(9, 13)).compareTo(int.parse(b[0].substring(9, 13))));

    print("getPhotoOfDate, $list");

    return transpose(list);
  }

  void setDataAsGlobal() {
    global.files = this.files;
    global.setOfDates = this.dates;
    global.setOfDatetimes = this.datetimes;
  }
}
