import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:lateDiary/StateProvider/DataStateProvider.dart';
import 'app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/StateProvider/YearPageStateProvider.dart';
import 'package:lateDiary/StateProvider/DayPageStateProvider.dart';
import 'package:lateDiary/StateProvider/NavigationIndexStateProvider.dart';
import 'package:flutter/material.dart';
import 'package:lateDiary/Data/DataManager.dart';

void bootstrap(int i) {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  // Bloc.observer = AppBlocObserver();

  // final todosRepository = TodosRepository(todosApi: todosApi);

  runZonedGuarded(
        () =>   runApp(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<DataManager>(
                create: (context){
                  return DataManager();
                },
              ),
              ChangeNotifierProvider<NavigationIndexProvider>(
                create: (context) {
                  return NavigationIndexProvider();
                },
              ),
              ChangeNotifierProxyProvider<DataManager, YearPageStateProvider>(
                update : (context, dataManager, a)=>YearPageStateProvider(dataManager),
                create : (context)=> YearPageStateProvider(null),

              ),
              ChangeNotifierProvider<DayPageStateProvider>(
                create: (context) {
                  return DayPageStateProvider();
                },
              ),
            ],
            child: App(),
          ),
        ),
        (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}
