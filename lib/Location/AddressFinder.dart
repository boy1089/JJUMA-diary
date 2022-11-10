import 'dart:io';
import 'package:exif/exif.dart';
import 'package:geocoding/geocoding.dart';
import 'Coordinate.dart';

class AddressFinder {
  static Future getAddressFromExif(filename) async{
    Coordinate coordinate = await getCoordinateFromExif(filename);
    Placemark? placemark = await getAddressFromCoordinate(coordinate.latitude, coordinate.longitude);
    print(placemark);
    return placemark;
  }

  static Future getCoordinateFromExif(filename) async {
    var bytes = await File(filename).readAsBytes();
    var data = await readExifFromBytes(bytes);
    // print("date of photo : ${data['Image DateTime'].toString().replaceAll(":", "")}");

    Coordinate coordinate = Coordinate(
        convertTagToValue(data['GPS GPSLatitude']),
        convertTagToValue(data['GPS GPSLongitude']));

    if(coordinate.latitude==null)
      return null;

    return coordinate;
  }


  static Future<Placemark?> getAddressFromCoordinate(latitude, longitude) async {
    //https://www.geeksforgeeks.org/how-to-get-address-from-coordinates-in-flutter/
    try {
      var address = await placemarkFromCoordinates(latitude, longitude);
      return address[0];
    } catch(e) {
      print("error in getAddressFromCoordinate, $e");
      return null;
    }
  }

  static double? convertTagToValue(tag) {
    if(tag==null) return null;

    List values = tag.printable
        .replaceAll("[", "")
        .replaceAll("]", "")
        .replaceAll(" ", "")
        .split(',');

    double value = double.parse(values[0]) +
        double.parse(values[1]) / 60 +
        double.parse(values[2].split('/')[0]) / 1e6/3600;
    return value;
  }
}
