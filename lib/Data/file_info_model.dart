import 'package:lateDiary/Location/Coordinate.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:ml_dataframe/ml_dataframe.dart';

class FileInfos {

  DataFrame data;
  FileInfos({required this.data});
  // factory FileInfos.fromList(List<infoFromFiles>){
  //   return
  // }

}

class FileInfo{
  dynamic? file;
  DateTime? datetime;
  String? date;
  Coordinate? coordinate;
  double? distance = 0;
  bool? isUpdated = false;
  Map? map = {};

  FileInfo(
      {this.file,
      this.datetime,
      this.date,
      this.coordinate,
      this.distance,
      this.isUpdated,
      this.map,}){
    if(map !=null){
      parseFromMap(map);
    }
  }

  factory FileInfo.fromJson({
    required Map<String, dynamic> json
}){
    return FileInfo(
      file : json['file'],
      datetime : formatDateString(json['datetime']),
      date : json['date'],
      coordinate : Coordinate(json['latitude'], json['longitude']),
      distance : json['distance'],
      isUpdated : json['isUpdated'],
      map : null,
    );
  }

  void parseFromMap(map){
    this.file = map['file'];
    if( ![null, "null"].contains(map['datetime']) )
      this.datetime = DateTime.parse(map['datetime']);
    this.date = map['date'];
    this.coordinate = Coordinate(map['latitude'], map['longitude']);
    this.distance = map['distance'];
    this.isUpdated = map['isUpdated'];
  }

  String toString(){
    return "datetime: ${datetime}, date: ${date}, coordinate : ${coordinate?.latitude}, distance : $distance, isUpdated : $isUpdated";
  }

  Map toMap(){
    return {
      "file" : file,
      'datetime' : datetime.toString(),
      'date' : date,
      'latitude' : coordinate?.latitude,
      'longitude' : coordinate?.longitude,
      'distance' : distance,
      'isUpdated' : isUpdated,
    };
  }
}