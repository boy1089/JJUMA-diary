import 'package:exif/exif.dart';
import 'package:glob/list_local_fs.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:glob/glob.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/Data/infoFromFile.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/Data/Directories.dart';

class PhotoDataManager {
  List datetimes = [];
  List dates = [];
  List<String> files = [];

  PhotoDataManager() {
    // init();
  }

  Future getPhotoOfDate(String date) async {
    Stopwatch stopwatch = Stopwatch()..start();

    List<int?> indexOfDate = List<int?>.generate(global.dates.length, (i) {
      if (global.dates.elementAt(i) == date) return i;
      return null;
    });

    print("time elapsed1 : ${stopwatch.elapsed}");
    indexOfDate = indexOfDate.whereType<int>().toList();
    print("time elapsed2 : ${stopwatch.elapsed}");
    List files = global.infoFromFiles.keys.toList();
    List filesOfDate = List.generate(
        indexOfDate.length, (i) => files.elementAt(indexOfDate.elementAt(i)!));

    print("time elapsed3 : ${stopwatch.elapsed}");
    List dateOfDate = List.generate(
        indexOfDate.length,
        (i) => formatDatetime(
            global.datetimes.elementAt(indexOfDate.elementAt(i)!)));
    print("time elapsed4 : ${stopwatch.elapsed}");
    // for (int i = 0; i < indexOfDate.length; i++) {
    //   print("${dateOfDate[i]}, ${filesOfDate[i]}");
    // }

    List list = transpose([dateOfDate, filesOfDate]);
    list.sort((a, b) => int.parse(a[0].substring(9, 13))
        .compareTo(int.parse(b[0].substring(9, 13))));
    // list.sort((a, b) =>int.parse(a[0].substring(9, 13)).compareTo(int.parse(b[0].substring(9, 13))));

    print("getPhotoOfDate, $list");

    return transpose(list);
  }

}
