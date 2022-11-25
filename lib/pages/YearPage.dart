import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:lateDiary/PolarMonthIndicator.dart';
import 'package:lateDiary/CustomWidget/ZoomableWidgets.dart';
import 'package:lateDiary/StateProvider/YearPageStateProvider.dart';
import 'package:lateDiary/StateProvider/DayPageStateProvider.dart';
import 'package:lateDiary/StateProvider/NavigationIndexStateProvider.dart';
import 'package:lateDiary/Note/NoteManager.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'dart:ui';

class YearPage extends StatefulWidget {
  static String id = 'year';
  int year = DateTime.now().year;
  YearPage(this.year, {Key? key}) : super(key: key) {}

  @override
  State<YearPage> createState() => _YearPageState();
}

class _YearPageState extends State<YearPage> {
  int year = DateTime.now().year;
  List<List<dynamic>> data = [];
  FocusNode focusNode = FocusNode();
  final myTextController = TextEditingController();
  NoteManager noteManager = NoteManager();

  var heatmapChannel = StreamController<Selected?>.broadcast();
  late double availableHeight = physicalHeight -
      global.kHeightOfArbitraryWidgetOnBottom -
      global.kBottomNavigationBarHeight;

  late Map layout_yearPage = {
    'graphSize': {
      true: graphSize * global.kMagnificationOnYearPage,
      false: graphSize
    },
    'left': {
      true: -graphSize / 2 * global.kMagnificationOnYearPage -
          graphSize /
              2 *
              global.kMagnificationOnYearPage *
              (1 - global.kRatioOfScatterInYearPage),
      false: global.kMarginForYearPage
    },
    'top': {
      true: null,
      false: (physicalHeight -
                  global.kBottomNavigationBarHeight -
                  global.kHeightOfArbitraryWidgetOnBottom) *
              (global.kYPositionRatioOfGraph) -
          graphSize / 2
    }, //30 : bottom bar, 30: navigation bar, (1/3) positioned one third
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
      true: (availableHeight -
              (availableHeight * global.kYPositionRatioOfGraph +
                  graphSize / 2)) /
          2,
      false: availableHeight -
          (availableHeight * global.kYPositionRatioOfGraph + graphSize / 2)
    }
  };
  late double graphSize = physicalWidth - 2 * global.kMarginForYearPage;

  @override
  void initState() {
    print("year page create");
    heatmapChannel.stream.listen(
      (value) {
        var provider =
            Provider.of<NavigationIndexProvider>(context, listen: false);
        var yearPageStateProvider =
            Provider.of<YearPageStateProvider>(context, listen: false);

        if (value == null) return;
        if (!yearPageStateProvider.isZoomIn) return;

        DateTime date = DateTime.parse(yearPageStateProvider.availableDates
            .elementAt(int.parse(value.values.first.first.toString())));

        if (!yearPageStateProvider.isZoomIn) return;
        provider.setNavigationIndex(2);
        provider.setDate(date);
        Provider.of<DayPageStateProvider>(context, listen: false)
            .setAvailableDates(yearPageStateProvider.availableDates);
      },
    );
    super.initState();
    Provider.of<YearPageStateProvider>(context, listen: false)
        .setYear(widget.year, notify: false);
    noteManager.setNotesOfYear(widget.year);
    data = []
      ..addAll(Provider.of<YearPageStateProvider>(context, listen: false).data);
  }

  @override
  Widget build(BuildContext context) {
    print(data);
    return Consumer<YearPageStateProvider>(
      builder: (context, product, child) => Scaffold(
        body: Stack(
            alignment:
                product.isZoomIn ? Alignment.center : Alignment.topCenter,
            children: [
              ZoomableWidgets(
                      gestures: {
                    AllowMultipleGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                                AllowMultipleGestureRecognizer>(
                            () => AllowMultipleGestureRecognizer(),
                            (AllowMultipleGestureRecognizer instance) {
                      instance.onTapUp = (details) {
                        if (product.isZoomIn) return;
                        product.setZoomInState(true);
                        Offset tapPosition = calculateTapPositionRefCenter(
                            details, 0, layout_yearPage);
                        double angleZoomIn =
                            calculateTapAngle(tapPosition, 0, 0);
                        print("angle : $angleZoomIn");
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
                      "${widget.year}",
                      style: TextStyle(fontSize: 30),
                    ),
                    PolarMonthIndicators().build(context),
                    Chart(
                      data: data,
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
                          accessor: (List datum) => datum[0]+0.5 as num,  // 0.5 is added to match the tap area and dot
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
                          on: {GestureType.tap},
                          toggle: true,
                          nearest: false,
                          testRadius: product.isZoomIn ? 10 : 0,
                        )
                      },
                      coord: PolarCoord()
                        ..radiusRange = [
                          1 - global.kRatioOfScatterInYearPage,
                          1
                        ],
                      axes: [
                        Defaults.circularAxis
                          ..grid = null
                          ..label = null
                      ],
                    ),
                  ],
                      isZoomIn: product.isZoomIn,
                      layout: layout_yearPage,
                      provider: product)
                  .build(context),
              Positioned(
                  width: physicalWidth,
                  // height: 10,
                  bottom: global.kMarginOfBottomOnDayPage,
                  child: AnimatedContainer(
                      duration: Duration(milliseconds: global.animationTime),
                      curve: global.animationCurve,
                      // margin: EdgeInsets.all(10),
                      height: layout_yearPage['textHeight'][product.isZoomIn],
                      child: ListView.builder(
                          itemCount: noteManager.notesOfYear.length,
                          itemBuilder: (BuildContext buildContext, int index) {
                            String date =
                                noteManager.notesOfYear.keys.elementAt(index);
                            return MaterialButton(
                              onPressed: () {
                                var provider =
                                    Provider.of<NavigationIndexProvider>(
                                        context,
                                        listen: false);
                                var yearPageStateProvider =
                                    Provider.of<YearPageStateProvider>(context,
                                        listen: false);

                                provider.setNavigationIndex(2);
                                provider.setDate(formatDateString(date));
                                Provider.of<DayPageStateProvider>(context,
                                        listen: false)
                                    .setAvailableDates(
                                        yearPageStateProvider.availableDates);
                              },
                              // padding: EdgeInsets.all(5),
                              child: Container(
                                margin: EdgeInsets.all(5),
                                width: physicalWidth,
                                color: global
                                    .kColor_container, //Colors.black12.withAlpha(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${formateDate2(formatDateString(date))}",
                                      style: TextStyle(
                                          fontWeight:
                                              global.kFontWeight_diaryTitle,
                                          color: global.kColor_diaryText),
                                    ),
                                    Text(
                                      "${noteManager.notesOfYear[date]}",
                                      style: TextStyle(
                                          fontWeight:
                                              global.kFontWeight_diaryContents,
                                          color: global.kColor_diaryText),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }))),
            ]),

      ),
    );
  }
}
