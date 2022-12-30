import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'app.dart';
import 'package:provider/provider.dart';
import 'package:JJUMA.d/StateProvider/year_page_state_provider.dart';
import 'package:JJUMA.d/StateProvider/navigation_index_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:JJUMA.d/Data/data_manager_interface.dart';
import 'package:JJUMA.d/Util/global.dart' as global;
import 'package:go_router/go_router.dart';

void bootstrap(int i) {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  YearPageStateProvider yearPageStateProvider =
      YearPageStateProvider(DataManagerInterface(global.kOs));

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
              return yearPageStateProvider..updateProvider_compute();
            },
            create: (context) => yearPageStateProvider,
          ),
        ],
        child: App(),
      ),
    ),
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}
