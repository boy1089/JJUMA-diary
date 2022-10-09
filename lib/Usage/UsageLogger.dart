import 'package:usage_stats/usage_stats.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:intl/intl.dart';

class UsageLogger {
  List<EventUsageInfo> events = [];
  List<UsageInfo> usageInfos = [];
  List<EventInfo> eventInfo =[];
  List<NetworkInfo> networkInfo = [];
  Map<String?, NetworkInfo?> _netInfoMap = Map();

  UsageLogger() {
    initUsage();
    debugPrint("usage logger instance created");
  }

  Future<void> initUsage() async {
    try {
      UsageStats.grantUsagePermission();

      DateTime endDate = new DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 1));

      // List<EventUsageInfo> queryEvents =
      //     await UsageStats.queryEvents(startDate, endDate);
      // List<NetworkInfo> networkInfos = await UsageStats.queryNetworkUsageStats(
      //   startDate,
      //   endDate,
      //   networkType: NetworkType.all,
      // );
      //
      // Map<String?, NetworkInfo?> netInfoMap = Map.fromIterable(networkInfos,
      //     key: (v) => v.packageName, value: (v) => v);
      //
      // List<UsageInfo> t = await UsageStats.queryUsageStats(startDate, endDate);

      // events = queryEvents.reversed.toList();
      // _netInfoMap = netInfoMap;
    } catch (err) {
      print(err);
    }
  }

  void getEvents(startDate, endDate) async {
    List<EventUsageInfo> events = await UsageStats.queryEvents(
        startDate, endDate);
    this.events = events;
  }

  void getUsageStat(startDate, endDate) async{
    List<UsageInfo> usageInfos = await UsageStats.queryUsageStats(
        startDate, endDate);
    this.usageInfos = usageInfos;
  }

  void getEventInfo(startDate, endDate) async{
    List<EventInfo> eventInfo = await UsageStats.queryEventStats(
        startDate, endDate);
    this.eventInfo = eventInfo;
  }

  void getNetworkInfo(startDate, endDate) async{
    List<NetworkInfo> networkInfo = await UsageStats.queryNetworkUsageStats(
        startDate, endDate);
    this.networkInfo = networkInfo;
  }


  void writeCache3() async {
    final Directory? directory = await getExternalStorageDirectory();
    final String folder = '${directory?.path}/usageData';
    bool isFolderExists = await Directory(folder).exists();

    final File file = File(
        '${folder}/${DateFormat('yyyyMMdd').format(DateTime.now())}_usageInfo.csv');

    if (!isFolderExists){
      Directory(folder).create(recursive : true);
    }

    bool isExists = await file.exists();
    debugPrint("writing note to Local..");

    // if (!isExists)
    await file.writeAsString(
        'packageName, firstTimeStamp, lastTimeStamp, lastTimeUsed, totalTineInForeground \n',

        mode: FileMode.write);

    for (int i = 0; i < this.usageInfos.length; i++) {
      var line = this.usageInfos.elementAt(i);
      await file.writeAsString(
          '${(line.packageName.toString())},'
              ' ${DateTime.fromMicrosecondsSinceEpoch(int.parse(line.firstTimeStamp.toString())*1000)},'
              ' ${DateTime.fromMicrosecondsSinceEpoch(int.parse(line.lastTimeStamp.toString())*1000)},'
              ' ${DateTime.fromMicrosecondsSinceEpoch(int.parse(line.lastTimeUsed.toString())*1000)},'
              ' ${DateTime.fromMicrosecondsSinceEpoch(int.parse(line.totalTimeInForeground.toString())*1000)}\n',
          mode: FileMode.append);
    }

    this.usageInfos = [];

  }

  void writeCache4() async {
    final Directory? directory = await getExternalStorageDirectory();
    final String folder = '${directory?.path}/usageData';
    bool isFolderExists = await Directory(folder).exists();

    final File file = File(
        '${folder}/${DateFormat('yyyyMMdd').format(DateTime.now())}_eventInfo.csv');

    if (!isFolderExists){
      Directory(folder).create(recursive : true);
    }

    bool isExists = await file.exists();
    debugPrint("writing note to Local..");

    // if (!isExists)
    await file.writeAsString(
        'firstTimeStamp, lastTimeStamp, totalTime, lastEventTime, eventType, count \n',

        mode: FileMode.write);

    for (int i = 0; i < this.eventInfo.length; i++) {
      var line = this.eventInfo.elementAt(i);
      await file.writeAsString(
              ' ${DateTime.fromMicrosecondsSinceEpoch(int.parse(line.firstTimeStamp.toString())*1000)},'
              ' ${DateTime.fromMicrosecondsSinceEpoch(int.parse(line.lastTimeStamp.toString())*1000)},'
              ' ${DateTime.fromMicrosecondsSinceEpoch(int.parse(line.totalTime.toString())*1000)},'
              '${DateTime.fromMicrosecondsSinceEpoch(int.parse(line.lastEventTime.toString())*1000)},'
              '${line.eventType},'
                  '${line.count}\n',
          mode: FileMode.append);
    }

    this.usageInfos = [];

  }


  void writeCache5() async {
    final Directory? directory = await getExternalStorageDirectory();
    final String folder = '${directory?.path}/usageData';
    bool isFolderExists = await Directory(folder).exists();

    final File file = File(
        '${folder}/${DateFormat('yyyyMMdd').format(DateTime.now())}_networkInfo.csv');

    if (!isFolderExists){
      Directory(folder).create(recursive : true);
    }

    bool isExists = await file.exists();
    debugPrint("writing note to Local..");

    // if (!isExists)
    await file.writeAsString(
        'firstTimeStamp, lastTimeStamp, totalTime, lastEventTime, eventType, count \n',

        mode: FileMode.write);

    for (int i = 0; i < this.eventInfo.length; i++) {
      var line = this.eventInfo.elementAt(i);
      await file.writeAsString(
          ' ${DateTime.fromMicrosecondsSinceEpoch(int.parse(line.firstTimeStamp.toString()))},'
              ' ${DateTime.fromMicrosecondsSinceEpoch(int.parse(line.lastTimeStamp.toString()))},'
              ' ${DateTime.fromMicrosecondsSinceEpoch(int.parse(line.totalTime.toString()))},'
              '${DateTime.fromMicrosecondsSinceEpoch(int.parse(line.lastEventTime.toString()))},'
              '${line.eventType},'
              '${line.count}\n',
          mode: FileMode.append);
    }

    this.usageInfos = [];

  }

// void writeCache() async {
  //   final Directory directory = await getApplicationDocumentsDirectory();
  //   final File file = File(
  //       '${directory.path}/usageData/${DateFormat('yyyyMMdd').format(DateTime.now())}_usage.csv');
  //   bool isExists = await file.exists();
  //   debugPrint("writing note to Local..");
  //
  //   // if (!isExists)
  //   await file.writeAsString(
  //       'time, packageName, eventType, className \n',
  //       mode: FileMode.write);
  //
  //   for (int i = 0; i < this.events.length; i++) {
  //     var line = this.events.elementAt(i);
  //     await file.writeAsString(
  //         '${DateTime.fromMicrosecondsSinceEpoch(int.parse(line.timeStamp.toString())*1000)},'
  //             ' ${line.packageName.toString()},'
  //             ' ${line.eventType.toString()},'
  //             ' ${line.className.toString()} \n',
  //         mode: FileMode.append);
  //   }
  //
  //   this.events = [];
  //
  // }


}
