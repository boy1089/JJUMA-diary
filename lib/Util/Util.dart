
import 'package:flutter/material.dart';


List<String> kTimeStamps = [
  '00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17',
'18', '19', '20', '21', '22', '23'
];


List<String> kTimeStamps2hour = [
  '00', '02',  '04',  '06', '08', '10', '12', '14', '16',
  '18', '20', '22',
];
List<String> kTimeStamps_filtered = [
  '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17',
  '18', '19', '20', '21', '22', '23'
];


List<String> kTimeStamps2hour_filtered = [
  '06', '08', '10', '12', '14', '16',
  '18', '20', '22',
];

const longitude_home = 126.7209;
const latitude_home = 37.3627;
const distance_threshold_home = 0.02;

const event_color_goingOut = Colors.red;
const event_color_backHome = Colors.blue;
const path_phonecall = '/sdcard/Music/TPhoneCallRecords';

int a = 10;
List<Color> get colorsHotCold => [
  Color.fromARGB(a, 50, 0, 0),
  Color.fromARGB(a, 40, 0, 0),
  Color.fromARGB(a, 30, 0, 0),
  Color.fromARGB(a, 20, 0, 0),
  Color.fromARGB(a, 10, 0, 0),
  Color.fromARGB(a, 0, 0, 0),
  Color.fromARGB(a, 0, 0, 10),
  Color.fromARGB(a, 0, 0, 20),
  Color.fromARGB(a, 0, 0, 30),
  Color.fromARGB(a, 0, 0, 40),
];