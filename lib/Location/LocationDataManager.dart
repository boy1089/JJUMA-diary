import 'package:flutter/cupertino.dart';
import 'package:lateDiary/Data/infoFromFile.dart';
import 'package:lateDiary/Location/AddressFinder.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/global.dart' as global;
import "package:lateDiary/Location/Coordinate.dart";
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/Data/Directories.dart';

import 'package:lateDiary/Data/DataManager.dart';

class LocationDataManager {
  List<String> files = [];
  List<Coordinate?> coordinateOfFiles = [];
  Map<String, InfoFromFile> infoFromFiles = {};

  LocationDataManager(this.infoFromFiles);

  DataManager dataManager = DataManager();

  Future<void> init() async {
    print("locationDataManager initializaton done");
  }

  void getCoordinatesFromPhotoFiles() async {
    global.isLocationUpadating = true;
    List files = dataManager.files;
    List<String> filesForSave = [];
    List<Coordinate?> coordinateForSave = [];

    for (int i = 0; i < files.length; i++) {
      if (global.locationDataAll.containsKey(files[i])) {
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
    Set indexOfDate = List.generate(
            dataManager.setOfDates.length,
            (i) =>
                (dataManager.setOfDates.elementAt(i).contains(date)) ? i : null)
        .toSet();
    indexOfDate.remove(null);

    List coordinatesOfDate = List.generate(indexOfDate.length, (i) {
      var data =
          dataManager.infoFromFiles.values.elementAt(indexOfDate.elementAt(i));
      Coordinate? coordinate = data.coordinate;
      return coordinate;
    });
    return coordinatesOfDate;
  }

  List<double?> getDistancesOfDate(String date) {
    //find the index which date is contained in infoFromFiles.
    List dates = global.setOfDates;

    var endIndex = dates.lastIndexOf(date);
    var startIndex = endIndex - 1000;

    print("$endIndex, $startIndex");
    if (startIndex < 0) startIndex = 0;
    List indexOfDate = List.generate(endIndex - startIndex, (i) {
      if (dates.elementAt(startIndex + i) == date) return startIndex + i;
    });

    indexOfDate.removeWhere((item) => item == null);
    print("indexOfDate : $indexOfDate");
    List<double?> distancesOfDate = [];
    List values = infoFromFiles.values.toList();
    indexOfDate.forEach((element) {
      InfoFromFile data = values.elementAt(element);
      distancesOfDate.add(data.distance);
    });
    return distancesOfDate;
  }

  double getMaxDistanceOfDate(String date) {
    List<double?> distancesOfDate = getDistancesOfDate(date);
    List<double> distancesOfDate2 =
        distancesOfDate.whereType<double>().toList();

    if (distancesOfDate2 == [null]) return 0;
    if (distancesOfDate2.length == 0) return 0;
    if (distancesOfDate2 == null) return 0;
    if (distancesOfDate2 == "null") return 0;

    double maxDistance = distancesOfDate2.reduce(max);
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
}
