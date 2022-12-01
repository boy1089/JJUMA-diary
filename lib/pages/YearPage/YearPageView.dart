import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:graphic/graphic.dart';
import 'package:lateDiary/Data/DataManagerInterface.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:lateDiary/pages/YearPage/PolarMonthIndicator.dart';
import 'package:lateDiary/CustomWidget/ZoomableWidgets.dart';
import 'package:lateDiary/StateProvider/DayPageStateProvider.dart';
import 'package:lateDiary/StateProvider/NavigationIndexStateProvider.dart';
import 'package:lateDiary/Note/NoteManager.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'dart:ui';
import 'package:lateDiary/Util/layouts.dart';

class YearPageView extends StatelessWidget {
  static String id = 'year';

  int year = DateTime.now().year;
  var product;
  var context;
  NoteManager noteManager = NoteManager();
  FocusNode focusNode = FocusNode();
  final myTextController = TextEditingController();

  var heatmapChannel = StreamController<Selected?>.broadcast();
  bool isHeatMapChannelListening = false;
  YearPageView(int year, product, context) {
    this.year = year;
    this.product = product;
    this.context = context;
    initState();
  }

  void initState() {
    if(!isHeatMapChannelListening)
      addListenerToChart();
    product.setYear(year, notify: false);
    noteManager.setNotesOfYear(year);
  }

  void addListenerToChart() {
    isHeatMapChannelListening = true;
    heatmapChannel.stream.listen(
      (value) async {


        if (value == null) return;
        if (!product.isZoomIn) return;
        var provider =
        Provider.of<NavigationIndexProvider>(context, listen: false);

        switch (value.keys.elementAt(0)){
          case "tapDown":
            break;
          case 'tapUp':
            DateTime date = DateTime.parse(product.availableDates
                .elementAt(int.parse(value.values.first.first.toString())));
            if (!product.isZoomIn) return;
            provider.setNavigationIndex(navigationIndex.day);

            provider.setDate(date);
            Provider.of<DayPageStateProvider>(context, listen: false)
                .setAvailableDates(product.availableDates);

            break;
        }

      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          alignment: product.isZoomIn ? Alignment.center : Alignment.topCenter,
          children: [
            ZoomableWidgets(
                    gestures: {
                  AllowMultipleGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                              AllowMultipleGestureRecognizer>(
                          () => AllowMultipleGestureRecognizer(),
                          (AllowMultipleGestureRecognizer instance) {
                    print(instance.state);
                    instance.onTapUp = (details) {
                      if (product.isZoomIn) return;
                      product.setZoomInState(true);
                      Offset tapPosition = calculateTapPositionRefCenter(
                          details, 0, layout_yearPage);
                      double angleZoomIn = calculateTapAngle(tapPosition, 0, 0);
                      product.setZoomInRotationAngle(angleZoomIn);
                    };
                  }),
                  AllowMultipleGestureRecognizer2:
                      GestureRecognizerFactoryWithHandlers<
                          AllowMultipleGestureRecognizer2>(
                    () => AllowMultipleGestureRecognizer2(),
                    (AllowMultipleGestureRecognizer2 instance) {
                      instance.onUpdate = (details) {
                        if (!product.isZoomIn) return;
                        product.setZoomInRotationAngle(
                            product.zoomInAngle + details.delta.dy / 400);
                      };
                    },
                  )
                },
                    widgets: [
                  Text(
                    "${year}",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  PolarMonthIndicators().build(context),
                  YearPageChart(product, heatmapChannel).build(context)
                ],
                    isZoomIn: product.isZoomIn,
                    layout: layout_yearPage,
                    provider: product)
                .build(context),
            Positioned(
                width: physicalWidth,
                bottom: global.kMarginOfBottomOnDayPage,
                child: NoteListView(product, noteManager).build(context)),
          ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // var c = DataRepository();
          // c.writeInfoAsJson({}, true);
          // await c.writeSummaryOfLocation(
          //     {}, true, []);
          // var summaryOfPhoto = await c.readSummaryOfPhoto();
          // print(summaryOfPhoto);
          // var summaryOfLocation = await c.readSummaryOfLocation();
          //
          var a = DataManagerInterface(global.kOs);
          print(product.data);
        },
      ),
    );
  }

  @override
  void dispose() {
    print("yearPageView disposed");
  }
}

class YearPageChart {
  var product;
  var heatmapChannel;
  YearPageChart(this.product, this.heatmapChannel);

  @override
  Widget build(BuildContext context) {
    return Chart(
      data: product.data,
      elements: [
        PointElement(
          position: Varset('week') * (Varset('day')),
          size: SizeAttr(
            variable: 'value',
            values: !product.isZoomIn
                ? [
                    global.kSizeOfScatter_ZoomOutMin,
                    global.kSizeOfScatter_ZoomOutMax
                  ]
                : [
                    global.kSizeOfScatter_ZoomInMin,
                    global.kSizeOfScatter_ZoomInMax
                  ],
          ),
          color: ColorAttr(
            encoder: (tuple) => global
                .kColorForYearPage[tuple['distance'].toInt()]
                .withAlpha((50 + tuple['value']).toInt()),
            updaters: {
              'tapDown': {true: (color) => color.withAlpha(150)},
              'tapUp': {true: (color) => color.withAlpha(150)}

              },
            ),
            selectionChannel: heatmapChannel,
          ),
        ],
        variables: {
          'week': Variable(
            accessor: (List datum) => datum[0] + 0.5
                as num, // 0.5 is added to match the tap area and dot
            scale: LinearScale(min: 0, max: 52, tickCount: 12),
          ),
          'day': Variable(
            accessor: (List datum) => datum[1] as num,
          ),
          'value': Variable(
            accessor: (List datum) => datum[2] as num,
          ),
          'distance': Variable(
            accessor: (List datum) =>
                // math.log(datum[3]) + 0.1 as num,
                datum[3] as num,
          ),
        },
        selections: {
          'tapDown': PointSelection(
            on: {GestureType.tapDown},
            toggle: true,
            nearest: false,
            testRadius: product.isZoomIn ? 10 : 0,),

          'tapUp': PointSelection(
          on: {GestureType.tapUp},
            toggle: true,
            nearest: false,
            testRadius: product.isZoomIn ? 10 : 0,
          )
        },
        coord: PolarCoord()
          ..radiusRange = [1 - global.kRatioOfScatterInYearPage, 1],
        axes: [
          Defaults.circularAxis
            ..grid = null
            ..label = null
        ],
      );
  }
}

class NoteListView {
  var product;
  var noteManager;
  NoteListView(this.product, this.noteManager);
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: Duration(milliseconds: global.animationTime),
        curve: global.animationCurve,
        height: layout_yearPage['textHeight'][product.isZoomIn],
        child: ListView.builder(
            itemCount: noteManager.notesOfYear.length,
            itemBuilder: (BuildContext buildContext, int index) {
              String date = noteManager.notesOfYear.keys.elementAt(index);
              return MaterialButton(
                onPressed: () {
                  var provider = Provider.of<NavigationIndexProvider>(context,
                      listen: false);
                  provider.setNavigationIndex(navigationIndex.day);
                  provider.setDate(formatDateString(date));
                  Provider.of<DayPageStateProvider>(context, listen: false)
                      .setAvailableDates(product.availableDates);
                },
                child: Container(
                  margin: EdgeInsets.all(5),
                  width: physicalWidth,
                  color: global.kColor_container,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${formateDate2(formatDateString(date))}",
                          style: Theme.of(context).textTheme.subtitle1),
                      Text("${noteManager.notesOfYear[date]}",
                          style: Theme.of(context).textTheme.bodyText1)
                    ],
                  ),
                ),
              );
            }));
  }
}
