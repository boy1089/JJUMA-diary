import 'package:flutter/material.dart';
import 'YearPageView.dart';
import 'package:provider/provider.dart';

import 'package:lateDiary/StateProvider/YearPageStateProvider.dart';

class YearPage extends StatelessWidget {
  int year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<YearPageStateProvider>(
      builder: (context, product, child) => PageView.builder(
          physics:
              product.isZoomIn
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
          controller: PageController(
              viewportFraction: 1.0,
              initialPage:
                  product.index),
          itemCount: 20,
          reverse: true,
          itemBuilder: (BuildContext context, int index) {
            year = DateTime.now().year - index;
            return YearPageView(year, product, context);
          }),
    ));
  }
  @override
  void dispose(){
    print("year page disposed");
  }
}
