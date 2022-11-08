import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/Location/LocationDataManager.dart';
import 'package:test_location_2nd/Photo/PhotoDataManager.dart';

import 'package:test_location_2nd/Sensor/AudioRecorder.dart';
import 'package:test_location_2nd/Sensor/SensorRecorder.dart';

import 'package:test_location_2nd/pages/MainPage.dart';
import 'pages/SettingPage.dart';

import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';
import 'Photo/PhotoDataManager.dart';
import 'package:test_location_2nd/Note/NoteManager.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    // Initialize the model in the builder. That way, Provider
    // can own Counter's lifecycle, making sure to call `dispose`
    // when not needed anymore.
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
  final sensorDataManager = SensorDataManager();
  final noteManager = NoteManager();
  late final photoDataManager;
  late final locationDataManager;
  //sensorLogger will be initialized after initializing PermissionManager
  late final sensorRecorder;
  late final audioRecorder;
  late final dataManager;


  Future initApp = Future.delayed(const Duration(seconds: 5));

  _MyAppState() {
    // sensorRecorder = SensorRecorder(permissionManager);
    // sensorRecorder.init();
    // audioRecorder = AudioRecorder(permissionManager);
    // audioRecorder.init();

    photoDataManager = PhotoDataManager();
    locationDataManager = LocationDataManager();
    dataManager = DataManager(photoDataManager, locationDataManager);
    initApp = init();
    super.initState();
  }

  Future<int> init() async {
    await permissionManager.init();
    await noteManager.init();
    await photoDataManager.init();
    await locationDataManager.init();
    await dataManager.init();
    print("init done");
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    print("start building app..");
    return FutureBuilder(
        future: initApp,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // print("snapshot.hasData? ${snapshot.hasData}, ${snapshot.data}");
          print(snapshot.data);
          print(dataManager.summaryOfPhotoData);
          return MaterialApp(
            initialRoute: '/daily',
            routes: {
              '/daily': (context) => MainPage(
                    permissionManager,
                    dataManager,
                    sensorDataManager,
                    photoDataManager,
                    noteManager,
                  ),
              '/settings': (context) =>
                  AndroidSettingsScreen(permissionManager),
            },
          );
        });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     initialRoute: '/daily',
  //     routes: {
  //       '/daily': (context) => MainPage(
  //             permissionManager,
  //             dataManager,
  //             sensorDataManager,
  //             photoDataManager,
  //             noteManager,
  //           ),
  //       '/settings': (context) =>
  //           AndroidSettingsScreen(permissionManager),
  //     },
  //   );
  // }
}
