import 'package:flutter/material.dart';
import 'package:lateDiary/Data/infoFromFile.dart';
import 'package:lateDiary/Note/NoteManager.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/Photo/PhotoDataManager.dart';

import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/Location/AddressFinder.dart';
import 'package:lateDiary/Location/Coordinate.dart';
import 'package:geocoding/geocoding.dart';

import '../Data/DataManagerInterface.dart';
import 'package:flutter/material.dart';

class DayPageStateProvider with ChangeNotifier {
  PhotoDataManager photoDataManager = PhotoDataManager();
  NoteManager noteManager = NoteManager();

  double zoomInAngle = 0.0;
  bool isZoomIn = false;
  bool isBottomNavigationBarShown = true;
  bool isZoomInImageVisible = false;
  String date = formatDate(DateTime.now());
  int indexOfDate = 0;
  List<String> availableDates = [];
  Map<int, String?> addresses = {};
  String note = "";
  Map<dynamic, InfoFromFile> listOfImages = {};
  List<Map<dynamic, InfoFromFile>> listOfEvents = [];
  Map<String, List<Map<dynamic, InfoFromFile>>> listOfEventsInDay = {};

  double keyboardSize = 300;
  DataManagerInterface dataManager;
  ScrollController scrollController = ScrollController();

  DayPageStateProvider(this.dataManager) {
    print("DayPageStateProvider created");
    updateData();
    scrollController.animateTo(1000,
        duration: Duration(milliseconds: 500), curve: Curves.bounceInOut);
    notifyListeners();
  }

  void updateData() async {
    Map<dynamic, InfoFromFile> data = dataManager.infoFromFiles;
    Map<dynamic, InfoFromFile> filteredDataAll = Map.fromEntries(data.entries
        .where((k) => k.value.date!.contains(date.substring(0, 6))));
    filteredDataAll.forEach((key, value) {print("$key, $value");});
    List<String> dates = List.generate(filteredDataAll.length,
        (index) => filteredDataAll.entries.elementAt(index).value.date!);
    Set<String> setOfDates = dates.toSet();
     indexOfDate = setOfDates.toList().indexWhere((element) => element==date);
    listOfEventsInDay = {};
    for (int i = 0; i < setOfDates.length; i++) {
      String date = setOfDates.elementAt(i);
      listOfImages = {};
      listOfImages.addAll(Map.fromEntries(
          filteredDataAll.entries.where((k) => k.value.date!.contains(date))));
      listOfEventsInDay[date] = updateEvents();
    }

  }

  List<Map<dynamic, InfoFromFile>> updateEvents() {
    List<Map<dynamic, InfoFromFile>> events = [];

    global.kMinimumTimeDifferenceBetweenImages_ZoomOut;
    var listOfImages2 = {...listOfImages};
    if (listOfImages2.isEmpty) return [];
    Map<dynamic, InfoFromFile> event = {}
      ..addEntries({listOfImages2.entries.elementAt(0)});

    for (int i = 0; i < listOfImages2.length - 1; i++) {
      // print(listOfImages2.entries.elementAt(i).value.datetime!.difference(
      //     listOfImages2.entries.elementAt(i + 1).value.datetime!));
      if ((listOfImages2.entries
              .elementAt(i + 1)
              .value
              .datetime!
              .difference(listOfImages2.entries.elementAt(i).value.datetime!)) <
          Duration(minutes: 60)) {
        event.addEntries({listOfImages2.entries.elementAt(i + 1)});
      } else {
        events.add(event);
        event = {}..addEntries({listOfImages2.entries.elementAt(i + 1)});
      }
    }
    if (event.isNotEmpty) events.add(event);
    listOfEvents = events;
    print("listEvents : $listOfEvents");
    return events;
  }

  void writeNote() {
    if (note != "") {
      noteManager.writeNote(date, note);
      noteManager.notes[date] = note;
    }

    if (note == "") {
      noteManager.tryDeleteNote(date);
      try {
        noteManager.notes.remove(date);
      } catch (e) {
        print("error during writeNote : $e");
      }
    }
  }

  void deleteNote() {
    noteManager.tryDeleteNote(date);
  }

  void setKeyboardSize() {
    final viewInsets = EdgeInsets.fromWindowPadding(
        WidgetsBinding.instance.window.viewInsets,
        WidgetsBinding.instance.window.devicePixelRatio);

    keyboardSize = viewInsets.bottom;
    print("daypage set keyboard size :$keyboardSize");
    notifyListeners();
  }

  void setDate(String date) {
    this.date = date;
    print("date : ${this.date}");
    updateData();
    notifyListeners();
  }

  void setIsZoomInImageVisible(bool isZoomInImageVisible) {
    this.isZoomInImageVisible = isZoomInImageVisible;
    notifyListeners();
  }

  void setBottomNavigationBarShown(bool isBottomNavigationBarShown) {
    this.isBottomNavigationBarShown = isBottomNavigationBarShown;
    print("isBottomNavigationBarShown : $isBottomNavigationBarShown");
    notifyListeners();
  }

  void setZoomInRotationAngle(angle) {
    // print("provider set zoomInAngle to $angle");
    zoomInAngle = angle;
    notifyListeners();
  }

  void setZoomInState(isZoomIn) {
    print("provider set isZoomIn to $isZoomIn");
    this.isZoomIn = isZoomIn;
    notifyListeners();
  }

  void setAvailableDates(availableDates) {
    print("provider set isZoomIn to $isZoomIn");
    this.availableDates = availableDates;
    notifyListeners();
  }

  void setNote(note) {
    this.note = note;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    print("dayPageStateProvider disposed");
  }

// Future<void> updateSensorData() async {
//   var sensorData = await this.sensorDataManager.openFile(date);
//   try {
//     sensorDataForPlot = modifyListForPlot(subsampleList(sensorData, 10));
//   } catch (e) {
//     sensorDataForPlot = [[]];
//     print("error during updating sensorData : $e");
//   }
//   print("sensorDataForPlot : $sensorDataForPlot");
// }
  // Future<Map<int, String?>> updateAddress() async {
  //   Map<int, int> selectedIndex = {};
  //   Map<int, String?> addresses = {};
  //   List<Placemark?> addressOfFiles = [];
  //
  //   files = transpose(photoForPlot)[1];
  //
  //   selectedIndex = selectIndexForLocation(files);
  //   addressOfFiles = await getAddressOfFiles(selectedIndex.values.toList());
  //   addresses = {
  //     for (var item in List.generate(selectedIndex.keys.length, (i) => i))
  //       selectedIndex.keys.elementAt(item):
  //       "${addressOfFiles.elementAt(item)?.locality}"
  //   };
  //
  //   // value: (item) => "${addressOfFiles
  //   //     .elementAt(item)
  //   //     ?.locality}, ${addressOfFiles.elementAt(item)?.thoroughfare}" );
  //   return addresses;
  // }
  //
  // Map<int, int> selectIndexForLocation(files) {
  //   Map<int, int> indexForSelectedFile = {};
  //   List<DateTime?> datetimes = List<DateTime?>.generate(files.length,
  //           (i) => dataManager.infoFromFiles[files.elementAt(i)]?.datetime);
  //   datetimes = datetimes.whereType<DateTime>().toList();
  //   List<int> times =
  //   List<int>.generate(datetimes.length, (i) => datetimes[i]!.hour);
  //   Set<int> setOfTimes = times.toSet();
  //   for (int i = 0; i < setOfTimes.length; i++)
  //     indexForSelectedFile[setOfTimes.elementAt(i)] =
  //     (times.indexOf(setOfTimes.elementAt(i)));
  //   return indexForSelectedFile;
  // }
  //
  // Future<List<Placemark?>> getAddressOfFiles(List<int> index) async {
  //   List<Placemark?> listOfAddress = [];
  //   for (int i = 0; i < index.length; i++) {
  //     Coordinate? coordinate =
  //         dataManager.infoFromFiles[files[index.elementAt(i)]]!.coordinate;
  //     if (coordinate == null) {
  //       listOfAddress.add(null);
  //     }
  //     Placemark? address = await AddressFinder.getAddressFromCoordinate(
  //         coordinate?.latitude, coordinate?.longitude);
  //     listOfAddress.add(address);
  //   }
  //   return listOfAddress;
  // }
}
