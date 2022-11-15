import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/PolarSensorDataPlot.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/polarPhotoImageContainer.dart';
import 'package:test_location_2nd/PolarPhotoDataPlot.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:intl/intl.dart';
import 'package:test_location_2nd/PolarTimeIndicators.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';

import 'package:test_location_2nd/CustomWidget/ZoomableWidgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';

import 'package:test_location_2nd/StateProvider/DayPageStateProvider.dart';
import 'package:test_location_2nd/StateProvider/NavigationIndexStateProvider.dart';

import 'package:test_location_2nd/CustomWidget/NoteEditor.dart';

import 'dart:ui';

class DayPage extends StatefulWidget {
  String date = formatDate(DateTime.now());
  @override
  State<DayPage> createState() => _DayPageState();

  DayPage(this.date, {Key? key}) : super(key: key);
}

class _DayPageState extends State<DayPage> {
  String date = formatDate(DateTime.now());
  Future readData = Future.delayed(const Duration(seconds: 1));
  List photoForPlot = [];
  dynamic photoData = [[]];
  dynamic sensorDataForPlot = [[]];
  List<List<dynamic>> photoDataForPlot = [[]];
  Map<int, String?> addresses = {};
  String note = "";

  FocusNode focusNode = FocusNode();
  final myTextController = TextEditingController();
  List files = [];

  @override
  void initState() {
    super.initState();
    date = widget.date;
    Provider.of<DayPageStateProvider>(context, listen: false).setDate(date);
    Provider.of<NavigationIndexProvider>(context, listen: false)
        .setDate(formatDateString(date));
    print("dayPAge");
    readData = _fetchData();
  }

  Future<List<dynamic>> _fetchData() async {
    var provider = Provider.of<DayPageStateProvider>(context, listen: false);
    await provider.updateDataForUi();

    myTextController.text = note;
    print("fetchData done, ${provider.photoForPlot}");

    photoForPlot = []..addAll(provider.photoForPlot);
    photoData = []..addAll(provider.photoData);
    sensorDataForPlot = []..addAll(provider.sensorDataForPlot);
    photoDataForPlot = []..addAll(provider.photoDataForPlot);
    addresses = {}..addAll(provider.addresses);

    return provider.photoForPlot;
  }

  bool isZoomInImageVisible = false;

  late double graphSize = physicalWidth - global.kMarginForDayPage * 2;
  late double availableHeight = physicalHeight -
      global.kHeightOfArbitraryWidgetOnBottom -
      global.kBottomNavigationBarHeight;
  //layout for zoomIn and zoomOut state
  late Map layout_dayPage = {
    'graphSize': {
      true: graphSize * global.kMagnificationOnDayPage,
      false: graphSize
    },
    // 'left': {true: -graphSize * 5.5, false: (physicalWidth - graphSize) / 2},
    'left': {
      true:
          -graphSize * (global.kMagnificationOnDayPage / 2) * (1 + (1 - 0.43)),
      false: global.kMarginForDayPage
    },
    'top': {
      true: null,
      false: (physicalHeight -
                  global.kBottomNavigationBarHeight -
                  global.kHeightOfArbitraryWidgetOnBottom) *
              (global.kYPositionRatioOfGraph) -
          graphSize / 2
    },
    'graphCenter': {
      true: null,
      false: Offset(
          physicalWidth / 2,
          (physicalHeight -
                  global.kBottomNavigationBarHeight -
                  global.kHeightOfArbitraryWidgetOnBottom) *
              (global.kYPositionRatioOfGraph))
    },

    'textHeight': {
      true: physicalHeight -
          graphSize -
          (physicalHeight -
                  global.kBottomNavigationBarHeight -
                  global.kHeightOfArbitraryWidgetOnBottom) *
              (global.kYPositionRatioOfGraph) -
          global.kImageSize +
          100,
      false: availableHeight -
          (availableHeight * global.kYPositionRatioOfGraph + graphSize / 2)
    }
  };
  double firstContainerSize = 1000;
  final viewInsets = EdgeInsets.fromWindowPadding(WidgetsBinding.instance.window.viewInsets,WidgetsBinding.instance.window.devicePixelRatio);
  late double kKeyboardHeight = viewInsets.bottom;

  void showKeyboard() {
    focusNode.requestFocus();
    setState(() {});
  }

  void dismissKeyboard(product) async {
    product.setNote(myTextController.text);
    focusNode.unfocus();
    await product.writeNote();
  }

  @override
  Widget build(BuildContext context) {
    print("building DayPage..");


    return Consumer<DayPageStateProvider>(
        builder: (context, product, child) => Scaffold(
              backgroundColor: global.kBackGroundColor,
              body: RawGestureDetector(
                behavior: HitTestBehavior.deferToChild,
                gestures: {
                  AllowMultipleGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                              AllowMultipleGestureRecognizer>(
                          () => AllowMultipleGestureRecognizer(),
                          (AllowMultipleGestureRecognizer instance) {
                    instance.onTapUp = (details) {
                      //action expected
                      //1. if not zoom in
                      //1-1. if image is clicked, then zoom in that location (angle)
                      //1-2. if note is clicked. focus on the editable text
                      //1-3 if image is clicked, when note is focused, dismiss the focus

                      //2. if zoom in
                      //2-1 if image is clicked enlarge the image
                      //2-2 if image is not clicked, dismiss the enlarged image
                      //2-3 if text is clicked, focus on the editable text
                      //2-4 if text is not clicked when note is focused, dismiss the focus

                      if (!global.isImageClicked)
                        global.indexForZoomInImage = -1;
                      global.isImageClicked = false;
                      setState(() {});

                      if (product.isZoomIn) return;
                      //if editing text, doesn't zoom in.
                      if (focusNode.hasFocus) {
                        print("has focus? ${focusNode.hasFocus}");
                        dismissKeyboard(product);
                        setState(() {});
                        return;
                      }

                      Offset tapPosition = calculateTapPositionRefCenter(
                          details, 0, layout_dayPage);
                      double angleZoomIn = calculateTapAngle(tapPosition, 0, 0);
                      product.setZoomInRotationAngle(angleZoomIn);

                      if (details.globalPosition.dy >
                          physicalHeight -
                              layout_dayPage['textHeight'][false] -
                              60) return;

                      product.setZoomInState(true);
                      product.setIsZoomInImageVisible(true);
                      product.setZoomInRotationAngle(angleZoomIn);
                      FocusManager.instance.primaryFocus?.unfocus();
                    };
                  }),
                  AllowMultipleGestureRecognizer2:
                      GestureRecognizerFactoryWithHandlers<
                          AllowMultipleGestureRecognizer2>(
                    () => AllowMultipleGestureRecognizer2(),
                    (AllowMultipleGestureRecognizer2 instance) {
                      instance.onUpdate = (details) {
                        if (!product.isZoomIn) return;
                        product.setZoomInRotationAngle(product.isZoomIn
                            ? product.zoomInAngle + details.delta.dy / 1000
                            : 0);
                      };
                    },
                  )
                },
                child: Stack(
                    alignment: product.isZoomIn
                        ? Alignment.center
                        : Alignment.bottomCenter,
                    children: [
                      FutureBuilder(
                          future: readData,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            return ZoomableWidgets(
                                    widgets: [
                                  PolarTimeIndicators(photoForPlot, addresses)
                                      .build(context),
                                  PolarSensorDataPlot(
                                          (sensorDataForPlot[0].length == 0) |
                                                  (sensorDataForPlot.length ==
                                                      0)
                                              ? global.dummyData1
                                              : sensorDataForPlot)
                                      .build(context),
                                  PolarPhotoDataPlot(photoDataForPlot)
                                      .build(context),
                                  polarPhotoImageContainers(photoForPlot)
                                      .build(context),
                                ],
                                    layout: layout_dayPage,
                                    isZoomIn: product.isZoomIn,
                                    provider: product)
                                .build(context);
                          }),
                      NoteEditor(layout_dayPage, focusNode, product,
                              myTextController)
                          .build(context),
                      Positioned(
                          top: 30,
                          child: Text(
                            "${DateFormat('EEEE').format(DateTime.parse(date))}/"
                            "${DateFormat('MMM').format(DateTime.parse(date))} "
                            "${DateFormat('dd').format(DateTime.parse(date))}/"
                            "${DateFormat('yyyy').format(DateTime.parse(date))}",
                            style: TextStyle(
                                fontSize: 20,
                                color: global.kColor_backgroundText),
                          )),
                    ]),
              ),
              floatingActionButton: FloatingActionButton(
                mini: true,
                backgroundColor: global.kMainColor_warm,
                child: focusNode.hasFocus ? Text("save") : Icon(Icons.add),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                onPressed: () {
                  double kKeyboardHeight = double.parse(viewInsets.bottom.toString()
                  );
                  print("keyboard : $kKeyboardHeight");
                },
              ),
          resizeToAvoidBottomInset: false,

        ));
  }


  @override
  void dispose() {
    print("dispose..");
    focusNode.dispose();
    super.dispose();
  }

}
