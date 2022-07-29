import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import 'package:intl/intl.dart';
import 'package:test_location_2nd/Util.dart';
// TODO : sort image. by year, by month, by date
// TODO : get all files, --> filesAll
//TODO : sort filesSortByYear, filesSortByMonth, filesSortByDate

//TODO : class - get files, def so


class ImageReader {

  var filesAll;
  var files_date;
  var filesSortByHour = [];
  var filesSortBy2Hour = [];
  var images_date;
  var _date;

  ImageReader(date){
    _date = date;
    updateState(date);
    }

  void updateState(date) async{
    filesAll = await getFiles();

    sortFilesByDate(date);
    debugPrint("ImageReader : updateState : filesDate: $files_date");
    sortFilesByHour();
    sortFilesBy2Hour();
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

  void sortFilesByDate(date) {
    files_date = filesAll.where((item) => item.toString().contains('$date')).toList();
  }

  void sortFilesByHour(){
    var files_temp = [];
    filesSortByHour = [];
    for(int i = 0; i < kTimeStamps.length; i++){
      files_temp = files_date.where((item) => item.toString().contains('${_date}_${kTimeStamps[i]}')).toList();
      filesSortByHour.add(files_temp);
    }
  }
  void sortFilesBy2Hour(){
    var files_temp = [];
    var files_temp2  = [];
    filesSortBy2Hour = [];
    for(int i = 0; i < kTimeStamps.length; i++){
      if( i%2==0){
        files_temp = files_date.where((item) => item.toString().contains('${_date}_${kTimeStamps[i]}')).toList();
        files_temp2 = files_date.where((item) => item.toString().contains('${_date}_${kTimeStamps[i+1]}')).toList();
        print("${files_temp + files_temp2}");
        filesSortBy2Hour.add(files_temp + files_temp2);
      }

    }
  }

}