import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/StateProvider/YearPageStateProvider.dart';
import 'package:lateDiary/StateProvider/DayPageStateProvider.dart';
import 'package:lateDiary/StateProvider/NavigationIndexStateProvider.dart';
import 'package:flutter/material.dart';

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
              ChangeNotifierProvider<NavigationIndexProvider>(
                create: (context) {
                  return NavigationIndexProvider();
                },
              ),
              ChangeNotifierProvider<YearPageStateProvider>(
                create: (context) {
                  return YearPageStateProvider();
                },
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
