import 'package:flutter/cupertino.dart';
import 'package:test_location_2nd/Data/infoFromFile.dart';
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
    // await readLocationData();
    // getCoordinatesFromPhotoFiles();
    print("locationDataManager initializaton done");
  }

  void getCoordinatesFromPhotoFiles() async {
    global.isLocationUpadating = true;
    List files = global.files;
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
    //find the index which date is contained in infoFromFiles.
    Set indexOfDate = List.generate(global.setOfDates.length,
        (i) => (global.setOfDates.elementAt(i).contains(date)) ? i : null).toSet();
    indexOfDate.remove(null);

    List coordinatesOfDate = List.generate(indexOfDate.length, (i) {
      var data =
          global.infoFromFiles.values.elementAt(indexOfDate.elementAt(i));
      Coordinate? coordinate = data.coordinate;
      print(coordinate.toString());
      return coordinate;
    });
    return coordinatesOfDate;
  }

  List<double?> getDistancesOfDate(String date) {
    Stopwatch stopwatch = Stopwatch()..start();

    //find the index which date is contained in infoFromFiles.
    List dates = global.setOfDates;
    // List indexOfDate = List.generate(
    //     global.dates.length, (i) => (dates.elementAt(i) == date) ? i : null);
    var endIndex = dates.lastIndexOf(date);
    var startIndex = endIndex - 1000;
    if(startIndex<0) startIndex = 0;
    List indexOfDate = List.generate(
        endIndex-startIndex, (i) {
    if(dates.elementAt(startIndex + i) == date)
      return startIndex + i;
    });

    indexOfDate.removeWhere((item) => item == null);
    List<double?> distancesOfDate = [];
    List values = global.infoFromFiles.values.toList();
    indexOfDate.forEach((element) {
      InfoFromFile data = values.elementAt(element);
      distancesOfDate.add(data.distance);
    });
    return distancesOfDate;
  }

  double getMaxDistanceOfDate(String date) {
    // Stopwatch stopwatch = new Stopwatch()..start();
    List<double?> distancesOfDate = getDistancesOfDate(date);
    // print("step1 ${stopwatch.elapsed}");
    List<double> distancesOfDate2 =
        distancesOfDate.whereType<double>().toList();
    // print("step2 ${stopwatch.elapsed}");

    // print("distancesOfDate : ${distancesOfDate}");
    // if(distancesOfDate2 == ["null"]) return 0;
    if (distancesOfDate2 == [null]) return 0;
    if (distancesOfDate2.length == 0) return 0;
    if (distancesOfDate2 == null) return 0;
    if (distancesOfDate2 == "null") return 0;
    // if(distancesOfDate2.length ==1) return distancesOfDate2[0];

    double maxDistance = distancesOfDate2.reduce(max);
    // print("step3 ${stopwatch.elapsed}");
    // stopwatch.stop();
    return maxDistance;
  }

  Future<void> writeLocationData(List filenames, List locations) async {
    final Directory? directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory?.path}/locationData.csv');
    print("writing location data to local..");

    if (!await file.exists())
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
  //
  // Future<void> readLocationData() async {
  //   final Directory? directory = await getApplicationDocumentsDirectory();
  //   try {
  //     final fileName =
  //         Glob('${directory?.path}/locationData.csv').listSync().elementAt(0);
  //     print("read ${fileName.path}");
  //     var data = await openFile(fileName.path);
  //     for (int i = 1; i < data.length; i++) {
  //       if (data[i].length > 1) {
  //         // print("${data[i][0]},${data[i][1]}, ${data[i][2]}");
  //         // print(data[i]);
  //         global.locationDataAll[data[i][0]] =
  //             Coordinate(data[i][1], data[i][2]);
  //         //updating summaryOfLocationData with reading data so as facilitate followup update.
  //         String? inferredDatetime = inferDatetimeFromFilename(data[i][0]);
  //
  //         inferredDatetime = inferredDatetime == null
  //             ? null
  //             : inferredDatetime!.substring(0, 8);
  //         global.summaryOfLocationData[inferredDatetime] = 0;
  //         coordinateOfFiles.add(Coordinate(data[i][1], data[i][2]));
  //       }
  //     }
  //     print("readLocation done");
  //   } catch (e) {
  //     print("error during readLocationData : $e");
  //   }
  // }
}
