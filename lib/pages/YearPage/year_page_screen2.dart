import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:lateDiary/Data/data_manager_interface.dart';
import 'package:lateDiary/Data/info_from_file.dart';
import 'package:lateDiary/StateProvider/day_page_state_provider.dart';
import 'package:lateDiary/app.dart';
import 'package:lateDiary/pages/DayPage/widgets/clickable_photo_card.dart';
import 'package:lateDiary/pages/DayPage/widgets/photo_card.dart';
import 'package:lateDiary/pages/setting_page.dart';
import 'package:matrix2d/matrix2d.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';
// import 'package:vector_math/vector_math.dart' as vector;
// import 'package:vector_math/vector_math_64.dart';
import '../DayPage/model/event.dart';
import 'year_page_view.dart';
import 'package:provider/provider.dart';

import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:go_router/go_router.dart';
import 'year_page_view_level1.dart';
import 'package:lateDiary/Util/Util.dart';

import 'dart:math';

class YearPageScreen2 extends StatefulWidget {
  const YearPageScreen2({Key? key}) : super(key: key);

  @override
  State<YearPageScreen2> createState() => _YearPageScreen2State();
}

class _YearPageScreen2State extends State<YearPageScreen2> {


  @override
  Widget build(BuildContext context) {

    return Consumer<YearPageStateProvider>(
        builder: (context, product, child) => Scaffold(
              body: SafeArea(child: TreeMap(product: product).build(context)),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  setState(() {});
                },
                child: Icon(Icons.refresh_outlined),
              ),
            ));
  }
}

class TreeMap {
  YearPageStateProvider product;
  TreeMap({required this.product});

  Widget build(BuildContext context) {
    DataManagerInterface dataManager = DataManagerInterface(global.kOs);
    Map<dynamic, InfoFromFile> data = dataManager.infoFromFiles;
    return SfTreemap(
        dataCount: dataManager.infoFromFiles.length,
        enableDrilldown: true,
        breadcrumbs: TreemapBreadcrumbs(
          builder: (BuildContext context, TreemapTile tile, bool isCurrent) {
            return Text("${tile.group}");
          },
        ),
        levels: [
          TreemapLevel(groupMapper: (int index) {
            String year = data.values.elementAt(index).date!.substring(0, 4);
            return year;
          },
              itemBuilder: (BuildContext context, TreemapTile tile) {
            String year = tile.group;
            var imagesInYear = Map.from(data)..removeWhere((key, value) => value.date?.substring(0, 4) != year);

            String pathOfRandomImage = imagesInYear.entries
                .elementAt(Random().nextInt(imagesInYear.length))
                .key;
            return Stack(children: [
              Container(
                  width: 1000,
                  height: 1000,
                  child: ExtendedImage.file(File(pathOfRandomImage),
                      compressionRatio: 0.1, fit: BoxFit.cover)),
              Text(
                "${imagesInYear[pathOfRandomImage]?.date!.substring(0, 4)}",
                style: TextStyle(fontSize: 20.0),
              ),
            ]);
          }
          ),


          TreemapLevel(groupMapper: (int index) {
            String yearMonth =data.values.elementAt(index).date!.substring(0, 6);
            return yearMonth;
          },
              itemBuilder: (BuildContext context, TreemapTile tile) {
                String yearMonth = tile.group;
                var imagesInYear = Map.from(data)..removeWhere((key, value) => value.date?.substring(0, 6) != yearMonth);
                String pathOfRandomImage = imagesInYear.entries
                    .elementAt(Random().nextInt(imagesInYear.length))
                    .key;
                return Stack(children: [
                  Container(
                      width: 1000,
                      height: 1000,
                      child: ExtendedImage.file(File(pathOfRandomImage),
                          compressionRatio: 0.1, fit: BoxFit.cover)),
                  Text(
                    "${tile.group.substring(4)}",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ]);
              }
          ),

          TreemapLevel(groupMapper: (int index) {
            String yearMonthDay =data.values.elementAt(index).date!.substring(0, 8);
            return yearMonthDay;
          },
              itemBuilder: (BuildContext context, TreemapTile tile) {
                String yearMonthDay = tile.group;
                var filteredImages = Map.from(data)..removeWhere((key, value) => value.date?.substring(0, 8) != yearMonthDay);
                String pathOfRandomImage = filteredImages.entries
                    .elementAt(Random().nextInt(filteredImages.length))
                    .key;
                return Stack(children: [
                  Container(
                      width: 500,
                      height: 500,
                      child: ExtendedImage.file(File(pathOfRandomImage),
                          compressionRatio: 0.1, fit: BoxFit.cover)),
                  Text(
                    "${tile.group.substring(6)} 일",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ]);
              }
          ),
          TreemapLevel(groupMapper: (int index) {
            DateTime datetime = data.values.elementAt(index)!.datetime!;
            String yearMonthDayHour = "${datetime.year}${datetime.month}${datetime.day}${datetime.hour}";
            return yearMonthDayHour;
          },
              itemBuilder: (BuildContext context, TreemapTile tile) {
                String yearMonthDayHourOfTile = tile.group;
                print("yearmonthdayHourOfTile : ${yearMonthDayHourOfTile}");

                var filteredImages = Map.from(data)..removeWhere((key, value) {
                  DateTime datetime = value.datetime;
                  String yearMonthDayHour = "${datetime.year}${datetime.month}${datetime.day}${datetime.hour}";
                  return yearMonthDayHourOfTile != yearMonthDayHour;
                });
                // print("filtered images : ${filteredImages}");
                String pathOfRandomImage = filteredImages.entries
                    .elementAt(Random().nextInt(filteredImages.length))
                    .key;
                return Stack(children: [
                  Container(
                      width: 500,
                      height: 500,
                      child: ExtendedImage.file(File(pathOfRandomImage),
                          compressionRatio: 0.1, fit: BoxFit.cover)),
                  Text(
                    "${tile.group.substring(8)}",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ]);
              }
          ),
        ],
        weightValueMapper: (int index) {
          var data = dataManager.infoFromFiles;

          return 1;
        });

  }
}
