import 'package:intl/intl.dart';
import 'package:exif/exif.dart';
import 'dart:io';

List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
  List<DateTime> days = [];
  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    days.add(startDate.add(Duration(days: i)));
  }
  return days;
}

List<DateTime> getDaysInMonth(int year, int month) {
  DateTime startDate = DateTime(year, month, 1);
  DateTime endDate = DateTime(year, month+1, 0);
  List<DateTime> days = [];
  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    days.add(startDate.add(Duration(days: i)));
  }
  return days;
}


/// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}

String formatDate(DateTime date) => new DateFormat("yyyyMMdd").format(date);
String formatDatetime(DateTime datetime) => new DateFormat("yyyyMMdd HHmmss").format(datetime);

String formatDate2(DateTime date) =>"${DateFormat('EEEE').format(date)}/"
    "${DateFormat('MMM').format(date)} "
    "${DateFormat('dd').format(date)}/"
    "${DateFormat('yyyy').format(date)}";
DateTime formatDateString(String date) => DateTime.parse(date);



Future<DateTime> inferDatetime(filename) async {

  String? datetime = inferDatetimeFromFilename(filename);
  if(datetime != null)
    return DateTime.parse(datetime);

  // datetime = await getExifDateOfFile(filename);
  // print("$filename, $datetime");
  // if(datetime != "null")
  //   return DateTime.parse(datetime!);

  return FileStat.statSync(filename).modified;
}
//20221010*201020
RegExp exp1 = RegExp(r"[0-9]{8}\D[0-9]{6}");
//2022-10-10 20-20-10
RegExp exp2 =
// RegExp(r"[0-9]{4}\D[0-9]{2}\D[0-9]{2}\D[0-9]{2}\D[0-9]{2}\D[0-9]{2}");
RegExp(r"[0-9]{4}\D[0-9]{2}\D[0-9]{2}[ ][0-9]{2}\D[0-9]{2}\D[0-9]{2}");

//timestamp
RegExp exp3 = RegExp(r"[0-9]{13}");


String? inferDatetimeFromFilename(filename) {
  //order if matching is important. 3->1->2.
  Iterable<RegExpMatch> matches = exp3.allMatches(filename);
  if (matches.length != 0) {
    var date = new DateTime.fromMicrosecondsSinceEpoch(
        int.parse(matches.first.group(0)!) * 1000);
    return formatDatetime(date);
  }

  matches = exp1.allMatches(filename);
  if (matches.length != 0) {
    return matches.first
        .group(0)!
        // .toString()
        .replaceAll(RegExp(r"[^0-9]"), " ");
  }

  matches = exp2.allMatches(filename);
  if (matches.length != 0) {
    return matches.first
        .group(0)!
        // .toString()
        .replaceAll(RegExp(r"[^0-9 ]"), "");
  }

  return null;
}


Future<String?> getExifDateOfFile(String file) async {
  var bytes = await File(file).readAsBytes();
  var data = await readExifFromBytes(bytes);
  // print("date of photo : ${data['Image DateTime'].toString().replaceAll(":", "")}");
  String dateInExif = data['Image DateTime'].toString().replaceAll(":", "");
  return dateInExif;
}

