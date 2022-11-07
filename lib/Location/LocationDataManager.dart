import 'package:test_location_2nd/Location/AddressFinder.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import "package:test_location_2nd/Location/Coordinate.dart";
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:convert';

List<String> pathsToPhoto = [
  "/storage/emulated/0/DCIM",
  "/storage/emulated/0/DCIM/Camera",
  "/storage/emulated/0/Pictures",
  "/storage/emulated/0/Pictures/*",
];

class LocationDataManager {
  List<String> files = [];
  List<Coordinate?> coordinateOfFiles = [];
  LocationDataManager() {
    // init();
  }

  Future<void> init() async {
    files = await getAllFiles();
    getCoordinatesFromFiles(files);
  }

  void getCoordinatesFromFiles(files) async {
    global.isLocationUpadating = true;
    for (int i = 0; i < files.length; i++) {
      Coordinate? coordinate =
          await AddressFinder.getCoordinateFromExif(files[i]);
      print(
          "getCoordinatesFromFiles : $i/${files.length}, ${coordinate?.latitude}, ${coordinate?.longitude} ");
      print("getCoordinatesFromFiles : $i/${files.length}, $coordinate ");
      coordinateOfFiles.add(coordinate);
      if (i % 100 == 0) {
        await writeLocationData(files, coordinateOfFiles);
        global.locations = coordinateOfFiles;
      }
    }
    await writeLocationData(files, coordinateOfFiles);
    global.locations = coordinateOfFiles;
    global.isLocationUpadating = false;
  }

  List getCoordinatesOfDate(String date) {
    Set indexOfDate = List.generate(
        global.datetimes.length,
        (i) => (global.datetimes.elementAt(i).substring(0, 8).contains(date) &
                (global.datetimes.elementAt(i).length > 8))
            ? i
            : null).toSet();
    indexOfDate.remove(null);
    print(indexOfDate);
    List coordinateOfDate = List.generate(indexOfDate.length,
        (i) => coordinateOfFiles.elementAt(indexOfDate.elementAt(i)));
    // List coordinateOfDate = List.generate(indexOfDate.length,
    //         (i)=>coordinateOfFiles.elementAt(indexOfDate.elementAt(i)));
    print(coordinateOfDate);
    return coordinateOfDate;
  }

  double getMaxDistanceOfDate(String date) {
    List coordinateOfDate = getCoordinatesOfDate(date);
    coordinateOfDate = coordinateOfDate.whereType<Coordinate>().toList();
    print("CoordinateOfDate : $coordinateOfDate");
    List<double> distanceOfDate = List.generate(coordinateOfDate.length,
        (i) => calculateDistanceToRef(coordinateOfDate[i]));
    double maxDistance = distanceOfDate.reduce(max);
    return maxDistance;
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
    newFiles = newFiles
        .where((element) => !element.path.contains('thumbnail'))
        .toList();
    return files;
  }

  Future writeLocationData(List filenames, List locations) async {
    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/locationData.csv');
    print("writing location data to local..");

    await file.writeAsString('filename,location\n', mode: FileMode.write);

    for (int i = 0; i < locations.length; i++) {
      await file.writeAsString(
          '${filenames.elementAt(i)},${locations.elementAt(i)}\n',
          mode: FileMode.append);
    }
  }

  Future readLocationData() async {
    final Directory? directory = await getExternalStorageDirectory();
    try {
      final fileName =
          Glob('${directory?.path}/locationData.csv').listSync().elementAt(0);
      print("read ${fileName.path}");
      var data = await openFile(fileName.path);
      for (int i = 0; i < data.length; i++) {
        if (data[i].length > 1) {
          global.summaryOfLocationData[data[i][0].toString()] =
              await data[i][1];
        }
      }
      print("readSummary done");
    } catch (e) {
      print("error during readSummaryOfPhotoData : $e");
    }
  }

  Future<List> openFile(filepath) async {
    File f = File(filepath);
    print("CSV to List");
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    return fields;
  }
}
