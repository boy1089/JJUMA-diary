import 'dart:io';
import 'package:glob/list_local_fs.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:glob/glob.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Photo/PhotoDataManager.dart';
import 'package:test_location_2nd/Location/LocationDataManager.dart';
import "package:test_location_2nd/Location/Coordinate.dart";
import 'infoFromFile.dart';

List<String> pathsToPhoto = [
  "/storage/emulated/0/DCIM",
  "/storage/emulated/0/DCIM/Camera",
  "/storage/emulated/0/Pictures",
  "/storage/emulated/0/Pictures/*",
  "/storage/emulated/0/Pictures/*/*",
];

class DataManager {
  Map<String, int> summaryOfPhotoData = {};
  Map<String, Coordinate> summaryOfCoordinate = {};
  PhotoDataManager photoDataManager;
  LocationDataManager locationDataManager;
  DataManager(this.photoDataManager, this.locationDataManager) {}

  List<String> files = [];
  List<String>? filesNotUpdated = [];
  List<String>? datesOutOfDate = [];

  Future<void> init() async {
    Stopwatch stopwatch = Stopwatch()..start();
    print("DataManager instance is initializing..");
    // var a = await readSummaryOfPhotoData();

    //get list of image files from local. --> update new images
    files = await getAllFiles();
    print("time elapsed : ${stopwatch.elapsed}");
    //read previously processed Info
    await readInfo([]);
    print("time elapsed : ${stopwatch.elapsed}");
    await readSummaryOfPhoto();
    print("time elapsed : ${stopwatch.elapsed}");
    await readSummaryOfLocation();
    print("time elapsed : ${stopwatch.elapsed}");
    // find the files which are in local but not in Info
    if (global.infoFromFiles.length > 1000)
      filesNotUpdated = await matchFilesAndInfo();
    print("time elapsed : ${stopwatch.elapsed}");
    // update info which are not updated
    await addFilesToInfo(filesNotUpdated);
    print("time elapsed : ${stopwatch.elapsed}");

    await updateDateOnInfo(filesNotUpdated);
    print("time elapsed : ${stopwatch.elapsed}");

    var result = await compute(updateDatesFromInfo, [global.infoFromFiles]);
    print("time elapsed : ${stopwatch.elapsed}");

    global.setOfDates = result[0];
    global.datetimes = result[1];
    global.dates = result[2];

    //find the dates which are out of date based on the number of photo.
    global.summaryOfPhotoData = await compute(updateSummaryOfPhotoFromInfo,
        [global.setOfDates, global.summaryOfPhotoData]);
    print("time elapsed : ${stopwatch.elapsed}");

    print("DataManager initialization done");
  }

  void executeSlowProcesses() async {
    Stopwatch stopwatch = new Stopwatch()..start();

    if (filesNotUpdated == null) return;

    int lengthOfFiles = filesNotUpdated!.length;
    for (int i = 0; i < lengthOfFiles / 100.floor(); i++) {
      // for (int i = 0; i < 5; i++) {
      print("executingSlowProcesses... $i / ${lengthOfFiles / 100.floor()}");

      //part of Files
      List<String> partOfFilesNotupdated = filesNotUpdated!.sublist(i * 100,
          lengthOfFiles < (i + 1) * 100 ? lengthOfFiles : (i + 1) * 100);

      // await updateExifOnInfo(partOfFilesNotupdated);
      global.infoFromFiles = await compute(updateExifOnInfo_compute,
          [partOfFilesNotupdated, global.infoFromFiles]);

      if (i % 5 == 0) {
        var result = await compute(updateDatesFromInfo, [global.infoFromFiles]);
        global.setOfDates = result[0];
        global.datetimes = result[1];
        global.dates = result[2];

        //update the summaryOflocation only on the specific date.

        global.summaryOfPhotoData = await compute(updateSummaryOfPhotoFromInfo,
            [global.setOfDates, global.summaryOfPhotoData]);
        global.summaryOfLocationData = await compute(
            updateSummaryOfLocationDataFromInfo_compute,
            [global.setOfDates, global.summaryOfLocationData, global.infoFromFiles]);

        await writeInfo(null, true);
        await writeSummaryOfLocation2(null, true);
        await writeSummaryOfPhoto2(null, true);
      }
    }
    //update the summaryOflocation only on the specific date.
    global.summaryOfPhotoData = await compute(updateSummaryOfPhotoFromInfo,
        [global.setOfDates, global.summaryOfPhotoData]);
    // await updateSummaryOfLocationDataFromInfo(null);
    // await updateSummaryOfLocationDataFromInfo(null);

    global.summaryOfLocationData = await compute(
        updateSummaryOfLocationDataFromInfo_compute,
        [global.setOfDates, global.summaryOfLocationData, global.infoFromFiles]);

    await writeInfo(null, true);
    await writeSummaryOfLocation2(null, true);
    await writeSummaryOfPhoto2(null, true);

    print("executeSlowProcesses done,executed in ${stopwatch.elapsed}");
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

  // i) check whether this file is contained in Info
  // ii) check whether this file is saved previously.
  Future<List<String>?> matchFilesAndInfo() async {
    List<String>? filesNotUpdated = [];
    List<String> filenamesFromInfo = global.infoFromFiles.keys.toList();

    for (int i = 0; i < files.length; i++) {
      String filename = files.elementAt(i);
      if (i % 1000 == 0) print("matchFilesAndInfo : $i / ${files.length}");

      bool isContained =
          filenamesFromInfo.contains(filename);
      if (!isContained) {
        filesNotUpdated.add(filename);
        continue;
      }

      filenamesFromInfo.remove(filename);


      DateTime? dateTimeInInfo = global.infoFromFiles[filename]?.datetime;
      Coordinate? coordinateInInfo = global.infoFromFiles[filename]?.coordinate;

      if (dateTimeInInfo == null || coordinateInInfo?.latitude == null) {
        filesNotUpdated.add(filename);
        continue;
      }
    }
    if (filesNotUpdated == []) return null;
    return filesNotUpdated;
  }

  Future<void> addFilesToInfo(List<String>? filenames) async {
    if (filenames.runtimeType==null || filenames!.isEmpty) filenames = files;

    for (int i = 0; i < filenames!.length; i++) {
      if (i % 100 == 0) print("addFilesToInfo $i / ${filenames.length}");
      String filename = filenames.elementAt(i);
      global.infoFromFiles[filename] = InfoFromFile();
    }
  }

  Future<List> updateDatesFromInfo(List input) async {
    if (input.isNotEmpty) {
      global.infoFromFiles = input[0];
    }
    List<String?> dates = [];
    List<DateTime?> datetimes = [];

    List<InfoFromFile> values = global.infoFromFiles.values.toList();
    for (int i = 0; i < values.length; i++) {
      InfoFromFile value = values.elementAt(i);
      dates.add(value.date);
      datetimes.add(value.datetime);
    }
    global.dates = dates;
    dates.removeWhere((i) => i == null);
    datetimes.removeWhere((i) => i == null);
    global.setOfDates = dates;
    global.datetimes = datetimes;

    return [global.setOfDates, global.datetimes, global.dates];
  }

  Future<void> updateDateOnInfo(List<String>? filenames) async {
    if (filenames == null|| filenames!.isEmpty) filenames = global.infoFromFiles.keys.toList();

    for (int i = 0; i < filenames.length; i++) {
      String filename = filenames.elementAt(i);
      String? inferredDatetime = inferDatetimeFromFilename(filename);
      // print(inferredDatetime);
      if (inferredDatetime != null) {
        global.infoFromFiles[filename]?.datetime =
            DateTime.parse(inferredDatetime);
        global.infoFromFiles[filename]?.date = inferredDatetime.substring(0, 8);

        if (i % 1000 == 0)
          print("updateDateOnInfo : $i / ${filenames.length},"
              "$filename, ${global.infoFromFiles[filename].toString()}");
      }
      // print("updateDateOnInfo : $i / ${filenames.length},"
      //     "$filename, ${global.infoFromFiles[filename].toString()}");
    }
  }

  Future<void> updateExifOnInfo(List<String>? filenames) async {
    if (filenames == null) filenames = global.infoFromFiles.keys.toList();

    for (int i = 0; i < filenames.length; i++) {
      String filename = filenames.elementAt(i);
      List ExifData = await getExifInfoOfFile(filename);
      if (i % 100 == 0)
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
      // print("filename : $filename, ExifData : ${ExifData[0]}");
      if ((ExifData[0] != null) &
          (ExifData[0] != "") &
          (ExifData[0] != "null")) {
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

  //input : [filenames, global.infoFromFiles]
  Future<Map<String, InfoFromFile>> updateExifOnInfo_compute(List input) async {
    List<String> filenames = input[0];
    global.infoFromFiles = input[1];
    if (filenames == null) filenames = global.infoFromFiles.keys.toList();

    for (int i = 0; i < filenames.length; i++) {
      String filename = filenames.elementAt(i);
      List ExifData = await getExifInfoOfFile(filename);
      if (i % 100 == 0)
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
      // print("filename : $filename, ExifData : ${ExifData[0]}");
      if ((ExifData[0] != null) &
          (ExifData[0] != "") &
          (ExifData[0] != "null")) {
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
    return global.infoFromFiles;
  }

  Future<Map<String, int>> updateSummaryOfPhotoFromInfo(List input) async {
    List dates = global.setOfDates;
    if (input.isNotEmpty) {
      dates = input[0];
      global.summaryOfPhotoData = input[1];
    }

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
    return global.summaryOfPhotoData;
  }

  Future<Map> updateSummaryOfLocationDataFromInfo(
      List<String>? datesOutOfDate) async {
    List listOfDates = [];
    listOfDates =
        (datesOutOfDate == null) ? global.setOfDates.toList() : datesOutOfDate!;

    print("updateSummaryOfLocationData..");

    Set setOfDates = listOfDates.toSet();
    for (int i = 0; i < setOfDates.length; i++) {
      if (i % 100 == 0)
        print("updateSummaryOfLocationData.. $i / ${setOfDates.length}");
      String date = setOfDates.elementAt(i);
      global.summaryOfLocationData[date] =
          locationDataManager.getMaxDistanceOfDate(date);
    }
    return global.summaryOfPhotoData;
  }

  //input : [global.dates, global.summaryOfPhotoData, global.infoFromFiles]
  Future<Map<String, double>> updateSummaryOfLocationDataFromInfo_compute(
      List input) async {
    List listOfDates = input[0].toList();
    global.infoFromFiles = input[2];
    global.setOfDates = input[0];
    print("updateSummaryOfLocationData..");

    Set setOfDates = listOfDates.toSet();
    // Stopwatch stopwatch = new Stopwatch();
    for (int i = 0; i < setOfDates.length; i++) {
      if (i % 100 == 0) {
        // stopwatch..start();
        print("updateSummaryOfLocationData.. $i / ${setOfDates.length}");
      }
      String date = setOfDates.elementAt(i);
      input[1][date] = locationDataManager.getMaxDistanceOfDate(date);
    }
    return input[1];
  }

  Future<List<String>> resetInfoFromFiles() async {
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
    String stringToWrite = "";
    for (int i = 0; i < filenames.length; i++) {
      String filename = filenames.elementAt(i);
      stringToWrite += '${filename},'
          '${infoFromFiles[filename]!.datetime},'
          '${infoFromFiles[filename]!.date},'
          '${infoFromFiles[filename]!.coordinate?.latitude},'
          '${infoFromFiles[filename]!.coordinate?.longitude},'
          '${infoFromFiles[filename]!.distance}\n';

      if (i % 100 == 0) {
        await file.writeAsString(stringToWrite, mode: FileMode.append);
        stringToWrite = "";
        print("writingInfo.. $i/${filenames.length}");
      }
      ;
    }
    await file.writeAsString(stringToWrite, mode: FileMode.append);
  }

  Future<Map<String, InfoFromFile>> readInfo(List input) async {

    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/InfoOfFiles.csv');

    bool isFileExist = await file.exists();
    if (!isFileExist) return {};

    var data = await openFile(file.path);
    // Stopwatch stopwatch2 = Stopwatch()..start();
    for (int i = 1; i < data.length; i++) {
    // for (int i = 1; i < 100; i++) {
      if (data[i].length < 2) return {};
      // if (i % 1000 == 0)
      // print("readInfo.. $i / ${data.length}, ${data[i]}");
      // Stopwatch stopwatch = Stopwatch()..start();
      InfoFromFile infoFromFile = InfoFromFile();
      var data_temp = data[i];

      int lengthOfData = data_temp.length;
      // print("$i, time elapsed : ${stopwatch.elapsed}");
      infoFromFile.datetime = parseToDatetime(data_temp[lengthOfData - 5]);
      // print("$i, time elapsed : ${stopwatch.elapsed}");

      infoFromFile.date = parseToString(data_temp[lengthOfData - 4]);

      // print("$i, time elapsed : ${stopwatch.elapsed}");
      infoFromFile.coordinate = Coordinate(
          parseToDouble(data_temp[lengthOfData - 3]),
          parseToDouble(data_temp[lengthOfData - 2]));
      // print("$i, time elapsed : ${stopwatch.elapsed}");

      infoFromFile.distance = data_temp[lengthOfData - 1] == "null"
          ? null
          : parseToDouble(data_temp[lengthOfData - 1]);
      // print("$i, time elapsed : ${stopwatch.elapsed}");

      String filename = data_temp[0];
      // print("$i, time elapsed : ${stopwatch.elapsed}");

      if (lengthOfData > 5) {
        filename = "";
        for (int j = 0; j < lengthOfData - 5; j++) {
          filename += data_temp[j] + ',';
        }
        filename = filename.substring(0, filename.length - 1);
      }
      // print("$i, time elapsed : ${stopwatch.elapsed}");

      global.infoFromFiles[filename] = infoFromFile;
      // print("$i, time elapsed : ${stopwatch.elapsed}");
    }
    // print(" time elapsed : ${stopwatch2.elapsed}");
    return global.infoFromFiles;
  }

  Future<void> writeSummaryOfLocation2(
      List<String>? datesOutOfDate, bool overwrite) async {
    Set setOfDates = global.setOfDates.toSet();
    if (overwrite == null) overwrite = false;
    if (datesOutOfDate != null) {
      setOfDates = datesOutOfDate.toSet();
    }
    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/summaryOfLocation.csv');

    if (!((await file.exists())) || overwrite) {
      print("overwritting");
      await file.writeAsString('date,distance\n', mode: FileMode.write);
    }

    var summaryOfLocation = global.summaryOfLocationData;
    String stringToWrite = "";
    for (int i = 0; i < setOfDates.length; i++) {
      if (i % 100 == 0)
        print("writingSummaryOfLocation.. $i/${setOfDates.length}");

      String date = setOfDates.elementAt(i);
      stringToWrite += '${date},${summaryOfLocation[date]}\n';
    }
    await file.writeAsString(stringToWrite, mode: FileMode.append);
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

  Future<void> writeSummaryOfPhoto2(
      List<String>? datesOutOfDate, bool overwrite) async {
    Set setOfDates = global.setOfDates.toSet();
    if (overwrite == null) overwrite = false;
    if (datesOutOfDate != null) {
      setOfDates = datesOutOfDate.toSet();
    }
    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/summaryOfPhoto.csv');

    if (!((await file.exists())) || overwrite) {
      print("overwritting");
      await file.writeAsString('date,numberOfPhoto\n', mode: FileMode.write);
    }

    var summaryOfPhoto = global.summaryOfPhotoData;
    String stringToWrite = "";
    for (int i = 0; i < setOfDates.length; i++) {
      if (i % 100 == 0) print("writingInfo.. $i/${setOfDates.length}");
      String date = setOfDates.elementAt(i);
      stringToWrite += '${date},${summaryOfPhoto[date]}\n';
    }
    await file.writeAsString(stringToWrite, mode: FileMode.append);
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
