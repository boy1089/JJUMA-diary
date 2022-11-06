import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/Photo/LocalPhotoDataManager.dart';

import 'package:test_location_2nd/Sensor/AudioRecorder.dart';
import 'package:test_location_2nd/Sensor/SensorRecorder.dart';

import 'package:test_location_2nd/Loggers/NoteLogger.dart';
import 'package:test_location_2nd/Sensor/SensorDataReader.dart';

import 'package:test_location_2nd/pages/MainPage.dart';
import 'pages/SettingPage.dart';

import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'Photo/GooglePhotoDataManager.dart';
import 'package:test_location_2nd/Note/NoteData.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';
import 'Photo/LocalPhotoDataManager.dart';
import 'package:test_location_2nd/Note/NoteManager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    // Initialize the model in the builder. That way, Provider
    // can own Counter's lifecycle, making sure to call `dispose`
    // when not needed awnymore.
    create: (context) => NavigationIndexProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final permissionManager = PermissionManager();
  final localPhotoDataManager = LocalPhotoDataManager();

  //sensorLogger will be initialized after initializing PermissionManager
  late final sensorRecorder;
  late final audioRecorder;
  late final dataManager;
  final sensorDataManager = SensorDataManager();
  final noteManager = NoteManager();

  // final noteLogger = NoteLogger();
  // final myTextController = TextEditingController();

  _MyAppState() {
    sensorRecorder = SensorRecorder(permissionManager);
    sensorRecorder.init();
    audioRecorder = AudioRecorder(permissionManager);
    audioRecorder.init();
    super.initState();
    init();
  }

  Future<void> init() async {
    dataManager = DataManager(localPhotoDataManager);
    await dataManager.init();
  }

  // void saveNote() {
  //   noteLogger.writeCache2(NoteData(DateTime.now(), myTextController.text));
  //   myTextController.clear();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/daily',
      routes: {
        '/daily': (context) => MainPage(
              permissionManager,
              dataManager,
              sensorDataManager,
              localPhotoDataManager,
              noteManager,
            ),
        '/settings': (context) =>
            AndroidSettingsScreen(permissionManager),
      },
    );
  }
}
