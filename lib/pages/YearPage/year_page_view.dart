import 'package:flutter/material.dart';
import 'package:lateDiary/Data/data_manager_interface.dart';
import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/Util/global.dart' as global;
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
                      ).build(context)
                    ],
                    isZoomIn: isZoomIn,
                    layout: layout_yearPage,
                    angle : angle)
                .build(context),
            // Positioned(
            //     width: physicalWidth,
            //     bottom: global.kMarginOfBottomOnDayPage,
            //     child: NoteListView(isZoomIn: isZoomIn, notes: notes)
            //         .build(context)),
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
