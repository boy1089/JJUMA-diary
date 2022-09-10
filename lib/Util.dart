
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