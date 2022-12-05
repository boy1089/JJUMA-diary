import 'package:lateDiary/Data/file_info_model.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'dart:math';

class LocationDataManager {
  Map<dynamic, FileInfoModel> infoFromFiles = {};

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
    for (var element in indexOfDate) {
      FileInfoModel data = values.elementAt(element);
      distancesOfDate.add(data.distance);
    }
    return distancesOfDate;
  }

  double getMaxDistanceOfDate(String date) {
    List<double?> distancesOfDate = getDistancesOfDate(date);
    List<double> distancesOfDate2 =
        distancesOfDate.whereType<double>().toList();

    if (distancesOfDate2 == [null]) return 0;
    if (distancesOfDate2.isEmpty) return 0;
    if (distancesOfDate2 == "null") return 0;

    double maxDistance = distancesOfDate2.reduce(max);
    return maxDistance;
  }
}
