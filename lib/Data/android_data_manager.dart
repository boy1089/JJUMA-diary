import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:glob/list_local_fs.dart';
import 'package:flutter/foundation.dart';
import 'package:glob/glob.dart';
import 'package:lateDiary/Data/data_manager_interface.dart';
import 'package:lateDiary/Data/summary_model.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/Location/LocationDataManager.dart';
import "package:lateDiary/Location/Coordinate.dart";
import 'package:ml_dataframe/ml_dataframe.dart';
import 'file_info_model.dart';
import 'package:lateDiary/Data/directories.dart';
import 'data_repository.dart';
import 'package:lateDiary/Location/Coordinate.dart';


class AndroidDataManager extends ChangeNotifier
    implements DataManagerInterface {
  AndroidDataManager._privateConstructor();
  static final AndroidDataManager _instance =
      AndroidDataManager._privateConstructor();
  factory AndroidDataManager() {
    return _instance;
  }

  Map<String, int> summaryOfPhotoData = {};
  Map<String, double> summaryOfLocationData = {};
  Map<String, Coordinate> summaryOfCoordinate = {};

  List setOfDates = [];
  List dates = [];
  List datetimes = [];
  List setOfDatetimes = [];
  SummaryModel summaryModel = SummaryModel();
  List files = [];
  List? filesNotUpdated = [];
  List<String>? datesOutOfDate = [];

  Map<dynamic, FileInfoModel> infoFromFiles = {};
  FilesInfoModel filesInfo = FilesInfoModel(data: DataFrame([[]]));

  DataRepository dataRepository = DataRepository();

  Future<void> init() async {
    Stopwatch stopwatch = Stopwatch()..start();

    print("DataManager instance is initializing..");
    //get list of image files from local. --> update new images
    files = await dataRepository.getAllFiles();
    infoFromFiles = await dataRepository.readInfoFromJson();
    filesInfo = dataRepository.fileInfos;
    summaryOfPhotoData = await dataRepository.readSummaryOfPhoto();
    summaryOfLocationData = await dataRepository.readSummaryOfLocation();
    notifyListeners();

    await matchFilesAndInfo3(filesInfo);

    filesInfo = await updateFileInfo(filesInfo);
    filesInfo.updateAll();
    // print(filesInfo.distances);
    summaryModel = SummaryModel.fromFilesInfo(filesInfoModel: filesInfo);
    print(summaryModel.locations);
    notifyListeners();
  }

  Future<List> getFileInfo(String path) async{
    String filename = path.split('/').last;
    String? inferredDatetime = null;
    DateTime? datetime = null;
    String? date = null;
    Coordinate? coordinate = null;
    double? distance = null;
    bool isUpdated = false;

    inferredDatetime = inferDatetimeFromFilename(path);
    if (inferredDatetime != null) {
      datetime = DateTime.parse(inferredDatetime);
      date = inferredDatetime.substring(0, 8);
    }

    //update coordinate
    List exifData = [];
    exifData = await getExifInfoOfFile(path);
    coordinate = exifData[1];
    if(exifData[1] != null){
      distance = calculateDistanceToRef(exifData[1]);
    }
    isUpdated = true;


    if(datetime != null) return [filename, datetime, date, coordinate, distance, isUpdated];
    if ((exifData[0] != null) &
    (exifData[0] != "") &
    (exifData[0] != "null")){
      datetime = DateTime.parse(exifData[0]);
      date = exifData[0].substring(0, 8);
      return [filename, datetime, date, coordinate, distance, isUpdated];
    }

    datetime =
        DateTime.parse(formatDatetime(FileStat.statSync(path).changed));
    date = formatDate(datetime);
    return [filename, datetime, date, coordinate, distance, isUpdated];
  }

  Future<FilesInfoModel> updateFileInfo(FilesInfoModel fileInfos) async {

    for(var column in fileInfos.data.series.toList().sublist(1)){
      if(!column.data.elementAt(columns.isUpdated.index)){
        String path = column.name;
        String? inferredDatetime = null;
        DateTime? datetime = null;
        String? date = null;
        Coordinate? coordinate = null;
        double? distance = null;
        bool isUpdated = false;

        List fileInfo = await getFileInfo(path);
        fileInfos.updateData(fileInfos.data.dropSeries(names : [path]));
        fileInfos.updateData(fileInfos.data.addSeries(Series(path, fileInfo)));

      }
    }
    return fileInfos;

  }

  void executeSlowProcesses() async {

    notifyListeners();
  }

  // i) check whether this file is contained in Info
  // ii) check whether this file is saved previously.
  Future<List?> matchFilesAndInfo2() async {
    return [];
  }

  Future<FilesInfoModel> matchFilesAndInfo3(FilesInfoModel fileInfos) async {
    List? filesNotUpdated = [];
    List filenamesFromInfo = fileInfos.data.header.toList().sublist(1);
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
        fileInfos.data = fileInfos.data.addSeries(
            Series(filename, [null, null, null, null, null, false]));
        continue;
      }
    }
    return fileInfos;
  }

  Future<void> addFilesToInfo(List? filenames) async {
    if (filenames!.isEmpty) filenames = files;
    print("Files Not updated : $filenames");
    for (int i = 0; i < filenames.length; i++) {
      var filename = filenames.elementAt(i);
      if (infoFromFiles[filename] == null) {
        infoFromFiles[filename] = FileInfoModel(isUpdated: false);
      }
    }
  }

  Future<void> addFilesToInfo2(List? filenames) async {
    if (filenames!.isEmpty) filenames = files;
    print("Files Not updated : $filenames");
    for (int i = 0; i < filenames.length; i++) {
      var filename = filenames.elementAt(i);
      if (infoFromFiles[filename] == null) {
        infoFromFiles[filename] = FileInfoModel(isUpdated: false);
      }
      if (!filesInfo.data.header.contains(filename)) {
        filesInfo.data.addSeries(Series(
            filename, [List.generate(columns.values.length, (index) => null)]));
      }
    }
  }

  static Future<List> updateDatesFromInfo(List input) async {
    print("input : $input");
    List filesNotUpdated = [];
    Map<dynamic, FileInfoModel> infoFromFiles = {};
    if (input.isNotEmpty) {
      infoFromFiles = input[0];
      filesNotUpdated = input[1];
    }

    List<String?> dates = [];
    List<DateTime?> datetimes = [];
    List setOfDates = [];
    List setOfDatetimes = [];

    List<FileInfoModel> values = infoFromFiles.values.toList();

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

  Future<void> updateDateOnInfo(List? input) async {
    if (input == null || input.isEmpty) input = infoFromFiles.keys.toList();

    for (int i = 0; i < input.length; i++) {
      String filename = input.elementAt(i);
      String? inferredDatetime = inferDatetimeFromFilename(filename);
      if (inferredDatetime != null) {
        infoFromFiles[filename]?.datetime = DateTime.parse(inferredDatetime);
        infoFromFiles[filename]?.date = inferredDatetime.substring(0, 8);
      }
    }
  }

  Future<void> updateDateOnInfo2(List? input) async {
    if (input == null || input.isEmpty)
      input = filesInfo.data.header.toList().sublist(1);

    //case for android
    for (int i = 0; i < input.length; i++) {
      String filename = input.elementAt(i);
      String? inferredDatetime = inferDatetimeFromFilename(filename);
      if (inferredDatetime != null) {
        infoFromFiles[filename]?.datetime = DateTime.parse(inferredDatetime);
        infoFromFiles[filename]?.date = inferredDatetime.substring(0, 8);
      }
    }
  }

  static Future<Map<dynamic, FileInfoModel>> updateExifOnInfo_compute(
      List input) async {
    List filenames = input[0];
    Map<dynamic, FileInfoModel> infoFromFiles = input[1];

    for (int i = 0; i < filenames.length; i++) {
      var filename = filenames.elementAt(i);
      List exifData = [];
      exifData = await getExifInfoOfFile(filename);

      if (i % 100 == 0)
        print(
            "updateExifOnInfo : $i / ${filenames.length}, $filename, ${exifData[0]}, ${exifData[1]}");
      infoFromFiles[filename]?.coordinate = exifData[1];
      if (exifData[1] != null) {
        infoFromFiles[filename]?.distance = calculateDistanceToRef(exifData[1]);
      }
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
    Map<dynamic, FileInfoModel> infoFromFiles = input[0];
    var infoFromFiles2 = [...infoFromFiles.values];
    Map<String, double> distances = {};

    for (int i = 0; i < infoFromFiles2.length; i++) {
      FileInfoModel infoFromFile = infoFromFiles2.elementAt(i);
      String? date = infoFromFile.date;
      if (date == null) continue;

      bool isContained = distances.containsKey(date);
      bool isNull = infoFromFile.distance == null ? true : false;

      if (isNull) {
        continue;
      }

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
    infoFromFiles.addAll({for (var v in files) v: FileInfoModel()});
    return files;
  }
}
