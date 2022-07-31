import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import 'package:intl/intl.dart';
import 'package:test_location_2nd/Util.dart';



class ImageReader {
  var filesAll;
  var files_date;
  var filesSortByHour = [];
  var filesSortBy2Hour = [];
  var images_date;
  var _date;

  var datesRange = [];
  var numberOfFiles = [];
  List<String> dates = [];

  ImageReader(date) {
    _date = date;
    updateState(date);
  }

  void updateState(date) async {
    _date = date;
    filesAll = await getFiles();

    debugPrint("imagReader, updateState");
    sortFilesByDate(date);
    print('bbb');
    if (date == "all") {
      debugPrint("imageReader, init with all");
      datesRange = getDateRange(filesAll);
      dates = getDateFromFiles(filesAll);
      numberOfFiles = getNumberOfFiles(dates);
    } else {
      debugPrint("ImageReader : updateState : filesDate: $files_date");
      sortFilesByHour();
      sortFilesBy2Hour();
    }

    filesAll = List.from(filesAll.reversed);
    dates = List.from(dates.reversed);
    numberOfFiles = List.from(numberOfFiles.reversed);
    datesRange = List.from(datesRange.reversed);

  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    var path = directory.path;
    return path;
  }

  Future<List<File>> getFiles() async {
    var kRoot = await _localPath;
    var fm = FileManager(root: Directory(kRoot + '/Images')); //
    filesAll = fm.filesTree(extensions: ["jpg"]);
    return await filesAll;
  }

  List<File> sortFilesByDate(date) {
    files_date =
        filesAll.where((item) => item.toString().contains('$date')).toList();

    return files_date;
  }

  void sortFilesByHour() {
    var files_temp = [];
    filesSortByHour = [];
    debugPrint("imageReader, sortbyHour, filesdate : $files_date");

    for (int i = 0; i < kTimeStamps.length; i++) {
      files_temp = files_date
          .where(
              (item) => item.toString().contains('${_date}_${kTimeStamps[i]}'))
          .toList();
      filesSortByHour.add(files_temp);
    }
  }

  void sortFilesBy2Hour() {
    var files_temp = [];
    var files_temp2 = [];
    // var timestamp = kTimeStamps_filtered;
    var timestamp = kTimeStamps;

    filesSortBy2Hour = [];

    debugPrint("imageReader, sortby2Hour, filesdate : $files_date");
    for (int i = 0; i < timestamp.length; i++) {
      if (i % 2 == 0) {
        files_temp = files_date
            .where(
                (item) => item.toString().contains('${_date}_${timestamp[i]}'))
            .toList();
        files_temp2 = files_date
            .where((item) =>
                item.toString().contains('${_date}_${timestamp[i + 1]}'))
            .toList();
        filesSortBy2Hour.add(files_temp + files_temp2);
      }

      // debugPrint("imageReader, sortby2Hour, filesdate : $filesSortBy2Hour");
    }
  }

  List<String> getDateRange(filesAll) {
    List<String> dateFromFilename = [];

    debugPrint("imageReader, filesAll $filesAll");
    for (int i = 0; i < filesAll.length; i++) {
      dateFromFilename
          .add(filesAll[i].toString().split('/').last.substring(0, 8));
    }
    var dates_temp = dateFromFilename.toSet().toList();

    var date_start = DateTime.parse(dates_temp.first);
    var date_end = DateTime.parse(dates_temp.last);
    var days;
    final daysToGenerate = date_end.difference(date_start).inDays;
    days = List.generate(
        daysToGenerate + 1,
        (i) =>
            DateTime(date_start.year, date_start.month, date_start.day + (i)));
    days = List.generate(
        days.length, (i) => DateFormat('yyyyMMdd').format(days[i]));

    return days;
  }

  List<String> getNumberOfFiles(List<String> dates) {
    List<String> numberOfFiles = [];
    for (int i = 0; i < dates.length; i++) {
      numberOfFiles.add(sortFilesByDate(dates[i]).length.toString());
    }
    return numberOfFiles;
  }

  List<String> getDateFromFiles(filesAll) {
    List<String> dateFromFilename = [];

    for (int i = 0; i < filesAll.length; i++) {
      dateFromFilename
          .add(filesAll[i].toString().split('/').last.substring(0, 8));
    }
    return dateFromFilename.toSet().toList();
  }
}
