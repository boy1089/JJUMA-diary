import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_location_2nd/Sensor/SensorLogger.dart';
import 'package:test_location_2nd/Loggers/NoteLogger.dart';
import 'package:test_location_2nd/Data/DataAnalyzer.dart';
import 'package:test_location_2nd/Sensor/SensorDataReader.dart';

import 'package:test_location_2nd/pages/MainPage.dart';
import 'pages/SettingPage.dart';

import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import 'Api/PhotoLibraryApiClient.dart';
import 'GooglePhotoManager.dart';
import 'package:test_location_2nd/Note/NoteData.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:test_location_2nd/StateProvider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    // Initialize the model in the builder. That way, Provider
    // can own Counter's lifecycle, making sure to call `dispose`
    // when not needed anymore.
    create: (context) => NavigationIndexProvider(),
    child: const MyApp(),
  ));
  // MultiProvider(
  //   providers: [
  //     ChangeNotifierProvider(create: (_) => NavigationIndexProvider()),
  //   ],
  //   child : const MyApp(),
  // );
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
  final googlePhotoManager = GooglePhotoManager();
  final dataReader = SensorDataReader();
  final googleAccountManager = GoogleAccountManager();
  final permissionManager = PermissionManager();
  late final photoLibraryApiClient =
      PhotosLibraryApiClient(googleAccountManager);
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
        '/daily': (context) => MainPage(dataReader, googleAccountManager,
            permissionManager, photoLibraryApiClient, dataManager, googlePhotoManager),
        '/settings': (context) =>
            AndroidSettingsScreen(googleAccountManager, permissionManager),
      },
    );
  }
}
