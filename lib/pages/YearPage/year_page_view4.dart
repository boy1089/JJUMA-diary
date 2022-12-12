import 'package:flutter/material.dart';
import 'package:lateDiary/app.dart';
import 'package:lateDiary/pages/setting_page.dart';
import 'package:matrix2d/matrix2d.dart';
import 'year_page_view.dart';
import 'package:provider/provider.dart';

import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:go_router/go_router.dart';
import 'year_page_view_level1.dart';
import 'package:lateDiary/Util/Util.dart';

class YearPageScreen2 extends StatelessWidget {
  const YearPageScreen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, int> data = {
      "2022": 100,
      "2021": 50,
      "2020": 150,
      "2019": 30,
      "2018": 200,
      "2017": 180,
      "2016": 5,
      "2015": 10,
    };

    int counts = data.values.toList().reduce((a, b) => a + b);
    int indexA = 0;
    int rows = 4;

    return Consumer<YearPageStateProvider>(
      builder: (context, product, child) => Scaffold(
          appBar: AppBar(),
          body: Container(
              width: physicalWidth,
              // height: physicalHeight,
              child: Column(
                // mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  //   crossAxisAlignment: CrossAxisAlignment.end,

                  children: List.generate(3, (index) {
                    int currentCount = 0;
                    int threshold = (counts / rows).floor() * (index + 1);
                    List<String> dataForRow = [];
                    print("indexA : $indexA, $threshold, $currentCount");
                    for (int j = indexA; j < data.length; j++) {

                      print("indexA : $indexA, $threshold, $j");
                      if (currentCount > threshold) {
                        indexA = j;
                        break;
                      }
                      currentCount = currentCount + data.values!.elementAt(j);
                      dataForRow.add(data.keys.elementAt(j));
                    }

                    return Row(
                        mainAxisSize: MainAxisSize.max,
                        children: List.generate(
                            dataForRow.length,
                                (i) => Container(
                              color: Colors.grey,
                              // width : 100,
                              height: (physicalHeight / rows).ceilToDouble(),
                              child: Text("${dataForRow[i]}"),
                            )));
                  }))),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              print(product.dataForChartList2);
            },
          )),
    );
  }
}
