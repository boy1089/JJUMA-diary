import 'package:flutter/material.dart';
import 'package:lateDiary/Permissions/PermissionManager.dart';
import 'package:lateDiary/Note/NoteManager.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lateDiary/navigation.dart';
import 'pages/PermissionPage.dart';
import 'package:lateDiary/Settings.dart';
import 'package:lateDiary/Data/Directories.dart';
import 'pages/MainPage/MainPage.dart';
import 'pages/SettingPage.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/theme/theme.dart';
import 'package:lateDiary/Data/DataManagerInterface.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final permissionManager = PermissionManager();
  final noteManager = NoteManager();
  late final dataManager;

  bool isPermissionOk = false;
  Future initApp = Future.delayed(const Duration(seconds: 5));
  _AppState() {
    dataManager = DataManagerInterface(global.kOs);
    super.initState();
    initApp = init();
  }

  Future<int> init() async {
    Stopwatch stopwatch = new Stopwatch()..start();
    global.isInitializationDone = false;
    await permissionManager.init();
    if (!permissionManager.isStoragePermissionGranted |
        !permissionManager.isLocationPermissionGranted) {
      // FlutterNativeSplash.remove();
      isPermissionOk = await Navigation.navigateTo(
          context: context,
          screen: PermissionPage(permissionManager),
          style: NavigationRouteStyle.material);
      setState(() {});
    }

    if (global.kOs == "android") {
      await Directories.init(Directories.directories);
      await Settings.init();
    }

    await noteManager.init();
    print("init process, time elapsed : ${stopwatch.elapsed}");
    FlutterNativeSplash.remove();
    await dataManager.init();
    print("init process, time elapsed : ${stopwatch.elapsed}");
    global.isInitializationDone = true;
    await Future.delayed(Duration(seconds: 1));
    print("init done,executed in ${stopwatch.elapsed}");
    dataManager.executeSlowProcesses();
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: LateDiaryTheme.light,
      initialRoute: MainPage.id,
      routes: {
        PermissionPage.id: (context) => PermissionPage(permissionManager),
        MainPage.id: (context) => FutureBuilder(
            future: initApp,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return MainPage();
            }),
        AndroidSettingsScreen.id: (context) => AndroidSettingsScreen(),
      },
      useInheritedMediaQuery: true,
    );
  }
}
