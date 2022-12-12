import 'package:flutter/material.dart';
import 'package:lateDiary/app.dart';
import 'package:lateDiary/pages/setting_page.dart';
import 'year_page_view.dart';
import 'package:provider/provider.dart';

import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

class YearPageScreen2 extends StatefulWidget {
  const YearPageScreen2({Key? key}) : super(key: key);

  @override
  State<YearPageScreen2> createState() => _YearPageScreen2State();
}

class _YearPageScreen2State extends State<YearPageScreen2> {
  late List<SocialMediaUsers> _source;

  @override
  void initState() {
    _source = <SocialMediaUsers>[
      SocialMediaUsers('India', 'Facebook', 25.4),
      SocialMediaUsers('USA', 'Instagram', 19.11),
      SocialMediaUsers('Japan', 'Facebook', 13.3),
      SocialMediaUsers('Germany', 'Instagram', 10.65),
      SocialMediaUsers('France', 'Twitter', 7.54),
      SocialMediaUsers('UK', 'Instagram', 4.93),
      SocialMediaUsers('UK', 'Instagram', 3),
      SocialMediaUsers('Japan', 'Facebook', 2),
      SocialMediaUsers('Germany', 'Instagram', 1),
      SocialMediaUsers('France', 'Twitter', 10),
      SocialMediaUsers('UK', 'Instagram', 6),
      SocialMediaUsers('UK', 'Instagram', 8),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<YearPageStateProvider>(
        builder: (context, product, child) => SingleChildScrollView(
          child: Container(
            height: 1000,
            width: 1000,
            child: SfTreemap(
              enableDrilldown: true,
              dataCount: product.dataForChartList[0].length,
              // dataCount: 10,

              weightValueMapper: (int index) {
                print("$index / ${product.dataForChartList[0].length}");
                print("${product.dataForChartList[0][index]}");
                return YearPageData.fromData(product.dataForChartList[0][index])
                    .number;
              },
              breadcrumbs: TreemapBreadcrumbs(
                builder:
                    (BuildContext context, TreemapTile tile, bool isCurrent) {
                  print("iscurrent : $isCurrent");
                  return Text(tile.group);
                },
              ),
              levels: [
                TreemapLevel(
                  groupMapper: (int index) {
                    // print("$index / ${product.dataForChartList[0].length}");
                    // print("${product.dataForChartList[0][index]}");
                    return YearPageData.fromData(
                            product.dataForChartList[0][index])
                        .week;
                  },
                  labelBuilder: (BuildContext context, TreemapTile tile) {
                    return Padding(
                      padding: const EdgeInsets.all(2.5),
                      child: Text(
                        '${tile.group}',
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  },
                ),

                TreemapLevel(groupMapper: (int index){
                  return YearPageData.fromData(
                    product.dataForChartList[0][index]).weekday;

                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class YearPageData {
  const YearPageData(
      this.week, this.weekday, this.number, this.location, this.date);
  final String week;
  final String weekday;
  final double number;
  final int location;
  final String date;

  factory YearPageData.fromData(data) {
    // print(
    //     "type : ${data[0].runtimeType}, ${data[1].runtimeType}, ${data[2].runtimeType} , ${data[3].runtimeType}, ${data[4].runtimeType}   ");
    // print(
    //     "type :  ${double.parse(data[2].toString()).runtimeType} , ${data[3].toInt().runtimeType}, ${data[4].runtimeType}   ");
    // print(
    //     "type :  ${double.parse(data[2].toString()).runtimeType}   ");

    // print("type : ${data[0].toString().runtimeType}");
    // print("type : ${data[1].toString().runtimeType}");
    // print("type : ${double.parse(data[2].toString()).runtimeType}");
    // print("type : ${data[3].toInt().runtimeType}");
    // print("type : ${data[4].toString().runtimeType}");
    // print('aa');
    if (data[2] == 0) data[2] = 1;
    return YearPageData(data[0].toString(), data[1].toString(),
        double.parse(data[2].toString()), data[3].toInt(), data[4].toString());
  }
}

class SocialMediaUsers {
  const SocialMediaUsers(this.country, this.socialMedia, this.usersInMillions);
  final String country;
  final String socialMedia;
  final double usersInMillions;
}
