import 'dart:io';
import 'dart:math';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as image;
import 'package:jjuma.d/Data/android_data_manager.dart';
import 'package:jjuma.d/Data/data_manager_interface.dart';
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
import 'package:jjuma.d/Util/global.dart' as global;
import 'package:jjuma.d/ML/Classifier.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:simple_cluster/src/dbscan.dart';

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

  double zoomInMultiple = 4.0;

  double heightOfLegend = 70;
  late Offset center = Offset(-1 * (sizeOfChart.width / 2 - physicalWidth / 2),
      -1 * (sizeOfChart.height / 2 - physicalHeight / 2) - heightOfLegend / 2);
  Offset position = Offset(0, 0);
  double textScaleFactor = 1.0;
  @override
  void initState() {
    super.initState();
    position = center;
    textScaleFactor = MediaQuery.of(context).textScaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(alignment: Alignment.topCenter, children: [
          Consumer<YearPageStateProvider>(
            builder: (context, product, child) => WillPopScope(
              onWillPop: () async {
                return willPopLogic(product);
              },
              child: GestureDetector(
                onTapUp: (detail) {
                  double scale = product.scale * zoomInMultiple;

                  double x = (position.dx * -1 + detail.localPosition.dx) *
                          zoomInMultiple -
                      physicalWidth / 2 * zoomInMultiple;
                  double y = (position.dy * -1 + detail.localPosition.dy) *
                          zoomInMultiple -
                      physicalHeight / 2 * zoomInMultiple;
                  x = -1 * x;
                  y = -1 * y;

                  print("${detail.localPosition}, $x, $y");

                  product.setScale(scale);
                  setState(() {
                    position = Offset(x, y) -
                        center * zoomInMultiple -
                        Offset(physicalWidth / 2, heightOfLegend * 2.5);
                  });
                },
                onPanUpdate: (detail) {
                  if (product.scale == 1) return;
                  setState(() {
                    position = position + detail.delta;
                  });
                },
                onDoubleTap: () {
                  position = center;
                  product.setScale(1.0);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Stack(alignment: Alignment.center, children: [
                    AnimatedPositioned(
                      width: sizeOfChart.width,
                      height: sizeOfChart.width,
                      left: position.dx,
                      top: position.dy,
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 300),
                      child: AnimatedScale(
                          scale: product.scale,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Stack(alignment: Alignment.center, children: [
                            CustomPaint(
                                size: const Size(0, 0), painter: OpenPainter()),
                            ...List.generate(product.listOfYears.length,
                                (index) {
                              int year = product.listOfYears.elementAt(index);
                              return YearChart(
                                  year: year,
                                  radius: 1 - index * 0.1,
                                  product: product);
                            }),
                            // ...testWidget.listOfWidget,
                            yearButton(product),
                          ])),
                    )
                  ]),
                ),
              ),
            ),
          ),
          Positioned(bottom: 30, child: LegendOfYearChart()),
          SizedBox(
            height: heightOfLegend,
            child: AppBar(
              backgroundColor: Colors.transparent,
              excludeHeaderSemantics: true,
              elevation: 0.0,
              actions: [CustomButtonTest(capture)],
            ),
          ),
        ]),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     DataManagerInterface dataManager = DataManagerInterface(global.kOs);
      //     var infoFromFiles = dataManager.infoFromFiles;
      //
      //     Classifier classifier = Classifier();
      //     List<List<double>> data = [];
      //     int i = 0;
      //     infoFromFiles.forEach((key, value) {
      //       i+=1;
      //       if(i>2000) return;
      //       if((value.coordinate == null)) return;
      //       if((value.coordinate!.latitude == null)) return;
      //       data.add([value.coordinate!.latitude!, value.coordinate!.longitude!]);
      //     });
      //     print("executing DBSCAN");
      //     DBSCAN dbscan = DBSCAN(
      //       epsilon: 3,
      //       minPoints: 2,
      //     );
      //     // List<List<int>> clusterOutput = dbscan.run(data);
      //     print("DBSCAN done");
      //     // print(clusterOutput);
      //     // print(dbscan.label);
      //
      //     // a = clusterOutput;
      //     // b = dbscan.label;
      //     print(a);
      //     print(b);
      //
      //   },
      // ),
    );
  }

//TODO : make
  generateJumadeung(List listOfImages) async {
    final image.JpegDecoder decoder = image.JpegDecoder();
    final List<image.Image> images = [];
    for (int i = 0; i < listOfImages.length; i++) {
      String imagePath = listOfImages.elementAt(i);
      print("genering Jumadeung... add ${imagePath}");
      if (imagePath == null) continue;
      image.Image pngResized = await readImageWithDownsampling(imagePath, 500);
      images.add(decoder.decodeImage(image.encodeJpg(pngResized))!);
    }

    List<int>? gifData = generateGIFFromImages(images);
    final directory = global.kOs == "android"
        ? (await getExternalStorageDirectory())?.path
        : (await getApplicationDocumentsDirectory())?.path;
    File imgFile = File('$directory/jjuma.d_gif}.gif');
    Uint8List a = Uint8List.fromList(gifData!);
    await imgFile.writeAsBytes(a);
    print("done!");
  }

  getFavoriteImagePaths() {
    DataManagerInterface dataManager = DataManagerInterface(global.kOs);
    var dicOfFavoriteImages = dataManager.filenameOfFavoriteImages;
    List listOfFavoriteImages = [];
    for (int i = 0; i < dicOfFavoriteImages.length; i++) {
      String year = dicOfFavoriteImages.keys.elementAt(i);
      listOfFavoriteImages.addAll(dicOfFavoriteImages[year]!.values);
    }
    return listOfFavoriteImages;
  }

  Future<image.Image> readImageWithDownsampling(imagePath, width) async {
    Uint8List data = await File(imagePath).readAsBytes();
    image.Image png = image.decodeJpg(data)!;
    int width = png.width;
    int height = png.height;
    bool isWidthWiderThanHeight = width > height;
    int lengthOfBoundingBox = isWidthWiderThanHeight ? height : width;

    png = isWidthWiderThanHeight
        ? image.copyCrop(png, (lengthOfBoundingBox / 8).floor(), 0,
            lengthOfBoundingBox, lengthOfBoundingBox)
        : image.copyCrop(png, 0, (lengthOfBoundingBox / 8).floor(),
            lengthOfBoundingBox, lengthOfBoundingBox);

    image.Image pngResized = image.copyResize(png!, width: 500);
    return pngResized;
  }

  List<int>? generateGIFFromImages(Iterable<image.Image> images) {
    final image.Animation animation = image.Animation();
    for (image.Image image2 in images) {
      animation.addFrame(image2..duration = 350);
    }
    return image.encodeGifAnimation(animation, samplingFactor: 5);
  }

  //
  bool willPopLogic(YearPageStateProvider product) {
    {
      if ((product.highlightedYear == null) &&
          (product.expandedYear == null) &&
          (product.scale == 1.0)) {
        return true;
      }
      product.setHighlightedYear(null);

      if ((product.scale != 1) || (position != center)) {
        product.setScale(1.0);
        position = center;
        return false;
      }

      if (product.expandedYear != null) {
        product.setExpandedYear(null);
        product.setScale(1.0);
        position = center;
      }

      return false;
    }
  }

  yearButton(YearPageStateProvider product) {
    return ElevatedButton(
        onPressed: () async {
          if (product.scale != 1) {
            willPopLogic(product);
            await Future.delayed(Duration(milliseconds: 200));
          }
          showGeneralDialog(
              barrierDismissible: true,
              barrierLabel: "yearButton",
              barrierColor: Colors.transparent,
              context: context,
              pageBuilder: (context, animation, animation2) => SafeArea(
                    child: Stack(alignment: Alignment.topCenter, children: [
                      Positioned(
                        top: center.dy,
                        child: SizedBox(
                          width: sizeOfChart.width,
                          height: sizeOfChart.height,
                          child: Stack(
                              alignment: Alignment.center,
                              children: List<Widget>.generate(
                                  product.listOfYears.length,
                                  (i) => Align(
                                      alignment: Alignment(
                                          cos(2 *
                                                      pi /
                                                      product
                                                          .listOfYears.length *
                                                      i +
                                                  0.02 * pi) *
                                              0.4,
                                          sin(2 *
                                                      pi /
                                                      product
                                                          .listOfYears.length *
                                                      i +
                                                  0.02 * pi) *
                                              0.4),
                                      child: yearButton2(
                                          product,
                                          product.listOfYears
                                              .elementAt(i)
                                              .toString())))),
                        ),
                      ),
                    ]),
                  ));
        },
        style: ElevatedButton.styleFrom(
            side: const BorderSide(width: 1, color: Color(0xff808080)),
            backgroundColor: Colors.transparent,
            fixedSize:
                Size(70.0, 70.0) * textScaleFactor,
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
            fixedSize:
                Size(70.0, 70.0) * textScaleFactor,
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

      final directory = global.kOs == "android"
          ? (await getExternalStorageDirectory())?.path
          : (await getApplicationDocumentsDirectory())?.path;
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
}

class TestWidget {
  TestWidget(this.on) {
    updateListOfWidget();
  }
  bool on = false;
  List listOfWidget = [];

  updateListOfWidget() {
    listOfWidget = List.generate(10, (i) {
      print('aa');
      return AnimatedPositioned(
          duration: Duration(seconds: 1),
          left: on ? 400 : i * 10,
          child: Container(width: 30, height: 40, color: Colors.blue));
    });
  }
}
