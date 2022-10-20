import 'dart:convert';
import 'package:intl/intl.dart';
List<String> splitResponse(response) {
  List<String> responseToString =
      json.decode(response)['mediaItems'].toString().split(',');
  return responseToString;
}

List<List<String>> parseResponse(response) {
  List<String> responseToString =
      json.decode(response)['mediaItems'].toString().split(',');

  List<String> links = ["link"];
  List<String> filenames = ["filename"];
  List<String> datetimes = ["time"];

  for (int i = 0; i < responseToString.length; i++) {
    if (responseToString[i].contains('creationTime')) {
      String time = responseToString[i].split("{").last;
      time = time.split(' ').last;

      //9 hour is added to make timezone correct in korea.
      DateTime datetime = DateTime.parse(time).add(Duration(hours : 9));
      time = DateFormat('yyyyMMdd_HHmmss').format(datetime);
        datetimes.add(time);
      print("$time, $datetime");

    }

      if (responseToString[i].contains("https://lh3.googleusercontent.com/")) {
      links.add(responseToString[i].substring(10));
    }
    //
    // if (responseToString[i].contains("filename")) {
    //   filenames.add(responseToString[i].substring(11).split('}').first);
    //   String filename = responseToString[i].substring(11).split('}').first;
    //   filenames.add(filename);

      // try {
      //   datetimes.add(filename.substring(0, 15));
      // } catch(e){
      //   datetimes.add(filename);
      // }
      // print(filename.substring(0, 15));
    // }
  }
  List<List<String>> result = [datetimes, links];
  // result.insert(0, ["time", "link", "filename"]);
  return result;
}

