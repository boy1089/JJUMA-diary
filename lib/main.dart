
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'bootstrap.dart';
import 'package:lateDiary/Util/Util.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Future.delayed(Duration(milliseconds: 200)).then((a){


     physicalScreenSize = window.physicalSize / window.devicePixelRatio;
     physicalWidth = physicalScreenSize.width;
     physicalHeight = physicalScreenSize.height;

  });

  bootstrap(1);

}
