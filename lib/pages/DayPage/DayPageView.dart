import 'package:flutter/material.dart';
import 'package:lateDiary/Data/DataManagerInterface.dart';
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
import 'package:lateDiary/Util/layouts.dart';

class DayPageView extends StatefulWidget {
  static String id = '/daily';
  String date = formatDate(DateTime.now());
  var product;
  @override
  State<DayPageView> createState() => _DayPageViewState();

  DayPageView(this.date, this.product, {Key? key}) : super(key: key);
}

class _DayPageViewState extends State<DayPageView> {
  String date = formatDate(DateTime.now());
  Future readData = Future.delayed(const Duration(seconds: 1));
  FocusNode focusNode = FocusNode();
  final myTextController = TextEditingController();
  var product;
  // late var context;

  @override
  void initState() {
    super.initState();
    date = widget.date;
    product = widget.product;
    product.setDate(date);
    readData = _fetchData();
  }

  Future<List<dynamic>> _fetchData() async {
    await product.updateDataForUi();
    myTextController.text = product.note;
    return product.photoForPlot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    style: Theme.of(context).textTheme.headline3)),
          ]),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: global.kMainColor_warm,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        onPressed: () async {
          // await product.updatePhotoData();
          // print(product.photoData);
          // var a = DataManagerInterface(global.kOs);
          // a.notifyListeners();
          if (focusNode.hasFocus) {
            dismissKeyboard(product);
          } else {
            showKeyboard();
          }
          setState(() {});
        },
        child: focusNode.hasFocus ? const Text("save") : const Icon(Icons.add),
      ),
      resizeToAvoidBottomInset: false,
    );
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
    print("DayPageView disposed..");
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
