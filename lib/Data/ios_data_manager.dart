import 'dart:io';
import 'package:glob/list_local_fs.dart';
import 'package:flutter/foundation.dart';
import 'package:glob/glob.dart';
import 'package:jjuma.d/Data/data_manager_interface.dart';
import 'package:jjuma.d/Util/DateHandler.dart';
import 'package:jjuma.d/Util/Util.dart';
import 'package:jjuma.d/Util/global.dart' as global;
import 'package:jjuma.d/Location/location_data_manager.dart';
import "package:jjuma.d/Location/coordinate.dart";
import '../pages/event.dart';
import 'info_from_file.dart';
import 'package:jjuma.d/Data/directories.dart';
import 'data_repository.dart';

class IosDataManager extends ChangeNotifier implements DataManagerInterface {
  IosDataManager._privateConstructor();
  static final IosDataManager _instance = IosDataManager._privateConstructor();
  factory IosDataManager() {
    return _instance;
  }

  Map<String, int> summaryOfPhotoData = {};
  Map<String, double> summaryOfLocationData = {};
  Map<String, Coordinate> summaryOfCoordinate = {};

  Map<String, Map<String, String>> noteForChart2 = {};
  Map<String, Map<String, String?>> filenameOfFavoriteImages = {};

  List setOfDates = [];
  List dates = [];
  List datetimes = [];
  List setOfDatetimes = [];
  List files = [];
  List? filesNotUpdated = [];
  List<String>? datesOutOfDate = [];

  Map<dynamic, InfoFromFile> infoFromFiles = {};
  Map<String, Event> eventList = {};
  DataRepository dataRepository = DataRepository();

  void setFilenameOfFavoriteImage(DateTime datetime, String? indexOfFavoriteImage){}

  @override
  Future<void> init() async {
    Stopwatch stopwatch = Stopwatch()..start();

    print("DataManager instance is initializing..");
    //get list of image files from local. --> update new images
    files = await dataRepository.getAllFiles();
    infoFromFiles = await dataRepository.readInfoFromJson();
    summaryOfPhotoData = await dataRepository.readSummaryOfPhoto();
    summaryOfLocationData = await dataRepository.readSummaryOfLocation();
    notifyListeners();
    print("DataManager init, $files");

    // find the files which are in local but not in Info
    filesNotUpdated = await matchFilesAndInfo();

    // update info which are not updated
    await addFilesToInfo(filesNotUpdated);
    print("addFilesToinfo done, time elapsed : ${stopwatch.elapsed}");

    var result = await updateDatesFromInfo([infoFromFiles, filesNotUpdated]);
    print("updateDatesFromInfo done, time elapsed : ${stopwatch.elapsed}");
    setOfDates = result[0];
    setOfDatetimes = result[1];
    dates = result[2];
    datetimes = result[3];

    print("date during init, ${dates.length}");

    //find the dates which are out of date based on the number of photo.
    summaryOfPhotoData = await compute(
        updateSummaryOfPhotoFromInfo, [setOfDates, summaryOfPhotoData]);
    print("updateSummaryOfPhoto done, time elapsed : ${stopwatch.elapsed}");
    notifyListeners();
  }

  static Future<Map<dynamic, InfoFromFile>> updateDatesOnInfo_ios(
      List input) async {
    List assetEntities = input[0];
    Map<dynamic, InfoFromFile> infoFromFiles = input[1];

    for (int i = 0; i < assetEntities.length; i++) {
      var assetEntity = assetEntities.elementAt(i);
      var filename = await assetEntity.titleAsync;
      String? inferredDatetime = inferDatetimeFromFilename(filename);
      if (inferredDatetime != null) {
        infoFromFiles[assetEntity]?.datetime = DateTime.parse(inferredDatetime);
        infoFromFiles[assetEntity]?.date = inferredDatetime.substring(0, 8);
      }
    }
    return infoFromFiles;
  }

  @override
  void executeSlowProcesses() async {
    if (filesNotUpdated!.isEmpty) return;
    print("executing slow process..");
    int lengthOfFiles = filesNotUpdated!.length;
    for (int i = 0; i < lengthOfFiles / 100.floor(); i++) {
      List partOfFilesNotupdated = filesNotUpdated!.sublist(i * 100,
          lengthOfFiles < (i + 1) * 100 ? lengthOfFiles : (i + 1) * 100);

      if (global.kOs == "ios")
        // infoFromFiles = await compute(updateDatesOnInfo_ios, [partOfFilesNotupdated, infoFromFiles]);
        infoFromFiles =
            await updateDatesOnInfo_ios([partOfFilesNotupdated, infoFromFiles]);
      await Future.delayed(Duration(seconds: 1));
      infoFromFiles = await updateExifOnInfo_compute(
          [partOfFilesNotupdated, infoFromFiles]);
      if (i % 5 == 0) {
        var result =
            await updateDatesFromInfo([infoFromFiles, filesNotUpdated]);
        setOfDates = result[0];
        setOfDatetimes = result[1];
        dates = result[2];
        datetimes = result[3];

        //update the summaryOflocation only on the specific date.
        summaryOfPhotoData = await updateSummaryOfPhotoFromInfo(
            [setOfDates, summaryOfPhotoData]);

        await dataRepository.writeInfoAsJson(infoFromFiles, true);
        await dataRepository.writeSummaryOfPhoto(
            summaryOfPhotoData, true, setOfDates);
        notifyListeners();
      }

      if (i % 10 == 0) {
        summaryOfLocationData =
            await updateSummaryOfLocationDataFromInfo2_compute([infoFromFiles]);
        await dataRepository.writeSummaryOfLocation(
            summaryOfLocationData, true, setOfDates);
      }
    }
    print("executing slow process..2");
    summaryOfPhotoData =
        await updateSummaryOfPhotoFromInfo([setOfDates, summaryOfPhotoData]);
    print("executing slow process..3");
    summaryOfLocationData = await updateSummaryOfLocationDataFromInfo_compute(
        [setOfDates, summaryOfLocationData, infoFromFiles]);
    print("executing slow process..4");
    await dataRepository.writeInfoAsJson(infoFromFiles, true);
    print("executing slow process..5");
    await dataRepository.writeSummaryOfLocation(
        summaryOfLocationData, true, setOfDates);
    print("executing slow process..6");
    await dataRepository.writeSummaryOfPhoto(
        summaryOfPhotoData, true, setOfDates);

    notifyListeners();
  }

  // i) check whether this file is contained in Info
  // ii) check whether this file is saved previously.
  @override
  Future<List?> matchFilesAndInfo() async {
    List? filesNotUpdated = [];
    List filenamesFromInfo = infoFromFiles.keys.toList();
    if (filenamesFromInfo
        .isNotEmpty) if (filenamesFromInfo.elementAt(0).runtimeType == String)
      filenamesFromInfo.sort((a, b) => a.compareTo(b));

    Map info = {...infoFromFiles};
    int j = 0;
    for (int i = 0; i < files.length; i++) {
      var filename = files.elementAt(i);
      int sublistIndex = j + 100 < filenamesFromInfo.length
          ? j + 100
          : filenamesFromInfo.length;
      bool isContained =
          filenamesFromInfo.sublist(j, sublistIndex).contains(filename);

      if (!isContained) {
        filesNotUpdated.add(filename);
        continue;
      }
      j += 1;

      bool? isUpdated = info[filename]?.isUpdated;

      if (!isUpdated!) {
        filesNotUpdated.add(filename);
        continue;
      }
    }
    if (filesNotUpdated == []) return null;
    return filesNotUpdated;
  }

  @override
  Future<void> addFilesToInfo(List? filenames) async {
    if (filenames!.isEmpty) filenames = files;
    print("filenames : $filenames");
    for (int i = 0; i < filenames.length; i++) {
      var filename = filenames.elementAt(i);
      if (infoFromFiles[filename] == null) {
        infoFromFiles[filename] = InfoFromFile(isUpdated: false);
      }
    }
  }

  static Future<List> updateDatesFromInfo(List input) async {
    print("input : $input");
    List filesNotUpdated = [];
    Map<dynamic, InfoFromFile> infoFromFiles = {};
    if (input.isNotEmpty) {
      infoFromFiles = input[0];
      filesNotUpdated = input[1];
    }

    List<String?> dates = [];
    List<DateTime?> datetimes = [];
    List setOfDates = [];
    List setOfDatetimes = [];

    List<InfoFromFile> values = infoFromFiles.values.toList();

    for (int i = 0; i < values.length; i++) {
      dates.add(values.elementAt(i).date);
      datetimes.add(values.elementAt(i).datetime);
    }

    dates = [...dates];
    datetimes = [...datetimes];

    dates.removeWhere((i) => i == null);
    datetimes.removeWhere((i) => i == null);
    setOfDates = dates;
    setOfDatetimes = datetimes;
    return [setOfDates, setOfDatetimes, dates, datetimes];
  }

  @override
  Future<void> updateDateOnInfo(List? input) async {
    if (input == null || input.isEmpty) input = infoFromFiles.keys.toList();

    //case for IOS
    if (input.elementAt(0).runtimeType != String) {
      // for (int i = 0; i < input.length; i++) {
      //   if (i % 100 == 0) print("$i / ${input.length}");
      //   var assetEntity = input.elementAt(i);
      //   String filename = await assetEntity.titleAsync;
      //   String? inferredDatetime = inferDatetimeFromFilename(filename);
      //   if (inferredDatetime != null) {
      //     infoFromFiles[assetEntity]?.datetime =
      //         DateTime.parse(inferredDatetime);
      //     infoFromFiles[assetEntity]?.date = inferredDatetime.substring(0, 8);
      //   }
      // }
      return;
    }
  }

  static Future<Map<dynamic, InfoFromFile>> updateExifOnInfo_compute(
      List input) async {
    List filenames = input[0];
    Map<dynamic, InfoFromFile> infoFromFiles = input[1];

    for (int i = 0; i < filenames.length; i++) {
      var filename = filenames.elementAt(i);
      List exifData = [];

      exifData = await getExifInfoOfFile_ios(filename);

      if (i % 100 == 0)
        print(
            "updateExifOnInfo : $i / ${filenames.length}, $filename, ${exifData[0]}, ${exifData[1]}");
      infoFromFiles[filename]?.coordinate = exifData[1];
      if (exifData[1] != null) {
        infoFromFiles[filename]?.distance = calculateDistanceToRef(exifData[1]);
      }
      print("${infoFromFiles[filename]?.coordinate}, ${infoFromFiles[filename]?.distance}");

      infoFromFiles[filename]?.isUpdated = true;
      //if datetime is updated from filename, then does not overwrite with exif
      if (infoFromFiles[filename]?.datetime != null) continue;
      //update the datetime of EXif if there is datetime is null from filename
      if ((exifData[0] != null) &
          (exifData[0] != "") &
          (exifData[0] != "null")) {
        infoFromFiles[filename]?.datetime = DateTime.parse(exifData[0]);
        infoFromFiles[filename]?.date = exifData[0].substring(0, 8);
        continue;
      }

      //if there is no info from filename and exif, then use changed datetime.
      DateTime datetime =
          DateTime.parse(formatDatetime(FileStat.statSync(filename).changed));
      infoFromFiles[filename]?.datetime = datetime;
      infoFromFiles[filename]?.date = formatDate(datetime);
    }
    return infoFromFiles;
  }

  static Future<Map<String, int>> updateSummaryOfPhotoFromInfo(
      List input) async {
    List dates = input[0];
    Map<String, int> counts = {};

    for (int i = 0; i < dates.length; i++) {
      String? date = dates[i];
      if (date == null) continue;
      bool isContained = counts.containsKey(date);
      if (isContained) {
        counts[date] = counts[date]! + 1;
        continue;
      }
      counts[date] = 1;
    }
    return counts;
  }

  static Future<Map<String, double>>
      updateSummaryOfLocationDataFromInfo2_compute(List input) async {
    Map<dynamic, InfoFromFile> infoFromFiles = input[0];
    var infoFromFiles2 = [...infoFromFiles.values];
    Map<String, double> distances = {};

    for (int i = 0; i < infoFromFiles2.length; i++) {
      InfoFromFile infoFromFile = infoFromFiles2.elementAt(i);
      String? date = infoFromFile.date;
      if (date == null) continue;

      bool isContained = distances.containsKey(date);
      bool isNull = infoFromFile.distance == null ? true : false;

      if (isNull) {
        continue;
      }
      print("$date, ${distances[date]}, ${infoFromFile.distance!}");
      if (isContained) {
        distances[date] = (distances[date]! > infoFromFile.distance!
            ? distances[date]
            : infoFromFile.distance)!;
        continue;
      }
      distances[date] = infoFromFile.distance!;
    }
    return distances;
  }

  //input : [global.dates, global.summaryOfPhotoData, infoFromFiles]
  static Future<Map<String, double>>
      updateSummaryOfLocationDataFromInfo_compute(List input) async {
    List listOfDates = input[0].toList();
    global.setOfDates = input[0];

    print("updateSummaryOfLocationData..");
    LocationDataManager locationDataManager = LocationDataManager(input[2]);
    Set setOfDates = listOfDates.toSet();
    for (int i = 0; i < setOfDates.length; i++) {
      String date = setOfDates.elementAt(i);
      input[1][date] = locationDataManager.getMaxDistanceOfDate(date);
    }
    return input[1];
  }

  @override
  Future<List<String>> resetInfoFromFiles() async {
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

    infoFromFiles = {};
    infoFromFiles.addAll({for (var v in files) v: InfoFromFile()});
    return files;
  }
  void setNote(DateTime datetime, String note){
    if (noteForChart2[datetime.year.toString()] == null)
      noteForChart2[datetime.year.toString()] = {};
    noteForChart2[datetime.year.toString()]![formatDate(datetime)] = note;
    dataRepository.writeNote(noteForChart2);
  }
  @override
  void addEvent(Event event) {
    this.eventList.addAll({formatDate2(event.images.values.first.datetime!):event});
  }




}
