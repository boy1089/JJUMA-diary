import 'package:glob/list_local_fs.dart';
import 'package:jjuma.d/Location/coordinate.dart';
import 'package:jjuma.d/Data/info_from_file.dart';
import 'package:glob/glob.dart';
import 'package:photo_manager/photo_manager.dart';
import '../pages/event.dart';
import 'directories.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:jjuma.d/Util/global.dart' as global;

class DataRepository {
  DataRepository._privateConstructor();
  static final DataRepository _instance = DataRepository._privateConstructor();
  factory DataRepository() {
    return _instance;
  }

  Map<String, int> summaryOfPhotoData = {};
  Map<String, double> summaryOfLocationData = {};
  Map<String, Coordinate> summaryOfCoordinate = {};

  List files = [];

  Map<dynamic, InfoFromFile> infoFromFiles = {};
  Map<String, Map<String, String>> notes = {};
  Map<String, Map<String, String?>> filenameOfFavoriteImages = {};

  Future<void> init() async {
    print("DataRepository instance is initializing..");
    files = await getAllFiles();
    await readInfoFromJson();
    await readSummaryOfPhoto();
    await readSummaryOfLocation();
    await readNote();
  }

  Future<List> getAllFiles() async {
    List files = [];
    List newFiles = [];

    if (global.kOs == "ios") {
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList();
      for (var path in paths) {
        // if (path.name != "Recents") continue;
        var assets = await path.getAssetListRange(start: 0, end: 20000);
        files.addAll([for (var asset in assets) asset]);
      }
      this.files = files;
      return files;
    }

    for (int i = 0; i < Directories.selectedDirectories.length; i++) {
      String path = Directories.selectedDirectories.elementAt(i);

      newFiles = Glob("$path/{**.jpg, **.png}").listSync();
      files.addAll(List.generate(
          newFiles.length, (index) => newFiles.elementAt(index).path));
    }

    files = files.where((element) => !element.contains('thumbnail')).toList();
    files = files..sort();
    return files;
  }

  Future<Map<dynamic, InfoFromFile>> readInfoFromJson() async {

    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/InfoOfFiles.json');

    bool isFileExist = await file.exists();
    if (!isFileExist) return {};

    var data = await file.readAsString();
    if (data == "") return {};

    Map<String, dynamic> mapFromJson = jsonDecode(data);

    Map<dynamic, InfoFromFile> test = {};
    List filenames = mapFromJson.keys.toList();

    var keys = files;
    var ids = [for (var a in keys) a.id];

    for (int i = 0; i < mapFromJson.length; i++) {
      if (global.kOs == "ios") {
        String id = filenames.elementAt(i);
        int index = ids.indexOf(id);
        // if (i % 100 == 0) {
        //   print("$i / ${mapFromJson.length}, ${index}");
        // }
        if (index != -1)
          test[keys[index]] = InfoFromFile.fromJson(json: mapFromJson[id]);
        continue;
      }

      String filename = filenames.elementAt(i);
      test[filename] = InfoFromFile.fromJson(json: mapFromJson[filename]);
    }

    infoFromFiles = test;

    return infoFromFiles;
  }

  Future<Map<String, int>> readSummaryOfPhoto() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/summaryOfPhoto.json');

    bool isFileExist = await file.exists();
    if (!isFileExist) return {};

    var data = await file.readAsString();
    if (data == "{}") return {};
    Map<String, dynamic> mapFromJson = jsonDecode(data);
    summaryOfPhotoData = Map<String, int>.from(mapFromJson);
    return summaryOfPhotoData;
  }

  Future<Map<String, double>> readSummaryOfLocation() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/summaryOfLocation.json');

    bool isFileExist = await file.exists();
    if (!isFileExist) return {};
    var data = await file.readAsString();
    if (data == "{}") return {};
    Map<String, dynamic> mapFromJson = jsonDecode(data);
    summaryOfLocationData = Map<String, double>.from(mapFromJson);
    return summaryOfLocationData;
  }


  Future<void> writeInfoAsJson(
      Map<dynamic, InfoFromFile> infoFromFiles, bool overwrite) async {
    List filenames = infoFromFiles.keys.toList();

    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/InfoOfFiles.json');

    var test = {};
    for (int i = 0; i < filenames.length; i++) {
      dynamic filename = filenames.elementAt(i);
      Map mapOfInfo = infoFromFiles[filename]!.toMap();

      if (global.kOs == "ios") {
        test[filename.id] = mapOfInfo;
        continue;
      }
      test[filename] = mapOfInfo;
      // if (i % 1000 == 0) print("$i / ${filenames.length}");
    }
    await file.writeAsString(jsonEncode(test));
  }

  // Map<dynamic, InfoFromFile> infoFromFiles, bool overwrite
  static Future<void> writeInfoAsJson_static(List input) async {
    Map<dynamic, InfoFromFile> infoFromFiles = input[0];
    List filenames = infoFromFiles.keys.toList();

    Directory directory = input[1];

    final File file = File('${directory.path}/InfoOfFiles.json');

    var test = {};
    for (int i = 0; i < filenames.length; i++) {
      dynamic filename = filenames.elementAt(i);
      Map mapOfInfo = infoFromFiles[filename]!.toMap();
      test[filename] = mapOfInfo;
    }
    await file.writeAsString(jsonEncode(test));
  }

  Future<void> writeSummaryOfPhoto(
      Map<dynamic, int> summaryOfPhotoData, bool overwrite, setOfDates) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/summaryOfPhoto.json');

    String stringToWrite = jsonEncode(summaryOfPhotoData);

    await file.writeAsString(stringToWrite, mode: FileMode.write);
  }

  Future<void> writeSummaryOfLocation(Map<String, double> summaryOfLocationData,
      bool overwrite, setOfDates) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/summaryOfLocation.json');

    String stringToWrite = jsonEncode(summaryOfLocationData);
    await file.writeAsString(stringToWrite, mode: FileMode.write);
  }

  Future<void> writeEventList(Map<String, Event> eventList) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/eventList.json');

    List keys = eventList.keys.toList();
    var test = {};
    for (int i = 0; i < keys.length; i++) {
      dynamic key = keys.elementAt(i);
      Map mapOfInfo = eventList[key]!.toMap();
      test[key] = mapOfInfo;
    }
    await file.writeAsString(jsonEncode(test), mode: FileMode.write);
  }

  Future<void> writeNote(Map<String, Map<String, String>> notes) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/notes.json');
    await file.writeAsString(jsonEncode(notes), mode: FileMode.write);
  }

  Future<Map<String, Map<String, String>>> readNote() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/notes.json');

    bool isFileExist = await file.exists();
    if (!isFileExist) return {};

    var data = await file.readAsString();

    var jsonData = json.decode(data);
    Map<String, Map<String, String>> test = {};

    for (var key in jsonData.keys) {
      test[key] = Map<String, String>.fromIterable(jsonData[key].entries,
          key: (item) => item.key, value: (item) => item.value);
    }
    this.notes = test;
    return test;
  }

  Future<void> writeFilenameOfFavoriteImage(
      Map<String, Map<String, String?>> indexOfFavoriteImages) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/filenameOfFavoriteImage.json');
    await file.writeAsString(jsonEncode(indexOfFavoriteImages),
        mode: FileMode.write);
  }

  Future<Map<String, Map<String, String?>>> readFilenameOfFavoriteImages() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/filenameOfFavoriteImage.json');

    bool isFileExist = await file.exists();
    if (!isFileExist) return {};

    var data = await file.readAsString();

    var jsonData = json.decode(data);
    Map<String, Map<String, String?>> test = {};

    for (var key in jsonData.keys) {
      test[key] = Map<String, String?>.fromIterable(jsonData[key].entries,
          key: (item) => item.key, value: (item) => item.value);
    }
    this.filenameOfFavoriteImages = test;
    return test;
  }
}
