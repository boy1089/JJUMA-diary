import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum NavigationRouteStyle {
  cupertino,
  material,
}

class Navigation {
  static Future<T?> navigateTo<T>({
    required BuildContext context,
    required Widget screen,
    required NavigationRouteStyle style,
  }) async {
    Route<T> route;
    route = CupertinoPageRoute<T>(builder: (_) => screen);
    if (style == NavigationRouteStyle.cupertino) {
      route = CupertinoPageRoute<T>(builder: (_) => screen);
    } else if (style == NavigationRouteStyle.material) {
      route = MaterialPageRoute<T>(builder: (_) => screen);
    }

    return await Navigator.push<T>(context, route);
  }
}