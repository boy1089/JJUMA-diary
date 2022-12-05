import 'package:lateDiary/Location/Coordinate.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:ml_dataframe/ml_dataframe.dart';

enum columns { filename, datetime, date, coordinate, distance, isUpdated }

class FilesInfoModel {
  DataFrame data;
  FilesInfoModel({required this.data});
  List<String?> dates = [];
  Set<String?> setOfDates = {};
  List<DateTime?> datetimes = [];
  List<double?> distances = [];
  List<Coordinate?> coordinates = [];

  // factor FilesInfoModel.fromJson({required Map<String, dynamic>json}){
  //
  // }


  factory FilesInfoModel.fromMapOfInfo({required Map map}) {
    DataFrame data = DataFrame([
      ['path'],
      ["filename"],
      ["datetime"],
      ["date"],
      ["coordinate"],
      ["distance"],
      ["isUpdated"]
    ]);

    var entries = map.entries;
    for (var i = 0; i < entries.length; i++) {
      var info = entries.elementAt(i);
      data = data.addSeries(Series(info.key, info.value.toList()));
    }
    return FilesInfoModel(data: data);
  }

  void updateData(data) {
    this.data = data;
  }

  void updateAll(){
    updateDates();
    updateCoordinates();
    updateDistances();
  }

  void updateDates() {
    this.datetimes = List<DateTime?>.from(
        data.rows.elementAt(columns.datetime.index).toList().sublist(1));
    this.dates = List<String?>.from(
        data.rows.elementAt(columns.date.index).toList().sublist(1));
    this.setOfDates = this.dates.toSet();
  }

  void updateCoordinates() {
    this.coordinates = List<Coordinate?>.from(
        data.rows.elementAt(columns.coordinate.index).toList().sublist(1));
  }
  void updateDistances() {
    this.distances = List<double?>.from(
        data.rows.elementAt(columns.distance.index).toList().sublist(1));
  }


}

class FileInfoModel {
  dynamic? file;
  DateTime? datetime;
  String? date;
  Coordinate? coordinate;
  double? distance = 0;
  bool? isUpdated = false;
  Map? map = {};

  FileInfoModel({
    this.file,
    this.datetime,
    this.date,
    this.coordinate,
    this.distance,
    this.isUpdated,
    this.map,
  }) {
    if (map != null) {
      parseFromMap(map);
    }
  }

  factory FileInfoModel.fromJson({required Map<String, dynamic> json}) {
    return FileInfoModel(
      file: json['file'],
      datetime: formatDateString(json['datetime']),
      date: json['date'],
      coordinate: Coordinate(json['latitude'], json['longitude']),
      distance: json['distance'],
      isUpdated: json['isUpdated'],
      map: null,
    );
  }

  void parseFromMap(map) {
    this.file = map['file'];
    if (![null, "null"].contains(map['datetime']))
      this.datetime = DateTime.parse(map['datetime']);
    this.date = map['date'];
    this.coordinate = Coordinate(map['latitude'], map['longitude']);
    this.distance = map['distance'];
    this.isUpdated = map['isUpdated'];
  }

  String toString() {
    return "datetime: ${datetime}, date: ${date}, coordinate : ${coordinate?.latitude}, distance : $distance, isUpdated : $isUpdated";
  }

  List toList() {
    return [file, datetime, date, coordinate, distance, isUpdated];
  }

  Map toMap() {
    return {
      "file": file,
      'datetime': datetime.toString(),
      'date': date,
      'latitude': coordinate?.latitude,
      'longitude': coordinate?.longitude,
      'distance': distance,
      'isUpdated': isUpdated,
    };
  }
}
