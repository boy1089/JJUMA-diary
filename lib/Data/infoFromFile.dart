import 'package:test_location_2nd/Location/Coordinate.dart';


class InfoFromFile{
  String? file;
  DateTime? datetime;
  String? date;
  Coordinate? coordinate;
  double? distance = 0;
  bool? isUpdated = false;

  InfoFromFile(
      {this.file,
      this.datetime,
      this.date,
      this.coordinate,
      this.distance,
      this.isUpdated});

  String toString(){
    return "datetime: ${datetime}, date: ${date}, coordinate : ${coordinate?.latitude}, distance : $distance, isUpdated : $isUpdated";
  }


}