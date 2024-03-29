import 'dart:math' as Math;

import 'package:jjuma.d/Util/global.dart' as global;

class Coordinate {
  double? latitude;
  double? longitude;
  Coordinate(
    this.latitude,
    this.longitude,
  );

  String toString() {
    return "$latitude, $longitude";
    // return "latitude : $latitude, longitude : $longitude";
  }

  void setLatRef(int ref){
    latitude = ref * (latitude!.abs());
  }

  void setLongRef(int ref){
    longitude = ref * (longitude!.abs());
  }

  bool operator ==(Object other){
    if (other is! Coordinate) return false;
    return (other.latitude == latitude) && (other.longitude == longitude);
  }


}

double calculateDistance(Coordinate coordinate1, Coordinate coordinate2) {
  var earthRadiusKm = 6371;
  var dLat = degreesToRadians(coordinate1.latitude! - coordinate2.latitude!);
  var dLon = degreesToRadians(coordinate1.longitude! - coordinate2.longitude!);

  var lat1 = degreesToRadians(coordinate1.latitude);
  var lat2 = degreesToRadians(coordinate2.latitude);

  var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2);
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return earthRadiusKm * c;
}

double calculateDistanceToRef(Coordinate coordinate1) {
  return calculateDistance(coordinate1, global.referenceCoordinate);
}

double degreesToRadians(degrees) {
  return degrees * Math.pi / 180;
}
