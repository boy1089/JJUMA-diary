import 'package:flutter/material.dart';

import 'package:test_location_2nd/Sensor/SensorLogger.dart';
import 'package:test_location_2nd/Loggers/NoteLogger.dart';
import 'package:test_location_2nd/Data/DataAnalyzer.dart';
import 'package:test_location_2nd/Sensor/SensorDataReader.dart';

import 'package:test_location_2nd/pages/daily_page.dart';
import 'pages/SettingPage.dart';

import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import 'Api/PhotoLibraryApiClient.dart';
import 'PhotoManager.dart';
import 'package:test_location_2nd/Note/NoteData.dart';
import 'package:test_location_2nd/Data/DataManager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final sensorLogger = SensorLogger();
  final noteLogger = NoteLogger();
  final dataAnalyzer = DataAnalyzer();
  final myTextController = TextEditingController();
  final dataReader = DataReader();
  final googleAccountManager = GoogleAccountManager();
  final permissionManager = PermissionManager();
  late final photoLibraryApiClient =
      PhotosLibraryApiClient(googleAccountManager);
  final photoManager = PhotoManager();
  final dataManager = DataManager();

  void saveNote() {
    noteLogger.writeCache2(NoteData(DateTime.now(), myTextController.text));
    myTextController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/daily',
      routes: {
        '/daily': (context) => TestPolarPage(dataReader, googleAccountManager,
            permissionManager, photoLibraryApiClient, dataManager),
        '/settings': (context) =>
            AndroidSettingsScreen(googleAccountManager, permissionManager),
      },
    );
  }
}
