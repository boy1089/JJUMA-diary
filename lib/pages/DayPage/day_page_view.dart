import 'package:flutter/material.dart';
import 'package:lateDiary/StateProvider/day_page_state_provider.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/pages/DayPage/polarPhotoImageContainer.dart';
import 'package:lateDiary/pages/DayPage/PolarPhotoDataPlot.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:intl/intl.dart';
import 'package:lateDiary/pages/DayPage/PolarTimeIndicators.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/CustomWidget/zoomable_widget.dart';
import 'package:lateDiary/CustomWidget/NoteEditor.dart';
import 'package:lateDiary/Util/layouts.dart';
import 'package:provider/provider.dart';

class DayPageView extends StatefulWidget {
  static String id = '/daily';
  String date;
  @override
  State<DayPageView> createState() => _DayPageViewState(date: date);

  DayPageView(this.date, {Key? key}) : super(key: key);
}

class _DayPageViewState extends State<DayPageView> {
  String date;
  bool isZoomIn = false;
  Future readData = Future.delayed(const Duration(seconds: 1));
  FocusNode focusNode = FocusNode();
  final myTextController = TextEditingController();
  var product;

  _DayPageViewState({required this.date});

  @override
  void initState() {
    super.initState();
    date = widget.date;
    product = Provider.of<DayPageStateProvider>(context, listen: false);
    product.setDate(date);
    readData = _fetchData();
  }

  Future<List<dynamic>> _fetchData() async {
    await product.updateDataForUi();
    myTextController.text = product.note;
    //implement class day_page_view_model
    return product.photoForPlot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          alignment:
              product.isZoomIn ? Alignment.center : Alignment.bottomCenter,
          children: [
            NoteEditor(layout_dayPage, focusNode, product, myTextController)
                .build(context),
            FutureBuilder(
                future: readData,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return ZoomableWidgets(
                      layout: layout_dayPage,
                      isZoomIn: product.isZoomIn,
                      angle : product.angle,
                      gestures: gestures(),
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
          if (focusNode.hasFocus) {
            dismissKeyboard(product);
          } else {
            showKeyboard();
          }
          setState(() {});
        },
        child: focusNode.hasFocus ? const Text("save") : const Icon(Icons.edit),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  gestures() {
    return {
      AllowMultipleGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<AllowMultipleGestureRecognizer>(
              () => AllowMultipleGestureRecognizer(),
              (AllowMultipleGestureRecognizer instance) {
        instance.onTapUp = (details) => onTap(details, context, product);
      }),
      AllowMultipleGestureRecognizer2:
          GestureRecognizerFactoryWithHandlers<AllowMultipleGestureRecognizer2>(
        () => AllowMultipleGestureRecognizer2(),
        (AllowMultipleGestureRecognizer2 instance) {
          instance.onUpdate = (details) => onPan(details, context, product);
        },
      )
    };
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
