import 'package:test_location_2nd/Location/AddressFinder.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import "package:test_location_2nd/Location/Coordinate.dart";
import 'dart:math';

List<String> pathsToPhoto = [
  "/storage/emulated/0/DCIM",
  "/storage/emulated/0/DCIM/Camera",
  "/storage/emulated/0/Pictures",
  "/storage/emulated/0/Pictures/*",
];
class LocationDataManager {

  List<String> files = [];
  List<Coordinate?> coordinateOfFiles = [];
  LocationDataManager(){
    // init();
  }

  Future<void> init() async {
    files = await getAllFiles();
    coordinateOfFiles = await getCoordinatesFromFiles(files);

  }

  Future<List<Coordinate?>> getCoordinatesFromFiles(files) async {
    List<Coordinate?> coordinateOfFiles = [];
    for(int i= 0; i<files.length; i++){
      Coordinate? coordinate = await AddressFinder.getCoordinateFromExif(files[i]);
      print("getCoordinatesFromFiles : $i/${files.length}, ${coordinate
          ?.latitude}, ${coordinate?.longitude} ");
      print("getCoordinatesFromFiles : $i/${files.length}, $coordinate ");
      coordinateOfFiles.add(coordinate);
    }
    return coordinateOfFiles;
  }

  List getCoordinatesOfDate(String date) {
    Set indexOfDate = List.generate(
        global.datetimes.length,
            (i) => (global.datetimes.elementAt(i).substring(0, 8).contains(date) & (global.datetimes.elementAt(i).length>8))
            ? i
            : null).toSet();
    indexOfDate.remove(null);
    print(indexOfDate);
    List coordinateOfDate = List.generate(indexOfDate.length,
        (i)=>coordinateOfFiles.elementAt(indexOfDate.elementAt(i)));
    // List coordinateOfDate = List.generate(indexOfDate.length,
    //         (i)=>coordinateOfFiles.elementAt(indexOfDate.elementAt(i)));
    print(coordinateOfDate);
    return coordinateOfDate;
  }

  double getMaxDistanceOfDate(String date){
    List coordinateOfDate = getCoordinatesOfDate(date);
    coordinateOfDate = coordinateOfDate.whereType<Coordinate>().toList();
    print("CoordinateOfDate : $coordinateOfDate");
    List<double> distanceOfDate = List.generate(coordinateOfDate.length, (i)=>calculateDistanceToRef(coordinateOfDate[i]));
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
    newFiles = newFiles.where((element)=>!element.path.contains('thumbnail')).toList();
    return files;
  }


}