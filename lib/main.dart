
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'bootstrap.dart';
import 'package:lateDiary/Util/Util.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Future.delayed(Duration(milliseconds: 200)).then((a){


     physicalScreenSize = window.physicalSize / window.devicePixelRatio;
     physicalWidth = physicalScreenSize.width;
     physicalHeight = physicalScreenSize.height;

     sizeOfChart = Size(physicalWidth*2, physicalWidth*2);

     maximumSizeOfScatter = physicalWidth/8;
     minimumSizeOfScatter = maximumSizeOfScatter/50;

  });

  bootstrap(1);

}
