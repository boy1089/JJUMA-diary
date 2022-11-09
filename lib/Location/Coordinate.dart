
import 'dart:math' as Math;
import 'package:test_location_2nd/Util/global.dart' as global;

class Coordinate {
  final double? latitude;
  final double? longitude;
  Coordinate(
      this.latitude,
      this.longitude,
      );

  String toString(){
    return "latitude : $latitude, longitude : $longitude}";
  }
}

double calculateDistance(Coordinate coordinate1, Coordinate coordinate2){
  var earthRadiusKm = 6371;

  var dLat = degreesToRadians(coordinate1.latitude! - coordinate2.latitude!);
  var dLon = degreesToRadians(coordinate1.longitude! - coordinate2.longitude!);

  var lat1 = degreesToRadians(coordinate1.latitude);
  var lat2 = degreesToRadians(coordinate2.latitude);

  var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2);
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return earthRadiusKm * c;
}

double calculateDistanceToRef(Coordinate coordinate1){
  return calculateDistance(coordinate1, global.referenceCoordinate);
}

double degreesToRadians(degrees) {
  return degrees * Math.pi / 180;
}

