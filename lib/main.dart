import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/shared.dart';
import 'package:test_location_2nd/Note/NoteData.dart';

import 'package:test_location_2nd/Sensor/SensorLogger.dart';
import 'package:test_location_2nd/Loggers/NoteLogger.dart';
import 'package:test_location_2nd/Data/DataAnalyzer.dart';
import 'package:test_location_2nd/Data/DataReader.dart';

import 'package:test_location_2nd/pages/daily_page.dart';
import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';

import 'pages/SettingPage.dart';
import 'navigation.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'Api/PhotoLibraryApiClient.dart';
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
