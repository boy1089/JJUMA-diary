import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'app.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/StateProvider/day_page_state_provider.dart';
import 'package:lateDiary/StateProvider/navigation_index_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:lateDiary/Data/data_manager_interface.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:go_router/go_router.dart';

void bootstrap(int i) {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  YearPageStateProvider yearPageStateProvider =
      YearPageStateProvider(DataManagerInterface(global.kOs));
  DayPageStateProvider dayPageStateProvider =
      DayPageStateProvider(DataManagerInterface(global.kOs));


  runZonedGuarded(
    () => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DataManagerInterface>(
            create: (context) {
              return DataManagerInterface(global.kOs);
            },
          ),
          ChangeNotifierProvider<NavigationIndexProvider>(
            create: (context) {
              return NavigationIndexProvider();
            },
          ),
          ChangeNotifierProxyProvider<DataManagerInterface,
              YearPageStateProvider>(
            update: (context, dataManager, a) {
              print("on update, $a");
              return yearPageStateProvider
                ..updateData()..modifyData();
            },
            create: (context) => yearPageStateProvider,
          ),
          ChangeNotifierProxyProvider<DataManagerInterface,
                  DayPageStateProvider>(
              update: (context, dataManager, a) => dayPageStateProvider,
              // update : (context, dataManager, a) =>DayPageStateProvider(dataManager),
              create: (context) {
                return dayPageStateProvider;
              })
        ],
        child: App(),
      ),
    ),
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}
