

import 'package:path_provider/path_provider.dart';

import 'package:ml_dataframe/ml_dataframe.dart';
import 'dart:io';
import 'package:test_location_2nd/Util.dart';
import 'package:test_location_2nd/Event.dart';
import 'package:test_location_2nd/EventList.dart';

import 'package:flutter_file_manager/flutter_file_manager.dart';

class DataAnalyzer{

  var directory;
  EventList eventList = EventList();
  List<File> files2 = [];
  var data;
  List<DataFrame> dataAll = [];
  var summary;

  DataAnalyzer(){
    eventList.load();
    // var a = readFiles();
    //
    // printData(a);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    var path = directory.path;
    return path;
  }

  Future<List<File>> getFiles() async {
    var a = await _localPath;
    var kRoot = a;
    var fm = FileManager(root: Directory('${kRoot}/sensorData')); //
    var b;
    b = fm.filesTree(extensions: [".csv"]);


    return b;
  }

  Future<List<DataFrame>> readFiles() async {
    var files = await getFiles();
    dataAll = [];
    print("files:  ${files}");
    print("files: ${files.length}");
    files2 = files;
    for(int i=0; i< files.length; i++){
      data = await readFile(files.elementAt(i).path);
      print('reaFiles, $i th data');
      dataAll.add(data);
    }
    return dataAll;
  }

  Future<DataFrame> readFile(path) async {
    var a = await _localPath;
    data = await fromCsv(path);
    return data;
  }

  Future<EventList> analyzeData(a) async {
    var b = await _localPath;
    dataAll = await a;
    eventList.clear();
    print('aaa ${dataAll.length}');
    for(int i = 0; i < files2.length; i++){
      print('processing ${i}/${files2.length} th data...${files2[i]}');
      data = await dataAll[i];
      analyzeIsHome();
    }
    eventList.sortEvent();

    return eventList;

  }
  void subsampleData(int subsampleFactor){
    data = data.setRange();
  }

  void analyzeIsHome(){
    List<int> isHomeList = [];
    double longitude_diff = 1;
    double latitude_diff = 1;
    int isHome = 0;

    int length = data.shape[0];
    print(data['time'].data.elementAt(0));
    print(data.header);
    for( int i =0; i< data['longitude'].data.length; i++ ){
      longitude_diff = (data['longitude'].data[i] - longitude_home).abs();
      latitude_diff = (data['latitude'].data[i] - latitude_home).abs();

      if ((longitude_diff + latitude_diff)< distance_threshold_home){
        isHome = 1;
      } else{
        isHome = 0;
      }
      isHomeList.add(isHome);
    }

    for( int i = 0; i < length-1; i++){
      var inoutData = isHomeList[i+1] - isHomeList[i];
      if(inoutData == 1) eventList.add(Event(DateTime.parse(data['time'].data[i]), 'back home' ));
      if(inoutData == -1) eventList.add(Event(DateTime.parse(data['time'].data[i]), 'going out'));
    }
    final series = Series('isHome', isHomeList);
    data = data.addSeries(series);

  }

  void updateSummary() {

  }

  void writeSummary() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(
        '${directory.path}/summary.csv');
  }

  void readSummary() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(
        '${directory.path}/summary.csv');
    print(directory.path);
    summary = await fromCsv('${directory.path}/summary.csv');
  }

  void printData(a) async {
    var b = await _localPath;
    print(dataAll);
    var c = await analyzeData(a);

  }
}