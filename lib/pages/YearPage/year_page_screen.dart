import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/Util.dart';
import 'year_chart.dart';
import 'drop_down_button_2.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';

Size sizeOfChart = Size(800, 800);

class YearPageScreen extends StatefulWidget {
  YearPageScreen({Key? key}) : super(key: key);

  @override
  State<YearPageScreen> createState() => _YearPageScreenState();
}

class _YearPageScreenState extends State<YearPageScreen> {
  PhotoViewScaleStateController scaleStateController =
      PhotoViewScaleStateController();
  late PhotoViewController controller;

  int maxNumOfYearChart = 10;

  var key2 = GlobalKey();
  double scaleCopy = 0.0;

  double minScale = 1;


  @override
  void initState() {
    super.initState();
    controller = PhotoViewController()
      ..outputStateStream.listen(listener);
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void listener(PhotoViewControllerValue value){
    setState((){
      scaleCopy = value.scale?? 1;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(children: [
        Consumer<YearPageStateProvider>(
          builder: (context, product, child) => WillPopScope(
            onWillPop: () async {
              if ((product.highlightedYear == null) &
                  (product.expandedYear == null) &
                  (product.photoViewScale == 1)) return true;
              product.setHighlightedYear(null);
              product.setExpandedYear(null);
              product.setPhotoViewScale(1);
              controller.scale = 1;
              return false;
            },
            child: RepaintBoundary(
              key: key2,
              child: PhotoView.customChild(
                backgroundDecoration: BoxDecoration(color: Colors.black12),
                customSize: sizeOfChart,
                minScale: minScale,
                // scaleStateController: scaleStateController,
                controller: controller,
                onTapDown: (context, detail, _) {
                  if (detail.globalPosition.dy > 70)
                    product.setOffstageMenu(true);
                },
                onScaleEnd: (context, value, a) {
                  product.setPhotoViewScale(a.scale ?? 1);
                  if (product.photoViewScale! < 1) {
                    product.setPhotoViewScale(1);
                    product.setOffstageMenu(false);
                    product.setExpandedYear(null);
                  }
                },
                child: Stack(alignment: Alignment.center, children: [
                  CustomPaint(size: Size(0, 0), painter: OpenPainter()),
                  ...List.generate(
                      product.dataForChart2_modified.length > maxNumOfYearChart
                          ? maxNumOfYearChart
                          : product.dataForChart2_modified.length, (index) {
                    int year =
                        product.dataForChart2_modified.keys.elementAt(index);

                    return YearChart(
                        year: year, radius: 1 - index * 0.1, product: product);
                  }),
                ]),
              ),
            ),
          ),
        ),
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
    floatingActionButton: FloatingActionButton(
      onPressed: (){
        controller.scale = 2.0;
      },
    ),

    );
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
      File imgFile = new File('$directory/lateDiary_${dateString}.png');
      await imgFile.writeAsBytes(pngBytes);
      print("FINISH CAPTURE ${imgFile.path}");

      await Share.shareXFiles([XFile(imgFile.path)], text: 'aa');
      SnackBar snackBar =
          SnackBar(content: Text('Image is also saved in ${imgFile.path}'),
          // action: SnackBarAction(label : "navitate", onPressed: (){},),
    );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}


class OpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Color(0xff808080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    canvas.drawCircle(Offset(0, 0), (physicalWidth / 2 - 3) * 0.3, paint1);
    canvas.drawCircle(Offset(0, 0), physicalWidth / 2 - 3, paint1);

    var paint2 = Paint()
      ..color = Color(0xff3f3f3f)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    double radius = 240;

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
    );

    final textSpan = TextSpan(
      text: 'aa',
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    final intl.DateFormat formatter = intl.DateFormat('MMM');

    for (int i = 0; i < 12; i++) {
      double angle = 2 * pi / 12 * i + 2 * pi / 24 * 16;
      double xOffset = cos(angle) * radius;
      double yOffset = sin(angle) * radius;
      canvas.drawLine(Offset(0, 0), Offset(xOffset, yOffset), paint2);

      final textSpan = TextSpan(
        text: '${formatter.format(DateTime(2022, i))}',
        style: textStyle,
      );

      textPainter..text = textSpan;
      textPainter.layout(
        minWidth: 0,
        maxWidth: 35,
      );

      textPainter.paint(canvas, Offset(xOffset - 14, yOffset - 7));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
