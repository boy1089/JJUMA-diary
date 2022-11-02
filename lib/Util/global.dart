




import 'package:intl/intl.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
DateTime selectedDate = DateTime(2022, 1, 1);

int mainPageSelectionIndex = 0;

Map summaryOfPhotoData = {};
Map summaryOfNoteData = {};

//Colors
Color kBackGroundColor = Colors.white;
Color kMainColor_warm = Colors.deepOrangeAccent;
// Color kMainColor_warm = Colors.red;

// Color kMainColor_cool = Colors.lightBlueAccent;
Color kMainColor_cool = Colors.white;
int indexForZoomInImage = -1;
bool isImageClicked = false;

Color kMainColor_option =Colors.green;

int animationTime = 200;
double monthPageScrollOffset = 0.0;

int startYear = 2013;

double kMinimumTimeDifferenceBetweenImages = 0.05; //unit is hour

GoogleSignInAccount? currentUser;

double value = 0.8;
double value2 = 0.6;
List<List<dynamic>> dummyData1 = [
  [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
  [0.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [1.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [2.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [3.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [4.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [5.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [6.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [7.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [8.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [9.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [10.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [11.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [12.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [13.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [14.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [15.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [16.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [17.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [18.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [19.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [20.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [21.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [22.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [23.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [24.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
];

List<List<dynamic>> dummyData2 = [
  [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
  [0.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [1.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [2.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [3.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [4.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [5.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [6.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [7.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [8.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [9.0, value, 0.0, 0.0, 0.0, 0.0, 0.0],
  [10.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [11.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [12.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [13.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [14.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [15.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [16.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [17.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [18.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [19.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [20.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [21.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [22.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [23.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
  [24.0, value2, 0.0, 0.0, 0.0, 0.0, 0.0],
];