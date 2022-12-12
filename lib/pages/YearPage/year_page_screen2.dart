import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:lateDiary/Data/data_manager_interface.dart';
import 'package:lateDiary/Data/info_from_file.dart';
import 'package:lateDiary/app.dart';
import 'package:lateDiary/pages/setting_page.dart';
import 'package:matrix2d/matrix2d.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';
// import 'package:vector_math/vector_math.dart' as vector;
// import 'package:vector_math/vector_math_64.dart';
import 'year_page_view.dart';
import 'package:provider/provider.dart';

import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:go_router/go_router.dart';
import 'year_page_view_level1.dart';
import 'package:lateDiary/Util/Util.dart';

class YearPageScreen2 extends StatefulWidget {
  const YearPageScreen2({Key? key}) : super(key: key);

  @override
  State<YearPageScreen2> createState() => _YearPageScreen2State();
}

class _YearPageScreen2State extends State<YearPageScreen2> {
  double _scale = 1.0;
  double _previousScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<YearPageStateProvider>(
        builder: (context, product, child) => Scaffold(
          appBar: AppBar(),
          body: TreeMap(product: product).build(context),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              product.dataForChartList2.forEach((element) {
                if (element[4].toString().contains("202203"))
                  print(element);
              });
            },
          ),
        ));
  }
}

class TreeMap {
  YearPageStateProvider product;
  TreeMap({required this.product});

  Widget build(BuildContext context) {
    return SfTreemap(
        dataCount: product.dataForChartList2.length,
        enableDrilldown: true,
        breadcrumbs: TreemapBreadcrumbs(
          builder: (BuildContext context, TreemapTile tile,
              bool isCurrent) {
            return Text("${tile.group}");
          },
        ),
        levels: [
          TreemapLevel(groupMapper: (int index) {
            // print("date : ${ product.dataForChartList2[index]}");
            // print("date : ${ product.dataForChartList2[index][4].toString()}");
            String year = product.dataForChartList2[index][4]
                .toString()
                .substring(0, 4);
            return year;
          }, itemBuilder: (BuildContext context, TreemapTile tile) {
            return FittedBox(
                child: Center(
                    child: Text("${tile.group}, ${tile.weight}")));
          }),
          TreemapLevel(groupMapper: (int index) {
            String yearMonth = product.dataForChartList2[index][4]
                .toString()
                .substring(0, 6);
            return yearMonth;
          }, itemBuilder: (BuildContext context, TreemapTile tile) {
            return FittedBox(
                child: Center(
                    child: Text("${tile.group}, ${tile.weight}")));
          }),

          TreemapLevel(
              padding: EdgeInsets.all(2.0),
              // color: Colors.transparent,
              groupMapper: (int index) {
                String yearMonthDay = product.dataForChartList2[index][4]
                    .toString()
                    .substring(0, 8);
                // String week = product.dataForChartList2[index][0].toString();
                return yearMonthDay;
              }, itemBuilder: (BuildContext context, TreemapTile tile) {

            print("location : ${DataManagerInterface(global.kOs).summaryOfLocationData[tile.group]}");
            double location = DataManagerInterface(global.kOs).summaryOfLocationData[tile.group]!;
            return Flexible(
              fit : FlexFit.tight,
              child: Container(
                  color : Color.fromARGB(100, (location*5).ceil(), 100, 100),

                  child: Text("${tile.group}, ${tile.weight}")),
            );

            //             Iterable<MapEntry<dynamic, InfoFromFile>> paths = DataManagerInterface(global.kOs).infoFromFiles.entries.where((element) => element.value.date == tile.group);
            //         return LayoutBuilder(
            //           builder: (BuildContext context, BoxConstraints constraints){
            //             double aspectRatio = constraints.maxWidth / constraints.maxHeight;
            //             print("constraints : $aspectRatio");
            //             if(aspectRatio > 1.5){
            //               return Row(children : List.generate(aspectRatio.ceil(), (index) => Container(
            //                 width : constraints.maxHeight * aspectRatio / aspectRatio.ceil(),
            //                 height : constraints.maxHeight,
            //                 child: ExtendedImage.file(File(paths.elementAt(index).key),
            //                   fit : BoxFit.cover,
            //                   compressionRatio: 0.05,),
            //               )));
            //             }
            //             if(aspectRatio < 0.7){
            //               return Column(
            //
            //                   children : List.generate((1/aspectRatio).ceil(),
            //                       (index) => Container(
            //                         width : constraints.maxWidth,
            //                         height : constraints.maxWidth *(1/ aspectRatio )/ (1/aspectRatio).ceil(),
            //                         child: ExtendedImage.file(File(paths.elementAt(index).key),
            //                 fit : BoxFit.cover,
            //                 compressionRatio: 0.05,),
            //                       )));
            //             }
            //             return SizedBox(
            //                 width: 500,
            //                 height : 500,
            //             child: ExtendedImage.file(File(paths.elementAt(0).key),
            //             fit : BoxFit.cover,
            //             compressionRatio: 0.05,),
            //           );
            // });
          }),
        ],
        weightValueMapper: (int index) {
          var data = product.dataForChartList2[index][2];
          print("2 type :${product.dataForChartList2[index][2]} ");
          return data == 0 ? 1 : data.toDouble();
        });


  }
}

