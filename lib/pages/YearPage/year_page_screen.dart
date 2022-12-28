import 'dart:io';
import 'dart:math';
import 'dart:ui';
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

class YearPageScreen extends StatefulWidget {
  const YearPageScreen({Key? key}) : super(key: key);

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
    controller = PhotoViewController()..outputStateStream.listen(listener);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void listener(PhotoViewControllerValue value) {
    setState(() {
      scaleCopy = value.scale ?? 1;
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
                  (controller.scale == 1)) return true;
              product.setHighlightedYear(null);
              product.setExpandedYear(null);
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

                onScaleEnd: (context, value, a) {
                  controller.scale = a.scale?? 1;
                  if (controller.scale! < 1) {
                    controller.scale = 1;
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // controller.scale = 2.0;
      //     var a = Provider.of<YearPageStateProvider>(context, listen: false);
      //     a.dataForChart2_modified[2022].forEach((element) => print(element));
      //     print("$physicalWidth, $physicalHeight}");
      //     print(window.physicalSize);
      //     print(sizeOfChart);
      //   },
      // ),
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
      File imgFile = File('$directory/lateDiary_${dateString}.png');
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
}
var rng = Random();
int randomNumber1 = rng.nextInt(800);
int randomNumber2 = rng.nextInt(800);
int randomNumber3 = rng.nextInt(800);
int randomNumber4 = rng.nextInt(800);
int randomNumber5 = rng.nextInt(800);
int randomNumber6 = rng.nextInt(800);
int randomNumber7 = rng.nextInt(800);
List<int> randomNumber = List.generate(20, (index)=>rng.nextInt(800));

class OpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = const Color(0xff808080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    canvas.drawCircle(const Offset(0, 0), (physicalWidth / 2 - 3) * 0.3, paint1);
    canvas.drawCircle(const Offset(0, 0), physicalWidth / 2 - 3, paint1);

    var paint2 = Paint()
      ..color = const Color(0xff3f3f3f)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    double radius = physicalWidth / 2 * 1.2;
    //
    // var paint3 = Paint()..color = Colors.white;

    // canvas.drawCircle(Offset(rng.nextInt(800) - 400, rng.nextInt(800) - 400), 5, paint3);
    // for(int i = 0; i < 19; i++){
    //   canvas.drawCircle(Offset(randomNumber.elementAt(i) - 400, randomNumber.elementAt(i+1) - 400), 1, paint3);
    // }

    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
    );

    const textSpan = TextSpan(
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
      canvas.drawLine(const Offset(0, 0), Offset(xOffset, yOffset), paint2);

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
