import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:jjuma.d/Util/DateHandler.dart';
import 'package:jjuma.d/pages/YearPage/legend.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:jjuma.d/StateProvider/year_page_state_provider.dart';
import 'package:jjuma.d/Util/Util.dart';
import 'year_chart.dart';
import 'drop_down_button_2.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'package:jjuma.d/pages/YearPage/chart_background.dart';

class YearPageScreen extends StatefulWidget {
  const YearPageScreen({Key? key}) : super(key: key);

  @override
  State<YearPageScreen> createState() => _YearPageScreenState();
}

class _YearPageScreenState extends State<YearPageScreen> {
  PhotoViewScaleStateController scaleStateController =
      PhotoViewScaleStateController();
  late PhotoViewController controller;

  var key2 = GlobalKey();
  double scaleCopy = 0.0;
  double minScale = 1;

  late TestWidget testWidget;
  bool testFlag = false;

  @override
  void initState() {
    super.initState();
    controller = PhotoViewController()..outputStateStream.listen(listener);
    testWidget = TestWidget(testFlag);
  }

  void listener(PhotoViewControllerValue value) {
    setState(() {
      scaleCopy = value.scale ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(alignment: Alignment.topCenter, children: [
          Consumer<YearPageStateProvider>(
            builder: (context, product, child) => WillPopScope(
              onWillPop: () => willPopLogic(product),
              child: RepaintBoundary(
                key: key2,
                child: PhotoView.customChild(
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.black12),
                  customSize: sizeOfChart,
                  minScale: minScale,
                  controller: controller,
                  onScaleEnd: (context, value, a) {
                    controller.scale = a.scale ?? minScale;
                    if (controller.scale! < minScale) {
                      controller.scale = minScale;
                      // product.setExpandedYear(null);
                    }
                  },
                  child: Stack(alignment: Alignment.center, children: [
                    CustomPaint(size: const Size(0, 0), painter: OpenPainter()),
                    ...List.generate(product.listOfYears.length, (index) {
                      int year = product.listOfYears.elementAt(index);
                      return YearChart(
                          year: year,
                          radius: 1 - index * 0.1,
                          product: product);
                    }),
                    // ...testWidget.listOfWidget,
                    yearButton(product),
                  ]),
                ),
              ),
            ),
          ),
          Positioned(bottom: 30, child: LegendOfYearChart()),
          SizedBox(
            height: 70,
            child: AppBar(
              backgroundColor: Colors.transparent,
              excludeHeaderSemantics: true,
              elevation: 0.0,
              actions: [CustomButtonTest(capture)],
            ),
          ),
        ]),
      ),
    );
  }

  willPopLogic(product) async {
    {
      if ((product.highlightedYear == null) &
          (product.expandedYear == null) &
          (controller.scale == 1)) return true;

      product.setHighlightedYear(null);

      if (controller.scale != 1) {
        controller.scale = 1;
        return false;
      }

      if (product.expandedYear != null) {
        product.setExpandedYear(null);
      }

      return false;
    }
  }

  yearButton(YearPageStateProvider product) {
    return ElevatedButton(
        onPressed: () {
          product.setExpandedYearByButton();

          setState(() {
            testFlag = !testFlag;
            testWidget = testWidget..on = testFlag;
            testWidget.updateListOfWidget();
            print(testWidget.listOfWidget);
          });
        },
        onLongPress: () {
          showGeneralDialog(
              barrierDismissible: true,
              barrierLabel: "yearButton",
              barrierColor: Colors.transparent,
              context: context,
              pageBuilder: (context, animation, animation2) => SafeArea(
                child: Center(
                      child: Container(
                        width: 500,
                        height: 430,
                        child: Stack(
                            alignment: Alignment.center,
                            children: List<Widget>.generate(
                                product.listOfYears.length,
                                (i) => Align(
                                    alignment: Alignment(
                                        cos(2 * pi / product.listOfYears.length * i + 0.02 * pi) * 0.6,
                                        sin(2 * pi / product.listOfYears.length * i + 0.02 * pi) * 0.6),
                                    child: yearButton2(
                                        product,
                                        product.listOfYears
                                            .elementAt(i)
                                            .toString())))),
                      ),
                    ),
              ));
        },
        style: ElevatedButton.styleFrom(
            side: const BorderSide(width: 1, color: Color(0xff808080)),
            backgroundColor: Colors.transparent,
            fixedSize: Size(70.0, 70.0),
            shape: const CircleBorder()),
        child: Text(
          product.expandedYear == null
              ? "All"
              : product.expandedYear.toString(),
          style: const TextStyle(fontSize: 15),
        ));
  }

  yearButton2(YearPageStateProvider product, String text) {
    return ElevatedButton(
        onPressed: () {
          product.setExpandedYear(int.parse(text));
          context.pop();
        },
        style: ElevatedButton.styleFrom(
            side: const BorderSide(width: 1, color: Color(0xff808080)),
            backgroundColor: Colors.transparent,
            fixedSize: Size(70.0, 70.0),
            shape: const CircleBorder()),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15),
        ));
  }

  void capture() async {
    var renderObject = key2.currentContext!.findRenderObject();
    if (renderObject is RenderRepaintBoundary) {
      var boundary = renderObject;
      ui.Image image = await boundary.toImage(pixelRatio: 10.0);
      final directory = (await getExternalStorageDirectory())?.path;
      ByteData byteData =
          (await image.toByteData(format: ui.ImageByteFormat.png))!;
      Uint8List pngBytes = byteData.buffer.asUint8List();
      String dateString = "${formatDatetime(DateTime.now())}";
      File imgFile = File('$directory/jjuma.d_${dateString}.png');
      await imgFile.writeAsBytes(pngBytes);
      print("FINISH CAPTURE ${imgFile.path}");

      await Share.shareXFiles([XFile(imgFile.path)], text: 'aa');
      SnackBar snackBar = SnackBar(
        content: Text('Image is also saved in ${imgFile.path}'),
        // action: SnackBarAction(label : "navitate", onPressed: (){},),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class TestWidget {
  TestWidget(this.on){
    updateListOfWidget();
  }
  bool on= false;
  List listOfWidget = [];

  updateListOfWidget(){
    listOfWidget = List.generate(10, (i) {

      print('aa');
      return AnimatedPositioned(
          duration: Duration(seconds: 1),
          left: on ? 400 : i * 10,
          child: Container(width: 30, height: 40, color: Colors.blue));
    }

    );
  }
}
