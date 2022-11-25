import 'package:flutter/material.dart';
import 'package:lateDiary/Util/global.dart' as global;

class LateDiaryTheme {
  static ThemeData get light {
    return ThemeData(
      textTheme: TextTheme(
        //year page
          headline1:TextStyle(
              color: Colors.black45,
              fontWeight: FontWeight.w300,
              fontSize: 30
          ),


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
      appBarTheme: const AppBarTheme(
        color: Color(0xFF13B9FF),
      ),
      colorScheme: ColorScheme.fromSwatch(
        brightness: Brightness.dark,
        accentColor: const Color(0xFF13B9FF),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      toggleableActiveColor: const Color(0xFF13B9FF),
    );
  }
}
