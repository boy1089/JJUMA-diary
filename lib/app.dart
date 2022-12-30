import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:JJUMA.d/Permissions/PermissionManager.dart';
import 'package:JJUMA.d/Note/note_manager.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:JJUMA.d/navigation.dart';
import 'package:JJUMA.d/pages/YearPage/year_page_screen.dart';
import 'package:JJUMA.d/pages/YearPage/year_page_screen.dart';
import 'package:JJUMA.d/pages/diary_page.dart';
import 'pages/permission_page.dart';
import 'package:JJUMA.d/Settings.dart';
import 'package:JJUMA.d/Data/directories.dart';
import 'pages/setting_page.dart';
import 'package:JJUMA.d/Util/global.dart' as global;
import 'package:JJUMA.d/theme/theme.dart';
import 'package:JJUMA.d/Data/data_manager_interface.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  final permissionManager = PermissionManager();
  late final dataManager;

  bool isPermissionOk = false;
  Future initApp = Future.delayed(const Duration(seconds: 1));

  _AppState() {
    dataManager = DataManagerInterface(global.kOs);
    super.initState();
    initApp = init();
  }

  Future<int> init() async {
    Stopwatch stopwatch = new Stopwatch()..start();

    print("init process start init time elapsed : ${stopwatch.elapsed}");
    global.isInitializationDone = false;
    await permissionManager.init();

    print("init process, permissino init done, time elapsed : ${stopwatch.elapsed}");
    if (!permissionManager.isStoragePermissionGranted) {
      // FlutterNativeSplash.remove();
      isPermissionOk = await Navigation.navigateTo(
          context: context,
          screen: PermissionPage(permissionManager),
          style: NavigationRouteStyle.material);
      setState(() {});
    }
    print("init process, permissino check done, time elapsed : ${stopwatch.elapsed}");

    if (global.kOs == "android") {
      await Directories.init(Directories.directories);
      await Settings.init();
    }
    print("init process, directories, settings init done, time elapsed : ${stopwatch.elapsed}");

    await dataManager.init();
    print("init process, dataManager init done, time elapsed : ${stopwatch.elapsed}");
    global.isInitializationDone = true;
    print("init done,executed in ${stopwatch.elapsed}");
    FlutterNativeSplash.remove();
    dataManager.executeSlowProcesses();
    return 0;
  }

  @override
  Widget build(BuildContext context) {

    var a = YearPageScreen();
    final _router = GoRouter(initialLocation: '/year', routes: [
      GoRoute(
          path: '/year',
          builder: (context, state) => a,
      ),

      GoRoute(
          path: '/setting',
          builder: (context, state) => AndroidSettingsScreen()),
    ]);

    return MaterialApp.router(
      theme: JJUMATheme.dark,
      routerConfig: _router,
      useInheritedMediaQuery: true,
    );
  }
}
