
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'bootstrap.dart';
import 'package:jjuma.d/Util/Util.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  print("starting..");
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Future.delayed(Duration(milliseconds: 200)).then((a){
      print("get screen size");
     physicalScreenSize = window.physicalSize / window.devicePixelRatio;
     physicalWidth = physicalScreenSize.width;
     physicalHeight = physicalScreenSize.height;

     sizeOfChart = Size(physicalWidth*2, physicalWidth*2);

     maximumSizeOfScatter = physicalWidth/8;
     minimumSizeOfScatter = maximumSizeOfScatter/50;
    print("getting screen size Done");
  });

  bootstrap(1);

}
