import 'package:flutter/material.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:test_location_2nd/Event.dart';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';
class EventList{
  List<Event> eventList = [];
  EventList(){}

  void getEventList(List<Event> list){
    eventList = list;
  }

  void add(Event event){
    eventList.add(event);
  }

  int length(){
    if (eventList != null){
      print(eventList.length);
      return eventList.length;
    } else {
      return 0;
    }
  }
  void sortEvent(){
    eventList.sort((a, b) => b.time.compareTo(a.time));
  }

  void clear(){
    eventList = [];
  }

  void load() async{
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(
        '${directory.path}/eventData/${DateFormat('yyyyMMdd').format(DateTime.now())}_eventSummary.csv');

    var data = await fromCsv(file.path);
    //TO eventList
    eventList = [];
    for(int i = 0; i< data[0].data.length; i++){
      print('adding $i th event to list');
      eventList.add(Event(DateTime.parse(data['time'].data.elementAt(i)), data['event'].data.elementAt(i)));
    }

  }

  void save() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(
        '${directory.path}/eventData/${DateFormat('yyyyMMdd').format(DateTime.now())}_eventSummary.csv');
    bool isExists = await file.exists();
    debugPrint("writing Cache to Local..");

    if (!isExists)
      await file.writeAsString(
        'time, event \n',
        mode: FileMode.append);

    for (int i = 0; i < eventList.length; i++) {
      var line = eventList[i];
      await file.writeAsString(
          '${line.time.toString()}, ${line.note.toString()}  \n',
          mode: FileMode.append);
    }
  }
}