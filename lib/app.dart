
import 'package:flutter/material.dart';
import 'package:lateDiary/Permissions/PermissionManager.dart';
import 'package:lateDiary/Sensor/SensorDataManager.dart';
import 'package:lateDiary/Note/NoteManager.dart';
import 'package:lateDiary/Photo/PhotoDataManager.dart';
import 'package:lateDiary/Location/LocationDataManager.dart';
import 'package:lateDiary/Data/DataManager.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lateDiary/navigation.dart';
import 'pages/PermissionPage.dart';
import 'package:lateDiary/Settings.dart';
import 'package:lateDiary/Data/Directories.dart';
import 'pages/MainPage.dart';
import 'pages/SettingPage.dart';
import 'package:lateDiary/Util/global.dart' as global;

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String initialRoute = '/daily';

  final permissionManager = PermissionManager();
  final sensorDataManager = SensorDataManager();
  final noteManager = NoteManager();

  late final photoDataManager;
  late final locationDataManager;

  late final dataManager;

  bool test = false;
  Future initApp = Future.delayed(const Duration(seconds: 5));

  _AppState() {

    photoDataManager = PhotoDataManager();
    locationDataManager = LocationDataManager();
    dataManager = DataManager(photoDataManager, locationDataManager);

    initApp = init();
    super.initState();
  }

  Future<int> init() async {
    Stopwatch stopwatch = new Stopwatch()..start();
    global.isInitializationDone = false;
    await permissionManager.init();

    print(
        "init process, permission manater init done. time elapsed : ${stopwatch.elapsed}");

    if (!permissionManager.isStoragePermissionGranted |
    !permissionManager.isLocationPermissionGranted) {
      FlutterNativeSplash.remove();
      test = await Navigation.navigateTo(
          context: context,
          screen: PermissionPage(permissionManager),
          style: NavigationRouteStyle.material);
      setState(() {});
    }

    await Directories.init(Directories.directories);
    await Settings.init();
    await noteManager.init();
    print("init process, time elapsed : ${stopwatch.elapsed}");
    await dataManager.init();
    print("init process, time elapsed : ${stopwatch.elapsed}");
    global.isInitializationDone = true;
    FlutterNativeSplash.remove();
    print("init done,executed in ${stopwatch.elapsed}");
    dataManager.executeSlowProcesses();
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/daily',
      routes: {
        '/permission': (context) => PermissionPage(permissionManager),
        '/daily': (context) => FutureBuilder(
            future: initApp,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return MainPage(
                permissionManager,
                dataManager,
                sensorDataManager,
                photoDataManager,
                noteManager,
              );
            }),
        '/settings': (context) => AndroidSettingsScreen(permissionManager),
      },
      useInheritedMediaQuery: true,
    );
  }
}
