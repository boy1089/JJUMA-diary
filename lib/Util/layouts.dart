import 'global.dart' as global;
import 'package:lateDiary/Util/Util.dart';
import 'package:flutter/material.dart';

Map layout_yearPage = {
  'graphSize': {
    true: global.kYearPageGraphSize * global.kMagnificationOnYearPage,
    false: global.kYearPageGraphSize
  },
  'left': {
    true: -global.kYearPageGraphSize / 2 * global.kMagnificationOnYearPage -
        global.kYearPageGraphSize /
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
        global.kYearPageGraphSize / 2
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
    true: (global.kAvailableHeight -
        (global.kAvailableHeight * global.kYPositionRatioOfGraph +
            global.kYearPageGraphSize / 2)) /
        2,
    false: global.kAvailableHeight -
        (global.kAvailableHeight * global.kYPositionRatioOfGraph + global.kYearPageGraphSize / 2)
  }
};