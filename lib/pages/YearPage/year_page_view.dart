import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:lateDiary/Data/data_manager_interface.dart';
import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/pages/DayPage/widgets/clickable_photo_card.dart';
import 'package:lateDiary/pages/DayPage/widgets/photo_card.dart';
import 'package:lateDiary/pages/YearPage/year_page_chart.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/pages/YearPage/polar_month_indicator.dart';
import 'package:lateDiary/CustomWidget/zoomable_widget.dart';
import 'package:lateDiary/Note/note_manager.dart';
import 'dart:ui';
import 'package:lateDiary/Util/layouts.dart';
import 'note_list_view.dart';

class YearPageView extends StatelessWidget {
  static String id = 'year';

  int year;
  dynamic dataForChart;
  double angle = 0.0;
  bool isZoomIn = false;
  BuildContext context;
  Map<String, String> notes = {};

  YearPageView(
      {required this.year,
      required this.dataForChart,
      required this.isZoomIn,
      required this.angle,
      required this.context}) {
    initState();
  }

  void initState() {
    NoteManager noteManager = NoteManager();
    noteManager.setNotesOfYear(year);
    notes = noteManager.notesOfYear;
  }

  @override
  Widget build(BuildContext context) {
    YearPageStateProvider product =
        Provider.of<YearPageStateProvider>(context, listen: false);

    return Scaffold(
      body: Stack(
          alignment: isZoomIn ? Alignment.center : Alignment.topCenter,
          children: [
            ZoomableWidgets(
                    gestures: gestures(),
                    widgets: [
                      Text(
                        "${year}",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      PolarMonthIndicators().build(context),
                      YearPageChart(
                        dataForChart: dataForChart,
                        isZoomIn: isZoomIn,
                        context: context,
                      ).build(context),
                      // Positioned(
                      //   left : 50,
                      //   top : 100,
                      //   child: PhotoCard(
                      //     height : 30,
                      //       event: DataManagerInterface(global.kOs)
                      //           .eventList
                      //           .entries
                      //           .elementAt(0)
                      //           .value),
                      // ),
                      // Positioned(
                      //   left: isZoomIn
                      //       ? 55 * global.kMagnificationOnYearPage
                      //       : 55,
                      //   top: isZoomIn
                      //       ? 125 * global.kMagnificationOnYearPage
                      //       : 125,
                      //   child: Transform.rotate(
                      //     angle: isZoomIn ? pi + pi / 6 : 0,
                      //     child: PhotoCard(
                      //         height: isZoomIn ? 120 : 50,
                      //         event: DataManagerInterface(global.kOs)
                      //             .eventList
                      //             .entries
                      //             .elementAt(0)
                      //             .value),
                      //   ),
                      // ),
                      // Positioned(
                      //   left: isZoomIn
                      //       ? 85 * global.kMagnificationOnYearPage
                      //       : 85,
                      //   top: isZoomIn
                      //       ? 205 * global.kMagnificationOnYearPage
                      //       : 205,
                      //   child: Transform.rotate(
                      //     angle: isZoomIn ? pi + pi / 10 : 0,
                      //     child: ClickablePhotoCard(
                      //       photoCard: PhotoCard(
                      //           height: isZoomIn ? 120 : 50,
                      //           event: DataManagerInterface(global.kOs)
                      //               .eventList
                      //               .entries
                      //               .elementAt(1)
                      //               .value),
                      //     ),
                      //   ),
                      // ),
                    ],
                    isZoomIn: isZoomIn,
                    layout: layout_yearPage,
                    angle: angle)
                .build(context),
          ]),
      // floatingActionButtonLocation: FloatingActionButtonLocation,
      floatingActionButton: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 100,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: global
                    .kColorForYearPage[product.importanceFilterIndex * 2]
                    .withAlpha(150)),
            child: FloatingActionButton(
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Text(
                    "${ImportanceFilter.values.elementAt(product.importanceFilterIndex).name}"),
                onPressed: () {
                  YearPageStateProvider product =
                      Provider.of<YearPageStateProvider>(context,
                          listen: false);
                  product.setImportanceFilter(
                      (product.importanceFilterIndex + 1) %
                          ImportanceFilter.values.length);
                }),
          ),
        ),
        SizedBox(height: 8.0),
        Container(
          width: 100,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: global.kColorForYearPage[product.locationFilterIndex * 2]
                    .withAlpha(150)
                // RoundedRectangleBorder(
                //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
            child: FloatingActionButton(
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Text(
                    "${LocationFilter.values.elementAt(product.locationFilterIndex).name}"),
                onPressed: () {
                  YearPageStateProvider product =
                      Provider.of<YearPageStateProvider>(context,
                          listen: false);
                  product.setLocationFilter((product.locationFilterIndex + 1) %
                      ImportanceFilter.values.length);
                }),
          ),
        ),
      ]),
    );
  }

  gestures() {
    YearPageStateProvider product =
        Provider.of<YearPageStateProvider>(context, listen: false);
    return {
      AllowMultipleGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<AllowMultipleGestureRecognizer>(
              () => AllowMultipleGestureRecognizer(),
              (AllowMultipleGestureRecognizer instance) {
        instance.onTapUp = (details) {
          if (isZoomIn) return;
          product.setZoomInState(true);
          Offset tapPosition =
              calculateTapPositionRefCenter(details, 0, layout_yearPage);
          double angleZoomIn = calculateTapAngle(tapPosition, 0, 0);
          product.setZoomInRotationAngle(angleZoomIn);
        };
      }),
      AllowMultipleGestureRecognizer2:
          GestureRecognizerFactoryWithHandlers<AllowMultipleGestureRecognizer2>(
        () => AllowMultipleGestureRecognizer2(),
        (AllowMultipleGestureRecognizer2 instance) {
          instance.onUpdate = (details) {
            if (!isZoomIn) return;
            product.setZoomInRotationAngle(angle + details.delta.dy / 400);
          };
        },
      )
    };
  }

  @override
  void dispose() {
    print("yearPageView disposed");
  }
}
