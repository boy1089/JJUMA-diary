import 'package:glob/list_local_fs.dart';
import 'package:lateDiary/Location/Coordinate.dart';
import 'package:lateDiary/Data/infoFromFile.dart';
import 'package:glob/glob.dart';
import 'Directories.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:lateDiary/Util/Util.dart';

class DataRepository {
  DataRepository._privateConstructor();
  static final DataRepository _instance = DataRepository._privateConstructor();
  factory DataRepository() {
    return _instance;
  }

  Map<String, int> summaryOfPhotoData = {};
  Map<String, double> summaryOfLocationData = {};
  Map<String, Coordinate> summaryOfCoordinate = {};

  List setOfDates = [];
  List dates = [];
  List datetimes = [];
  List setOfDatetimes = [];
  List<String> files = [];
  List<String>? filesNotUpdated = [];
  List<String>? datesOutOfDate = [];

  Map<String, InfoFromFile> infoFromFiles = {};

  Future<void> init() async {
    print("DataRepository instance is initializing..");
    files = await getAllFiles();
    await readInfoFromJson();
    await readSummaryOfPhoto();
    await readSummaryOfLocation();
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
    files.sort((a, b) => a.compareTo(b));
    return files;
  }

  Future<Map<String, InfoFromFile>> readInfoFromJson() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/InfoOfFiles.json');

    bool isFileExist = await file.exists();
    if (!isFileExist) return {};

    var data = await file.readAsString();
    Map mapFromJson = jsonDecode(data);

    Map<String, InfoFromFile> test = {};
    List filenames = mapFromJson.keys.toList();
    for (int i = 0; i < mapFromJson.length; i++) {
      String filename = filenames.elementAt(i);
      test[filename] = InfoFromFile(map: mapFromJson[filename]);
    }

    infoFromFiles = test;

    return test;
  }

  Future<Map<String, int>> readSummaryOfPhoto() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/summaryOfPhoto.csv');

    bool isFileExist = await file.exists();
    if (!isFileExist) return {};

    var data = await openFile(file.path);
    for (int i = 1; i < data.length; i++) {
      if (data[i].length < 2) return {};
      summaryOfPhotoData[data[i][0].toString()] = data[i][1];
    }
    return summaryOfPhotoData;
  }

  Future<Map<String, double>> readSummaryOfLocation() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/summaryOfLocation.csv');

    bool isFileExist = await file.exists();
    if (!isFileExist) return {};

    var data = await openFile(file.path);
    for (int i = 1; i < data.length; i++) {
      if (data[i].length < 2) return {};
      if ([null, "null"].contains(data[i][1])) {
        summaryOfLocationData[data[i][0].toString()] = 0.0;
        continue;
      }
      summaryOfLocationData[data[i][0].toString()] = data[i][1];
    }
    return summaryOfLocationData;
  }

  Future<void> writeInfoAsJson(Map<String, InfoFromFile> infoFromFiles, bool overwrite) async {
    List<String> filenames = infoFromFiles.keys.toList();

    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/InfoOfFiles.json');

    // await file.writeAsString(jsonEncode(input));
    var test = {};
    for (int i = 0; i < filenames.length; i++) {
      String filename = filenames.elementAt(i);
      Map mapOfInfo = infoFromFiles[filename]!.toMap();
      test[filename] = mapOfInfo;
    }
    file.writeAsString(jsonEncode(test));
  }

  Future<void> writeSummaryOfPhoto2(
      Map<String, int> summaryOfPhotoData, bool overwrite, setOfDates) async {

    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/summaryOfPhoto.csv');

    if (!((await file.exists())) || overwrite) {
      print("overwritting");
      await file.writeAsString('date,numberOfPhoto\n', mode: FileMode.write);
    }

    var summaryOfPhoto = summaryOfPhotoData;
    String stringToWrite = "";
    for (int i = 0; i < setOfDates.length; i++) {
      if (i % 100 == 0) print("writingInfo.. $i/${setOfDates.length}");
      String date = setOfDates.elementAt(i);
      stringToWrite += '${date},${summaryOfPhoto[date]}\n';
    }
    await file.writeAsString(stringToWrite, mode: FileMode.append);
  }

  Future<void> writeSummaryOfLocation2(
      Map<String, double> summaryOfLocationData, bool overwrite, setOfDates) async {

    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/summaryOfLocation.csv');

    if (!((await file.exists())) || overwrite) {
      await file.writeAsString('date,distance\n', mode: FileMode.write);
    }

    String stringToWrite = "";
    for (int i = 0; i < setOfDates.length; i++) {
      if (i % 100 == 0)
        print("writingSummaryOfLocation.. $i/${setOfDates.length}");

      String date = setOfDates.elementAt(i);
      stringToWrite += '$date,${summaryOfLocationData[date]}\n';
    }
    await file.writeAsString(stringToWrite, mode: FileMode.append);
  }
}
