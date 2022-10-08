import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/shared.dart';
import 'package:test_location_2nd/NoteData.dart';

import 'package:test_location_2nd/SensorLogger.dart';
import 'package:test_location_2nd/NoteLogger.dart';
import 'package:test_location_2nd/DataAnalyzer.dart';
import 'package:test_location_2nd/DataReader.dart';

import 'package:test_location_2nd/daily_page.dart';
import 'package:test_location_2nd/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/GoogleAccountManager.dart';

import 'SettingPage.dart';
import 'navigation.dart';
import 'package:test_location_2nd/PermissionManager.dart';
import 'PhotoLibraryApiClient.dart';
import 'PhotoManager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var text = "logging";
  final sensorLogger = SensorLogger();
  final noteLogger = NoteLogger();
  final dataAnalyzer = DataAnalyzer();
  final myTextController = TextEditingController();
  final dataReader = DataReader();
  final googleAccountManager = GoogleAccountManager();
  final permissionManager = PermissionManager();
  late final photoLibraryApiClient = PhotosLibraryApiClient(googleAccountManager);
  final photoManager = PhotoManager();

  void saveNote() {
    noteLogger.writeCache2(NoteData(DateTime.now(), myTextController.text));
    text = "${DateTime.now()} : note saved!";
    myTextController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute : '/daily',
      routes : {
        '/daily' : (context) => TestPolarPage(dataReader, googleAccountManager, permissionManager, photoLibraryApiClient),
        '/settings' : (context) => AndroidSettingsScreen(googleAccountManager, permissionManager),
      },

    );
  }
}
