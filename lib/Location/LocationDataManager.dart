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
  Map<String, InfoFromFile> infoFromFiles = {};

  LocationDataManager(this.infoFromFiles);

  Future<void> init() async {
    print("locationDataManager initializaton done");
  }

  List<double?> getDistancesOfDate(String date) {
    //find the index which date is contained in infoFromFiles.
    List dates = global.setOfDates;

    var endIndex = dates.lastIndexOf(date);
    var startIndex = endIndex - 1000;

    if (startIndex < 0) startIndex = 0;
    List indexOfDate = List.generate(endIndex - startIndex, (i) {
      if (dates.elementAt(startIndex + i) == date) return startIndex + i;
    });

    indexOfDate.removeWhere((item) => item == null);
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
}
