import 'package:flutter/material.dart';
import 'package:jjuma.d/Util/global.dart' as global;

class jjumaTheme {
  static ThemeData get light {
    return ThemeData(
      progressIndicatorTheme: ProgressIndicatorThemeData(),
      fontFamily: 'NotoSans',
      textTheme: TextTheme(
          //theme for year page year
          headline1: TextStyle(
              color: Colors.black45, fontWeight: FontWeight.w300, fontSize: 90),

          //theme for day page title
          headline3: TextStyle(
          color: Colors.black45, fontWeight: FontWeight.w300, fontSize: 25),

          //theme for background texts
          headline2:
              TextStyle(fontSize: 40, color: global.kColor_backgroundText),

          //theme for notes
          subtitle1: TextStyle(
              fontWeight: global.kFontWeight_diaryTitle,
              color: global.kColor_diaryText),
          bodyText1: TextStyle(
              fontWeight: global.kFontWeight_diaryContents,
              color: global.kColor_diaryText)),
      appBarTheme: const AppBarTheme(
        color: Color(0xFF13B9FF),
      ),
      colorScheme: ColorScheme.fromSwatch(
        accentColor: const Color(0xFF13B9FF),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      toggleableActiveColor: const Color(0xFF13B9FF),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      fontFamily: 'NotoSans',
      appBarTheme: const AppBarTheme(
        // color: Color(0xFF13B9FF),
        color : Colors.black12,
      ),
      colorScheme: ColorScheme.fromSwatch(
        brightness: Brightness.dark,
        accentColor: const Color(0xFF13B9FF),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      toggleableActiveColor: const Color(0xFF13B9FF),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders : {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }
      ),
    );
  }
}
