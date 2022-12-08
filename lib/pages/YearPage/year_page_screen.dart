import 'package:flutter/material.dart';
import 'package:lateDiary/pages/setting_page.dart';
import 'year_page_view.dart';
import 'package:provider/provider.dart';

import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:go_router/go_router.dart';

class YearPageScreen extends StatelessWidget {
  static String id = '/year';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<YearPageStateProvider>(
        builder: (context, product, child) => WillPopScope(
          onWillPop: () async {
            product.setZoomInState(false);
            return Navigator.canPop(context);
          },
          child: PageView.builder(
              physics: product.isZoomIn
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              controller: PageController(
                  viewportFraction: 1.0, initialPage: product.index),
              itemCount: 20,
              reverse: true,
              itemBuilder: (BuildContext context, int index) {
                int year = DateTime.now().year - index;
                return YearPageView(
                    year: year,
                    dataForChart: product.dataForChartList[index],
                    isZoomIn: product.isZoomIn,
                    angle: product.zoomInAngle,
                    context: context);
                // return YearPageView2(year : year);
              }),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        mini: true,
        child: Icon(Icons.settings),
        onPressed: () {
          // context.go('/setting');
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => AndroidSettingsScreen()));
        },
      ),
    );
  }

  onTap(BuildContext context) {}

  @override
  void dispose() {
    print("year page disposed");
  }
}
