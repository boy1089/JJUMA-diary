import 'global.dart' as global;
import 'package:JJUMA.d/Util/Util.dart';
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
    true:(physicalHeight -
        global.kBottomNavigationBarHeight -
        global.kHeightOfArbitraryWidgetOnBottom) *
        (global.kYPositionRatioOfGraph) -
        global.kYearPageGraphSize / 2,
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



var graphSize = physicalWidth*2;

Map layout_yearPage2 = {
  'graphSize': {
    true: graphSize * 2,
    false:graphSize
  },
  'left': {
    true: -graphSize,
    false: -graphSize/4,
  },
  'top': {
    true: -graphSize/2,
    false: 0,
  }, //30 : bottom bar, 30: navigation bar, (1/3) positioned one third

};

Map layout_dayPage = {
  'graphSize': {
    true: global.kDayPageGraphSize * global.kMagnificationOnDayPage,
    false: global.kDayPageGraphSize
  },
  'left': {
    true: -global.kDayPageGraphSize / 2 * global.kMagnificationOnDayPage -
        global.kDayPageGraphSize /
            2 *
            global.kMagnificationOnDayPage *
            (1 - 0.4),
    false: global.kMarginForDayPage
  },
  'top': {
    true: null,
    false: (physicalHeight -
        global.kBottomNavigationBarHeight -
        global.kHeightOfArbitraryWidgetOnBottom) *
        (global.kYPositionRatioOfGraph) -
        global.kDayPageGraphSize / 2
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
    true: (global.kAvailableHeight -
        (global.kAvailableHeight * global.kYPositionRatioOfGraph +
            global.kDayPageGraphSize / 2)) /
        2 -
        20,
    false: global.kAvailableHeight -
        (global.kAvailableHeight * global.kYPositionRatioOfGraph +
            global.kDayPageGraphSize / 2) -
        20
  }
};
