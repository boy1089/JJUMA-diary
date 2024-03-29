import 'dart:io';
import 'package:flutter/material.dart';
import 'package:glob/list_local_fs.dart';
import 'package:flutter/foundation.dart';
import 'package:glob/glob.dart';
import 'package:jjuma.d/Data/data_manager_interface.dart';
import 'package:jjuma.d/Util/DateHandler.dart';
import 'package:jjuma.d/Util/Util.dart';
import 'package:jjuma.d/Util/global.dart' as global;
import 'package:jjuma.d/Location/location_data_manager.dart';
import "package:jjuma.d/Location/coordinate.dart";
import 'package:path_provider/path_provider.dart';
import '../pages/event.dart';
import 'info_from_file.dart';
import 'package:jjuma.d/Data/directories.dart';
import 'data_repository.dart';

class AndroidDataManager extends ChangeNotifier
    implements DataManagerInterface {
  AndroidDataManager._privateConstructor();
  static final AndroidDataManager _instance =
      AndroidDataManager._privateConstructor();
  factory AndroidDataManager() {
    return _instance;
  }

  @override
  Map<String, int> summaryOfPhotoData = {};
  @override
  Map<String, double> summaryOfLocationData = {};
  @override
  Map<String, Coordinate> summaryOfCoordinate = {};

  @override
  List setOfDates = [];
  @override
  List dates = [];
  @override
  List datetimes = [];
  @override
  List setOfDatetimes = [];
  @override
  List files = [];
  @override
  List? filesNotUpdated = [];
  @override
  List<String>? datesOutOfDate = [];

  @override
  Map<dynamic, InfoFromFile> infoFromFiles = {};
  @override
  Map<String, Event> eventList = {};

  @override
  DataRepository dataRepository = DataRepository();

  @override
  Map<String, Map<String, String>> noteForChart2 = {};
  @override
  Map<String, Map<String, String?>> filenameOfFavoriteImages = {};
  late final Directory directory;
  @override
  Future<void> init() async {
    directory = await getApplicationDocumentsDirectory();
    Stopwatch stopwatch = Stopwatch()..start();

    print("DataManager instance is initializing..");
    files = await dataRepository.getAllFiles();
    print("getAllFiles done, time elapsed : ${stopwatch.elapsed}");

    infoFromFiles = await dataRepository.readInfoFromJson();
    print("readInfoFromJson done, time elapsed : ${stopwatch.elapsed}");

    noteForChart2 = await dataRepository.readNote();
    print("read note done, time elapsed : ${stopwatch.elapsed}");

    filenameOfFavoriteImages = await dataRepository.readFilenameOfFavoriteImages();
    print("readIndexOfFavoriteImage done, time elapsed : ${stopwatch.elapsed}");

    // find the files which are in local but not in Info
    filesNotUpdated = await matchFilesAndInfo();
    print("matchFile done, time elapsed : ${stopwatch.elapsed}");

    // update info which are not updated
    await addFilesToInfo(filesNotUpdated);
    print("addFilesToinfo done, time elapsed : ${stopwatch.elapsed}");

    await updateDateOnInfo(filesNotUpdated);
    print("updateDateOnInfo done, time elapsed : ${stopwatch.elapsed}");

    notifyListeners();
    print("notifyListner done, time elapsed : ${stopwatch.elapsed}");

  }

  @override
  void executeSlowProcesses() async {
    if (filesNotUpdated!.isEmpty) return;
    print("executing slow process..");
    int lengthOfFiles = filesNotUpdated!.length;

    for (int i = 0; i < lengthOfFiles / 100.floor(); i++) {
      print("executing slow process.. $i / ${lengthOfFiles / 100.floor()}");
      List partOfFilesNotupdated = filesNotUpdated!.sublist(i * 100,
          lengthOfFiles < (i + 1) * 100 ? lengthOfFiles : (i + 1) * 100);

      infoFromFiles = await compute(
          updateExifOnInfo_compute, [partOfFilesNotupdated, infoFromFiles]);

      await compute(DataRepository.writeInfoAsJson_static, [infoFromFiles, directory]);
      // notifyListeners();
    }

    await dataRepository.writeInfoAsJson(infoFromFiles, true);

    notifyListeners();
  }

  // i) check whether this file is contained in Info
  // ii) check whether this file is saved previously.
  @override
  Future<List?> matchFilesAndInfo() async {
    List? filesNotUpdated = [];
    List filenamesFromInfo = infoFromFiles.keys.toList();

    if ((filenamesFromInfo
        .isNotEmpty)&&(global.kOs=='android')) {
      print("match file, sort..");
      filenamesFromInfo..sort();
    }

    Map info = {...infoFromFiles};
    int j = 0;
    for (int i = 0; i < files.length; i++) {
      String filename = files.elementAt(i);
      int sublistIndex = j + 1000 < filenamesFromInfo.length
          ? j + 1000
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

  static Future<Map<dynamic, InfoFromFile>> updateExifOnInfo_compute(
      List input) async {
    List filenames = input[0];
    Map<dynamic, InfoFromFile> infoFromFiles = input[1];

    for (int i = 0; i < filenames.length; i++) {
      var filename = filenames.elementAt(i);
      List exifData = [];
      exifData = await getExifInfoOfFile(filename);

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

  @override
  void addEvent(Event event) async {
    this
        .eventList
        .addAll({formatDatetime(event.images.values.first.datetime!): event});
    await dataRepository.writeEventList(this.eventList);
    // notifyListeners();
  }

  @override
  void setNote(DateTime datetime, String note) {
    if (noteForChart2[datetime.year.toString()] == null)
      noteForChart2[datetime.year.toString()] = {};
    noteForChart2[datetime.year.toString()]![formatDate(datetime)] = note;
    dataRepository.writeNote(noteForChart2);
  }

  @override
  void setFilenameOfFavoriteImage(DateTime datetime, String? filenameOfFavoriteImage) {
    print("setFilenameOfFavoriateImage");
    if (filenameOfFavoriteImages[datetime.year.toString()] == null)
      filenameOfFavoriteImages[datetime.year.toString()] = {};
    filenameOfFavoriteImages[datetime.year.toString()]![formatDate(datetime)] =
        filenameOfFavoriteImage;
    dataRepository.writeFilenameOfFavoriteImage(filenameOfFavoriteImages);

    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }
}
