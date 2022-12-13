import 'package:flutter/material.dart';
import 'package:lateDiary/Data/info_from_file.dart';
import 'package:lateDiary/Note/note_manager.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/Photo/photo_data_manager.dart';

import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/Location/AddressFinder.dart';
import 'package:lateDiary/Location/coordinate.dart';
import 'package:geocoding/geocoding.dart';

import '../Data/data_manager_interface.dart';
import 'package:flutter/material.dart';

import '../pages/DayPage/model/event.dart';

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
  List<Event> listOfEvents = [];
  Map<String, List<Event>> listOfEventsInDay = {};

  double keyboardSize = 300;
  DataManagerInterface dataManager;
  ScrollController scrollController = ScrollController();

  DayPageStateProvider(this.dataManager) {
    print("DayPageStateProvider created");
    updateData();
    notifyListeners();
  }

  void updateData() async {
    Map<dynamic, InfoFromFile> data = dataManager.infoFromFiles;

    Map<dynamic, InfoFromFile> filteredDataAll = Map.fromEntries(data.entries
        .where((k) {
          if(k.value.date == null) return false;
      return k.value.date!.contains(date.substring(0, 8));
    }));
    filteredDataAll = removeEventFromMap(filteredDataAll);

    List<String> dates = List.generate(filteredDataAll.length,
        (index) => filteredDataAll.entries.elementAt(index).value.date!);

    Set<String> setOfDates = dates.toSet();

    indexOfDate = setOfDates.toList().indexWhere((element) => element == date);
    listOfEventsInDay = {};
    for (int i = 0; i < setOfDates.length; i++) {
      String date = setOfDates.elementAt(i);
      listOfImages = {};
      listOfImages.addAll(Map.fromEntries(
          filteredDataAll.entries.where((k) => k.value.date!.contains(date))));
      listOfEventsInDay[date] = updateEvents();
      dataManager.eventList.forEach((key, value) {
        if(key.contains(date)) listOfEventsInDay[date]!.add(value);
      });
    }
  }

  Map<dynamic, InfoFromFile> removeEventFromMap(Map<dynamic, InfoFromFile> map){
    Map<dynamic, InfoFromFile> imagesInEvents = {};
    for(int i = 0; i< dataManager.eventList.length; i++){
      imagesInEvents.addAll(dataManager.eventList.values.elementAt(i).images);
    }
    print("imagesInEvetns : $imagesInEvents");
    print("map : $map");

    map.removeWhere((key, value) => imagesInEvents.containsKey(key));
    return map;
  }

  List<Event> updateEvents() {
    List<Event> events = [];

    var listOfImages2 = {...listOfImages};

    if (listOfImages2.isEmpty) return [];
    Map<dynamic, InfoFromFile> dataForEvent = {}
      ..addEntries({listOfImages2.entries.elementAt(0)});

    for (int i = 0; i < listOfImages2.length - 1; i++) {
      if ((listOfImages2.entries
              .elementAt(i + 1)
              .value
              .datetime!
              .difference(listOfImages2.entries.elementAt(i).value.datetime!)) <
          Duration(minutes: 60)) {
        dataForEvent.addEntries({listOfImages2.entries.elementAt(i + 1)});
      } else {

        events.add(Event.fromImages(images : dataForEvent));
        dataForEvent = {}..addEntries({listOfImages2.entries.elementAt(i + 1)});
      }
    }
    if (dataForEvent.isNotEmpty) events.add(Event.fromImages(images : dataForEvent));
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
}
