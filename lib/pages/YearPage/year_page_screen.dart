import 'package:flutter/material.dart';
import 'year_page_view.dart';
import 'package:provider/provider.dart';

import 'package:lateDiary/StateProvider/year_page_state_provider.dart';

class YearPageScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<YearPageStateProvider>(
      builder: (context, product, child) => PageView.builder(
          physics: product.isZoomIn
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          controller:
              PageController(viewportFraction: 1.0, initialPage: product.index),
          itemCount: 20,
          reverse: true,

          itemBuilder: (BuildContext context, int index) {
            int year = DateTime.now().year - index;
            return YearPageView(
                year: year,
                dataForChart: product.dataForChartList[index],
                isZoomIn: product.isZoomIn,
                angle : product.zoomInAngle,
                context: context);
            // return YearPageView2(year : year);

          }),
    ));
  }

  @override
  void dispose() {
    print("year page disposed");
  }
}
