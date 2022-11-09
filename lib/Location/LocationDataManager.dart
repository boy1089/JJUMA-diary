import 'package:flutter/cupertino.dart';
import 'package:test_location_2nd/Location/AddressFinder.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import "package:test_location_2nd/Location/Coordinate.dart";
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:test_location_2nd/Util/Util.dart';

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
    await readLocationData();
    getCoordinatesFromPhotoFiles();
    print("locationDataManager initializaton done");
  }

  void getCoordinatesFromPhotoFiles() async {
    global.isLocationUpadating = true;
    List<String> files = global.files;
    List<String> filesForSave = [];
    List<Coordinate?> coordinateForSave = [];

    for (int i = 0; i < files.length; i++) {
      if (global.locationDataAll.containsKey(files[i])) {
        // print("${files[i]} is already in the saved data");
        continue;
      }

      Coordinate? coordinate =
          await AddressFinder.getCoordinateFromExif(files[i]);

      global.locationDataAll[files[i]] = coordinate;
      coordinateOfFiles.add(coordinate);
      filesForSave.add(files.elementAt(i));
      coordinateForSave.add(coordinate);
      if (i % 100 == 0) {
        print("getCoordinatesFromPhotoFiles : $i/ ${files.length}");
        await writeLocationData(filesForSave, coordinateForSave);
        global.locations = coordinateOfFiles;
        filesForSave = [];
        coordinateForSave = [];
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
    List coordinateOfDate = List.generate(indexOfDate.length,
        (i) => coordinateOfFiles.elementAt(indexOfDate.elementAt(i)));
    // List coordinateOfDate = List.generate(indexOfDate.length,
    //         (i)=>coordinateOfFiles.elementAt(indexOfDate.elementAt(i)));
    return coordinateOfDate;
  }

  double getMaxDistanceOfDate(String date) {
    List coordinateOfDate = getCoordinatesOfDate(date);
    coordinateOfDate = coordinateOfDate.whereType<Coordinate>().toList();
    List<double> distanceOfDate = List.generate(coordinateOfDate.length, (i) {
      return calculateDistanceToRef(coordinateOfDate[i]);
    });
    double maxDistance = distanceOfDate.reduce(max);
    return maxDistance;
  }

  Future<void> writeLocationData(List filenames, List locations) async {
    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/locationData.csv');
    print("writing location data to local..");

    if(!await file.exists())
    await file.writeAsString('filename,latitude,longitude\n',
        mode: FileMode.write);

    for (int i = 0; i < locations.length; i++) {
      if (locations.elementAt(i) == null) {
        await file.writeAsString(
            '${filenames.elementAt(i)},'
            '${global.referenceCoordinate.latitude},'
            '${global.referenceCoordinate.longitude}\n',
            mode: FileMode.append);
      } else {
        await file.writeAsString(
            '${filenames.elementAt(i)},'
            '${locations.elementAt(i).latitude},'
            '${locations.elementAt(i).longitude}\n',
            mode: FileMode.append);
      }
    }
  }

  Future<void> readLocationData() async {
    final Directory? directory = await getExternalStorageDirectory();
    try {
      final fileName =
          Glob('${directory?.path}/locationData.csv').listSync().elementAt(0);
      print("read ${fileName.path}");
      var data = await openFile(fileName.path);
      for (int i = 1; i < data.length; i++) {
        if (data[i].length > 1) {
          // print("${data[i][0]},${data[i][1]}, ${data[i][2]}");
          // print(data[i]);
          global.locationDataAll[data[i][0]] =
              Coordinate(data[i][1], data[i][2]);
          //updating summaryOfLocationData with reading data so as facilitate followup update.
          String? inferredDatetime = inferDatetimeFromFilename(data[i][0]);

          inferredDatetime = inferredDatetime == null
              ? null
              : inferredDatetime!.substring(0, 8);
          global.summaryOfLocationData[inferredDatetime] = 0;
          coordinateOfFiles.add(Coordinate(data[i][1], data[i][2]));
        }
      }
      print("readLocation done");
    } catch (e) {
      print("error during readLocationData : $e");
    }
  }
}
