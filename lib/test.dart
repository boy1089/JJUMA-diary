//
// import 'package:lateDiary/Location/coordinate.dart';
//
// class InfoFromFile{
//   dynamic? file;
//   DateTime? datetime;
//   String? date;
//   Coordinate? coordinate;
//   double? distance = 0;
//   bool? isUpdated = false;
//   Map? map = {};
//
//   InfoFromFile(
//       {this.file,
//         this.datetime,
//         this.date,
//         this.coordinate,
//         this.distance,
//         this.isUpdated,
//         this.map,}){
//     if(map !=null){
//       parseFromMap(map);
//     }
//   }
//   factory InfoFromFile.fromJson({
//     required Map<String, dynamic> json,
// }) {
//     return InfoFromFile(
//       file : json['file'],
//       datetime : json['']
//     )
//   }
//
//   void parseFromMap(map){
//     this.file = map['file'];
//     if( ![null, "null"].contains(map['datetime']) )
//       this.datetime = DateTime.parse(map['datetime']);
//     this.date = map['date'];
//     this.coordinate = Coordinate(map['latitude'], map['longitude']);
//     this.distance = map['distance'];
//     this.isUpdated = map['isUpdated'];
//   }
//
//   String toString(){
//     return "datetime: ${datetime}, date: ${date}, coordinate : ${coordinate?.latitude}, distance : $distance, isUpdated : $isUpdated";
//   }
//
//   Map toMap(){
//     return {
//       "file" : file,
//       'datetime' : datetime.toString(),
//       'date' : date,
//       'latitude' : coordinate?.latitude,
//       'longitude' : coordinate?.longitude,
//       'distance' : distance,
//       'isUpdated' : isUpdated,
//     };
//   }
// }