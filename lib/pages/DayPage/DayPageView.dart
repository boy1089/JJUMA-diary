import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/pages/DayPage/polarPhotoImageContainer.dart';
import 'package:lateDiary/pages/DayPage/PolarPhotoDataPlot.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:intl/intl.dart';
import 'package:lateDiary/pages/DayPage/PolarTimeIndicators.dart';
import 'package:lateDiary/Util/DateHandler.dart';

import 'package:lateDiary/CustomWidget/ZoomableWidgets.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';

import 'package:lateDiary/StateProvider/DayPageStateProvider.dart';
import 'package:lateDiary/StateProvider/NavigationIndexStateProvider.dart';

import 'package:lateDiary/CustomWidget/NoteEditor.dart';
import 'dart:ui';
import 'package:lateDiary/Util/layouts.dart';

class DayPageView extends StatefulWidget {
  static String id = '/daily';
  String date = formatDate(DateTime.now());

  @override
  State<DayPageView> createState() => _DayPageViewState();

  DayPageView(this.date, {Key? key}) : super(key: key);
}

class _DayPageViewState extends State<DayPageView> {
  String date = formatDate(DateTime.now());
  Future readData = Future.delayed(const Duration(seconds: 1));

  FocusNode focusNode = FocusNode();
  final myTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    date = widget.date;
    Provider.of<DayPageStateProvider>(context, listen: false).setDate(date);
    Provider.of<NavigationIndexProvider>(context, listen: false)
        .setDate(formatDateString(date));
    readData = _fetchData();
  }

  Future<List<dynamic>> _fetchData() async {
    var provider = Provider.of<DayPageStateProvider>(context, listen: false);
    await provider.updateDataForUi();
    myTextController.text = provider.note;
    return provider.photoForPlot;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DayPageStateProvider>(builder: (context, product, child) {
      return Scaffold(
        backgroundColor: global.kBackGroundColor,
        body: Stack(
            alignment:
                product.isZoomIn ? Alignment.center : Alignment.bottomCenter,
            children: [
              FutureBuilder(
                  future: readData,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return ZoomableWidgets(
                        layout: layout_dayPage,
                        isZoomIn: product.isZoomIn,
                        provider: product,
                        gestures: {
                          AllowMultipleGestureRecognizer:
                              GestureRecognizerFactoryWithHandlers<
                                      AllowMultipleGestureRecognizer>(
                                  () => AllowMultipleGestureRecognizer(),
                                  (AllowMultipleGestureRecognizer instance) {
                            instance.onTapUp =
                                (details) => onTap(details, context, product);
                          }),
                          AllowMultipleGestureRecognizer2:
                              GestureRecognizerFactoryWithHandlers<
                                  AllowMultipleGestureRecognizer2>(
                            () => AllowMultipleGestureRecognizer2(),
                            (AllowMultipleGestureRecognizer2 instance) {
                              instance.onUpdate =
                                  (details) => onPan(details, context, product);
                            },
                          )
                        },
                        widgets: [
                          PolarTimeIndicators(
                                  product.photoForPlot, product.addresses)
                              .build(context),
                          PolarPhotoDataPlot(product.photoDataForPlot)
                              .build(context),
                          polarPhotoImageContainers(product.photoForPlot)
                              .build(context),
                        ]).build(context);
                  }),
              NoteEditor(layout_dayPage, focusNode, product, myTextController)
                  .build(context),
              Positioned(
                  top: 30,
                  child: Text(
                    "${DateFormat('EEEE').format(DateTime.parse(date))}/"
                    "${DateFormat('MMM').format(DateTime.parse(date))} "
                    "${DateFormat('dd').format(DateTime.parse(date))}/"
                    "${DateFormat('yyyy').format(DateTime.parse(date))}",
                    style: TextStyle(
                        fontSize: 20, color: global.kColor_backgroundText),
                  )),
            ]),
        floatingActionButton: FloatingActionButton(
          mini: true,
          backgroundColor: global.kMainColor_warm,
          child: focusNode.hasFocus ? Text("save") : Icon(Icons.add),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          onPressed: () {
            if (focusNode.hasFocus) {
              dismissKeyboard(product);
            } else {
              showKeyboard();
            }
            setState(() {});
          },
        ),
        resizeToAvoidBottomInset: false,
      );
    });
  }

  void onTap(details, context, product) {
    if (!global.isImageClicked) global.indexForZoomInImage = -1;
    global.isImageClicked = false;
    setState(() {});

    if (product.isZoomIn) return;
    if (focusNode.hasFocus) {
      dismissKeyboard(product);
      setState(() {});
      return;
    }

    Offset tapPosition =
        calculateTapPositionRefCenter(details, 0, layout_dayPage);
    double angleZoomIn = calculateTapAngle(tapPosition, 0, 0);
    product.setZoomInRotationAngle(angleZoomIn);

    product.setZoomInState(true);
    product.setIsZoomInImageVisible(true);
    product.setZoomInRotationAngle(angleZoomIn);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void onPan(details, context, product) {
    if (!product.isZoomIn) return;
    product.setZoomInRotationAngle(
        product.isZoomIn ? product.zoomInAngle + details.delta.dy / 1000 : 0);
  }

  @override
  void dispose() {
    print("dispose..");
    focusNode.dispose();
    super.dispose();
  }

  void showKeyboard() {
    focusNode.requestFocus();
    setState(() {});
  }

  void dismissKeyboard(product) async {
    product.setNote(myTextController.text);
    focusNode.unfocus();
    await product.writeNote();
  }
}
