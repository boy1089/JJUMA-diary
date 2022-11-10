import 'dart:io';
import 'package:glob/list_local_fs.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:glob/glob.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Photo/PhotoDataManager.dart';
import 'package:test_location_2nd/Location/AddressFinder.dart';
import 'package:test_location_2nd/Location/LocationDataManager.dart';
import "package:test_location_2nd/Location/Coordinate.dart";
import 'infoFromFile.dart';

List<String> pathsToPhoto = [
  "/storage/emulated/0/DCIM",
  "/storage/emulated/0/DCIM/Camera",
  "/storage/emulated/0/Pictures",
  "/storage/emulated/0/Pictures/*",
];

class DataManager {
  Map<String, int> summaryOfPhotoData = {};
  Map<String, Coordinate> summaryOfCoordinate = {};
  PhotoDataManager photoDataManager;
  LocationDataManager locationDataManager;
  DataManager(this.photoDataManager, this.locationDataManager) {}

  List<String> files = [];

  Future<void> init() async {
    print("DataManager instance is initializing..");
    // var a = await readSummaryOfPhotoData();
    List<String>? filesNotUpdated = [];

    //get list of image files from local. --> update new images
    files = await getAllFiles();
    //read previously processed Info
    await readInfo();
    await readSummaryOfPhoto();
    await readSummaryOfLocation();

    // find the files which are in local but not in Info
    filesNotUpdated = await matchFilesAndInfo();
    // update info which are not updated
    await addFilesToInfo(filesNotUpdated);
    await updateDateOnInfo(filesNotUpdated);
    await updateDatesFromInfo();
    await updateExifOnInfo(filesNotUpdated);
    await writeInfo(filesNotUpdated, false);

    //find the dates which are out of date based on the number of photo.
    List<String>? datesOutOfDate = await updateSummaryOfPhotoFromInfo();

    //update the summaryOflocation only on the specific date.
    await updateSummaryOfLocationDataFromInfo(datesOutOfDate);

    await writeSummaryOfLocation(datesOutOfDate, false);
    await writeSummaryOfPhoto(datesOutOfDate, false);
    print("DataManager initialization done");
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
    files = files.where((element) => !element.contains('thumbnail')).toList();
    return files;
  }

  // i) check whether this file is contained in Info
  // ii) check whether this file is saved previously.
  Future<List<String>?> matchFilesAndInfo() async {
    List<String>? filesNotUpdated = [];
    List<String> filenamesFromInfo = global.infoFromFiles.keys.toList();

    for (int i = 0; i < files.length; i++) {
      String filename = files.elementAt(i);
      // if (i % 100 == 0)
      print("matchFilesAndInfo : $i / ${files.length}");
      int indexInInfo =
          filenamesFromInfo.indexWhere((element) => element == filename);
      if (indexInInfo == -1) {
        filesNotUpdated.add(filename);
        continue;
      }
      filenamesFromInfo.remove(filename);
      DateTime? dateTimeInInfo = global.infoFromFiles[filename]?.datetime;
      if (dateTimeInInfo == null) {
        filesNotUpdated.add(filename);
        continue;
      }
    }
    if (filesNotUpdated == []) return null;
    return filesNotUpdated;
  }

  Future<void> addFilesToInfo(List<String>? filenames) async {
    if (filenames == null) return;
    for (int i = 0; i < filenames.length; i++) {
      if (i % 100 == 0) print("addFilesToInfo $i / ${filenames.length}");
      String filename = filenames.elementAt(i);
      global.infoFromFiles[filename] = InfoFromFile();
    }
  }

  Future<void> updateDatesFromInfo() async {
    List dates = List.generate(global.infoFromFiles.length, (i) {
      var key = global.infoFromFiles.keys.elementAt(i);
      return global.infoFromFiles[key]?.date;
    });
    List datetimes = List.generate(global.infoFromFiles.length, (i) {
      var key = global.infoFromFiles.keys.elementAt(i);
      return global.infoFromFiles[key]?.datetime;
    });

    dates.removeWhere((i) => i == null);
    datetimes.removeWhere((i)=>i == null);
    global.dates = dates;
    global.datetimes = datetimes;
  }

  Future<void> updateDateOnInfo(List<String>? filenames) async {
    if (filenames == null) filenames = global.infoFromFiles.keys.toList();

    for (int i = 0; i < filenames.length; i++) {
      String filename = filenames.elementAt(i);
      String? inferredDatetime = inferDatetimeFromFilename(filename);
      if (inferredDatetime != null) {
        global.infoFromFiles[filename]?.datetime =
            DateTime.parse(inferredDatetime);
        global.infoFromFiles[filename]?.date = inferredDatetime.substring(0, 8);

        // if (i % 100 == 0)
        //   print("updateDateOnInfo : $i / ${filenames.length},"
        //       "$filename, ${global.infoFromFiles[filename].toString()}");

      }
      print("updateDateOnInfo : $i / ${filenames.length},"
          "$filename, ${global.infoFromFiles[filename].toString()}");
    }
  }

  Future<void> updateExifOnInfo(List<String>? filenames) async {
    if (filenames == null) filenames = global.infoFromFiles.keys.toList();

    for (int i = 0; i < filenames.length; i++) {
      String filename = filenames.elementAt(i);
      List ExifData = await getExifInfoOfFile(filename);
      print(
          "updateExifOninfo : $i / ${filenames.length}, $filename, ${ExifData[0]}, ${ExifData[1]}");
      global.infoFromFiles[filename]?.coordinate = ExifData[1];

      if (ExifData[1] != null) {
        global.infoFromFiles[filename]?.distance =
            calculateDistanceToRef(ExifData[1]);
      }

      //if datetime is updated from filename, then does not overwrite with exif
      if (global.infoFromFiles[filename]?.datetime != null) continue;

      //update the datetime of EXif if there is datetime is null from filename
      if ((ExifData[0] != null)) {
        global.infoFromFiles[filename]?.datetime = DateTime.parse(ExifData[0]);
        global.infoFromFiles[filename]?.date = ExifData[0].substring(0, 8);
        continue;
      }
      //if there is no info from filename and exif, then use changed datetime.
      DateTime datetime =
          DateTime.parse(formatDatetime(FileStat.statSync(filename).changed));
      global.infoFromFiles[filename]?.datetime = datetime;
      global.infoFromFiles[filename]?.date = formatDate(datetime);
    }
  }

  Future<List<String>> updateSummaryOfPhotoFromInfo() async {
    List dates = global.dates;
    dates.removeWhere((i) => i == null);
    Set setOfDates = dates.toSet();
    List<String> datesOutOfDate = [];
    for (int i = 0; i < setOfDates.length; i++) {
      String date = setOfDates.elementAt(i);
      int numberOfPhoto = dates.where((c) => (c == date)).length;

      // update the date
      // i) if the number of photo is different from read result and update result,
      // ii) if that date is not contained in the summaryOfPhoto
      if ((global.summaryOfPhotoData[date] != numberOfPhoto) ||
          (!global.summaryOfPhotoData.keys.contains(date))) {
        datesOutOfDate.add(date);
        global.summaryOfPhotoData[date] =
            dates.where((c) => (c == date)).length;
      }
    }
    print("updateSummaryOfPhoto done");
    return datesOutOfDate;
  }

  Future<void> updateSummaryOfLocationDataFromInfo(
      List<String> datesOufOfDate) async {
    print("updateSummaryOfLocationData..");
    List listOfDates = datesOufOfDate;
    Set setOfDates = listOfDates.toSet();
    for (int i = 0; i < setOfDates.length; i++) {
      print("updateSummaryOfLocationData.. $i / ${setOfDates.length}");
      String date = setOfDates.elementAt(i);
      global.summaryOfLocationData[date] =
          locationDataManager.getMaxDistanceOfDate(date);
    }
  }

  Future<List<String>> resetInfoFromFiles() async {
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

    files = files.where((element) => !element.contains('thumbnail')).toList();

    global.infoFromFiles = {};
    global.infoFromFiles.addAll(
        Map.fromIterable(files, key: (v) => v, value: (v) => InfoFromFile()));

    return files;
  }

  Future<void> writeInfo(List<String>? filenames, bool overwrite) async {
    if (overwrite == null) overwrite = false;
    if (filenames == null) filenames = global.infoFromFiles.keys.toList();

    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/InfoOfFiles.csv');

    if (!((await file.exists())) || overwrite) {
      print("overwritting");
      await file.writeAsString(
          'filename,datetime,date,latitude,longitude,distance\n',
          mode: FileMode.write);
    }
    var infoFromFiles = global.infoFromFiles;
    for (int i = 0; i < filenames.length; i++) {
      String filename = filenames.elementAt(i);

      await file.writeAsString(
          '${filename},'
          '${infoFromFiles[filename]!.datetime},'
          '${infoFromFiles[filename]!.date},'
          '${infoFromFiles[filename]!.coordinate?.latitude},'
          '${infoFromFiles[filename]!.coordinate?.longitude},'
          '${infoFromFiles[filename]!.distance}\n',
          mode: FileMode.append);
      if (i % 100 == 0) print("writingInfo.. $i/${filenames.length}");
    }
  }

  Future<void> readInfo() async {
    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/InfoOfFiles.csv');

    bool isFileExist = await file.exists();
    if (!isFileExist) return;

    var data = await openFile(file.path);
    for (int i = 1; i < data.length; i++) {
      if (data[i].length < 2) return;
      if (i % 100 == 0) print("readInfo.. $i / ${data.length}, ${data[i]}");

      InfoFromFile infoFromFile = InfoFromFile();
      infoFromFile.datetime = parseToDatetime(data[i][1]);
      infoFromFile.date = parseToString(data[i][2]);
      infoFromFile.coordinate =
          Coordinate(parseToDouble(data[i][3]), parseToDouble(data[i][4]));
      infoFromFile.distance =
          data[i][5] == "null" ? null : parseToDouble(data[i][5]);
      global.infoFromFiles[data[i][0]] = infoFromFile;
    }
  }

  Future<void> writeSummaryOfLocation(
      List<String> datesOutOfDate, bool overwrite) async {
    if (overwrite == null) overwrite = false;
    if (datesOutOfDate == null)
      datesOutOfDate = global.infoFromFiles.keys.toList();

    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/summaryOfLocation.csv');

    if (!((await file.exists())) || overwrite) {
      print("overwritting");
      await file.writeAsString('date,distance\n', mode: FileMode.write);
    }

    var summaryOfLocation = global.summaryOfLocationData;
    for (int i = 0; i < datesOutOfDate.length; i++) {
      if (i % 100 == 0) print("writingInfo.. $i/${datesOutOfDate.length}");

      String date = datesOutOfDate.elementAt(i);
      await file.writeAsString(
          '${date},'
          '${summaryOfLocation[date]}\n',
          mode: FileMode.append);
    }
  }

  Future<void> readSummaryOfLocation() async {
    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/summaryOfLocation.csv');

    bool isFileExist = await file.exists();
    if (!isFileExist) return;

    var data = await openFile(file.path);
    for (int i = 1; i < data.length; i++) {
      if (data[i].length < 2) return;
      if (i % 100 == 0)
        print("readSummaryOfLocation.. $i / ${data.length}, ${data[i]}");
      global.summaryOfLocationData[data[i][0].toString()] = data[i][1];
    }
  }

  Future<void> writeSummaryOfPhoto(
      List<String> datesOutOfDate, bool overwrite) async {
    if (overwrite == null) overwrite = false;
    if (datesOutOfDate == null)
      datesOutOfDate = global.infoFromFiles.keys.toList();

    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/summaryOfPhoto.csv');

    if (!((await file.exists())) || overwrite) {
      print("overwritting");
      await file.writeAsString('date,numberOfPhoto\n', mode: FileMode.write);
    }

    var summaryOfPhoto = global.summaryOfPhotoData;
    for (int i = 0; i < datesOutOfDate.length; i++) {
      if (i % 100 == 0) print("writingInfo.. $i/${datesOutOfDate.length}");
      String date = datesOutOfDate.elementAt(i);
      await file.writeAsString(
          '${date},'
          '${summaryOfPhoto[date]}\n',
          mode: FileMode.append);
    }
  }

  Future<void> readSummaryOfPhoto() async {
    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/summaryOfPhoto.csv');

    bool isFileExist = await file.exists();
    if (!isFileExist) return;

    var data = await openFile(file.path);
    for (int i = 1; i < data.length; i++) {
      if (data[i].length < 2) return;
      if (i % 100 == 0)
        print("readSummaryOfPhoto.. $i / ${data.length}, ${data[i]}");
      global.summaryOfPhotoData[data[i][0].toString()] = data[i][1];
    }
  }
}

DateTime? parseToDatetime(input) {
  if (input == null) return null;
  if (input.runtimeType == String) {
    try {
      return DateTime.parse(input);
    } catch (e) {
      print("error in parseToDatetime, invalid format? $e");
      return null;
    }
  }
  return input;
}

String? parseToString(input) {
  if (input == "null") return null;
  if (input == null) return null;
  return input.toString();
}

double? parseToDouble(input) {
  if (input == "null") return null;
  if (input == null) return null;
  if (input.runtimeType == "String") return double.parse(input);
  if (input.runtimeType == double) return input;
  if (input.runtimeType == int) return input.toDouble();
  return double.parse(input);
}
