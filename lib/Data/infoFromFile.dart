import 'package:test_location_2nd/Location/Coordinate.dart';


class InfoFromFile{
  String? file;
  DateTime? datetime;
  String? date;
  Coordinate? coordinate;
  double? distance;

  String toString(){
    return "datetime: ${datetime}, date: ${date}, coordinate : ${coordinate?.latitude}, distance : $distance";
  }

}