import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lateDiary/Permissions/PermissionManager.dart';
import 'package:lateDiary/Note/note_manager.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lateDiary/navigation.dart';
import 'package:lateDiary/pages/DayPage/day_page.dart';
import 'package:lateDiary/pages/YearPage/year_page_screen.dart';
import 'package:lateDiary/pages/YearPage/year_page_screen2.dart';
import 'package:lateDiary/pages/YearPage/year_pave_view3.dart';
import 'package:lateDiary/pages/diary_page.dart';
import 'pages/permission_page.dart';
import 'package:lateDiary/Settings.dart';
import 'package:lateDiary/Data/directories.dart';
import 'pages/MainPage/main_page.dart';
import 'pages/setting_page.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/theme/theme.dart';
import 'package:lateDiary/Data/data_manager_interface.dart';

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
    // dataManager.executeSlowProcesses();
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    late final AnimationController _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    final _router = GoRouter(initialLocation: '/year', routes: [
      GoRoute(
          path: '/year',
          builder: (context, state) => YearPageScreen2(),
          routes: [
            GoRoute(
                path: 'day',
                // builder: (context, state) => DayPage()
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                      key: state.pageKey,
                      child: DayPage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        // return SizeTransition(
                        //   // alignment: Alignment(context.),
                        //     sizeFactor: CurveTween(curve: Curves.easeInOutCirc)
                        //         .animate(animation),
                        //     child: child);

                        return ScaleTransition(
                            // alignment: Alignment(context.),
                            scale: CurveTween(curve: Curves.easeInOutCirc)
                                .animate(animation),
                            child: child);
                        // // return FadeTransition(
                        //   opacity:
                        //   CurveTween(curve: Curves.easeInOutCirc).animate(animation),
                        //   child: child,
                        // );
                      });
                }),
          ]),

      GoRoute(
          path: '/setting',
          builder: (context, state) => AndroidSettingsScreen()),
    ]);

    return MaterialApp.router(
      theme: LateDiaryTheme.dark,
      routerConfig: _router,
      useInheritedMediaQuery: true,
    );
  }
}
