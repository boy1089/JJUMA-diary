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

class DayPage extends StatefulWidget {
  String date = formatDate(DateTime.now());
  @override
  State<DayPage> createState() => _DayPageState();

  DayPage(date, {Key? key}) : super(key: key);
}

class _DayPageState extends State<DayPage> {
  String date = formatDate(DateTime.now());
  Future readData = Future.delayed(const Duration(seconds: 1));

  FocusNode focusNode = FocusNode();
  final myTextController = TextEditingController();
  List files = [];

  @override
  void initState() {
    super.initState();
    date = widget.date;
    Provider.of<DayPageStateProvider>(context, listen: false).setDate(date);
    readData = _fetchData();
  }

  Future<List<dynamic>> _fetchData() async {
    var provider = Provider.of<DayPageStateProvider>(context, listen: false);
    await provider.updateDataForUi();
    myTextController.text = provider.note;
    print("fetchData done, ${provider.photoDataForPlot}");
    await Future.delayed(Duration(seconds: 1));
    return provider.photoDataForPlot;
  }

  bool isZoomInImageVisible = false;

  late double graphSize = physicalWidth - global.kMarginForDayPage * 2;

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
          global.kImageSize,
      false: physicalHeight -
          graphSize -
          ((physicalHeight -
                      global.kBottomNavigationBarHeight -
                      global.kHeightOfArbitraryWidgetOnBottom) *
                  (global.kYPositionRatioOfGraph) -
              graphSize / 2) -
          global.kImageSize * 2 / 3
    }
  };
  double firstContainerSize = 1000;

  void showKeyboard() {
    focusNode.requestFocus();
    setState(() {});
  }

  void dismissKeyboard(product) async {
    focusNode.unfocus();
    await product.writeNote(date);
  }

  @override
  Widget build(BuildContext context) {
    print("building DayPage..");

    return Consumer<DayPageStateProvider>(
        builder: (context, product, child) => FutureBuilder(
            future: readData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              print("snapshot : ${snapshot.data}. ${snapshot.hasData}");
              return Scaffold(
                backgroundColor: global.kBackGroundColor,
                body: (!snapshot.hasData)
                    ? Center(
                        child: SizedBox(
                            width: global.kSizeOfProgressIndicator,
                            height: global.kSizeOfProgressIndicator,
                            child: CircularProgressIndicator(
                              strokeWidth:
                                  global.kStrokeWidthOfProgressIndicator,
                            )))
                    : RawGestureDetector(
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
                              Offset tapPosition =
                                  calculateTapPositionRefCenter(
                                      details, 0, layout_dayPage);
                              double angleZoomIn =
                                  calculateTapAngle(tapPosition, 0, 0);
                              product.setZoomInRotationAngle(angleZoomIn);

                              if (details.globalPosition.dy >
                                  physicalHeight -
                                      layout_dayPage['textHeight'][false] -
                                      60) return;
                              //if editing text, doesn't zoom in.
                              if (focusNode.hasFocus) {
                                print("has focus? ${focusNode.hasFocus}");
                                dismissKeyboard(product);
                                setState(() {});
                                return;
                              }
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
                                    ? product.zoomInAngle +
                                        details.delta.dy / 1000
                                    : 0);
                              };
                            },
                          )
                        },
                        child: Stack(
                            alignment: product.isZoomIn
                                ? Alignment.center
                                : Alignment.topCenter,
                            children: [
                              ZoomableWidgets(
                                      widgets: [
                                    PolarTimeIndicators(product.photoForPlot,
                                            product.addresses)
                                        .build(context),
                                    PolarSensorDataPlot((product
                                                        .sensorDataForPlot[0]
                                                        .length ==
                                                    0) |
                                                (product.sensorDataForPlot
                                                        .length ==
                                                    0)
                                            ? global.dummyData1
                                            : product.sensorDataForPlot)
                                        .build(context),
                                    PolarPhotoDataPlot(product.photoDataForPlot)
                                        .build(context),
                                    polarPhotoImageContainers(
                                            product.photoForPlot)
                                        .build(context),
                                  ],
                                      layout: layout_dayPage,
                                      isZoomIn: product.isZoomIn,
                                      provider: product)
                                  .build(context),
                              KeyboardVisibilityBuilder(
                                  builder: (context, isKeyboardVisible) {
                                print("isKeyboardVisible : $isKeyboardVisible");
                                print(MediaQuery.of(context).viewInsets.top -
                                    100);
                                return Positioned(
                                  width: physicalWidth,
                                  height: isKeyboardVisible
                                      ? physicalHeight - 200 - 200
                                      : layout_dayPage['textHeight'][false],
                                  bottom: global.kMarginOfBottomOnDayPage,
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    // height: !focusNode.hasFocus
                                    //     ? physicalHeight / 2 - 200
                                    //     : physicalHeight / 2 - 200,
                                    color: focusNode.hasFocus
                                        ? global.kColor_containerFocused
                                        : global.kColor_container,
                                    child: EditableText(
                                      // readOnly: isZoomIn ? true : false,
                                      maxLines: 15,
                                      controller: myTextController,
                                      onSelectionChanged: (a, b) {
                                        if (!focusNode.hasFocus)
                                          setState(() {});
                                      },

                                      onEditingComplete: () {
                                        print("editing completed");
                                        dismissKeyboard(product);
                                      },

                                      focusNode: focusNode,
                                      style: TextStyle(
                                          color: global.kColor_diaryText),
                                      cursorColor: Colors.black12,
                                      backgroundCursorColor: Colors.black12,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                );
                              }),
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
                    if (focusNode.hasFocus) {
                      dismissKeyboard(product);
                    } else {
                      showKeyboard();
                    }
                    ;
                    setState(() {});
                  },
                ),
              );
            }));
  }

  @override
  void dispose() {
    print("dispose..");
    focusNode.dispose();
    super.dispose();
  }
}
