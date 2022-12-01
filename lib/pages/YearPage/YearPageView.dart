import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:lateDiary/Data/DataManagerInterface.dart';
import 'package:lateDiary/Data/DataRepository.dart';
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

  YearPageView(int year, product, context) {
    this.year = year;
    this.product = product;
    this.context = context;
    initState();
  }

  void initState() {
    addListenerToChart();
    product.setYear(year, notify: false);
    noteManager.setNotesOfYear(year);
  }

  void addListenerToChart() {
    heatmapChannel.stream.listen(
      (value) {
        var provider =
            Provider.of<NavigationIndexProvider>(context, listen: false);

        if (value == null) return;
        if (!product.isZoomIn) return;

        DateTime date = DateTime.parse(product.availableDates
            .elementAt(int.parse(value.values.first.first.toString())));

        if (!product.isZoomIn) return;
        provider.setNavigationIndex(navigationIndex.day);
        provider.setDate(date);
        Provider.of<DayPageStateProvider>(context, listen: false)
            .setAvailableDates(product.availableDates);
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
          var c = DataRepository();
          var a = DataManagerInterface(global.kOs);
          // await c.writeInfoAsJson(a.infoFromFiles, true);
          a.filesNotUpdated = a.infoFromFiles.keys.toList();
          a.executeSlowProcesses();

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
        'choose': PointSelection(
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
