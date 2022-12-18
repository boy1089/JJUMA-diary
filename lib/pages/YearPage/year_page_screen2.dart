import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/Util/Util.dart';
import 'year_chart.dart';

class YearPageScreen2 extends StatefulWidget {
  YearPageScreen2({Key? key}) : super(key: key);

  @override
  State<YearPageScreen2> createState() => _YearPageScreen2State();
}

class _YearPageScreen2State extends State<YearPageScreen2> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<YearPageStateProvider>(
        builder: (context, product, child) => PhotoView.customChild(
          minScale: 1.0,
          onScaleEnd: (context, value, a) {
            product.setPhotoViewScale(a.scale ?? 1);
            if (product.photoViewScale! < 1) {
              product.setPhotoViewScale(1);
              product.setExpandedYear(null);
            }
          },
          child: SizedBox(
            width: physicalWidth,
            height: physicalWidth,
            child: Stack(
                alignment: Alignment.center,

                children: List.generate(product.dataForChart2.length, (index) {
                // children: List.generate(3, (index) {
                  int year = product.dataForChart2.keys.elementAt(index);

                  // if (product.expandedYear == null) {
                  return YearChart(
                      year: year,
                      radius: 1 - index * 0.1,
                      isExpanded: (product.expandedYear == null) ||
                              (product.expandedYear == year)
                          ? false
                          : true,
                      product: product);
                })),
          ),
        ),
      ),
    );
  }
}
