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

  Map<String, Map> listOfImagesInYears = {};

  double keyboardSize = 300;
  DataManagerInterface dataManager;
  ScrollController scrollController = ScrollController();

  DayPageStateProvider(this.dataManager) {
    print("DayPageStateProvider created");
    updateData();
    notifyListeners();
  }

  void updateData(){
    List<int> listOfYears = List<int>.generate(10, (index)=>DateTime.now().year - index);

    for(int year in listOfYears){
        listOfImagesInYears[year.toString()] = Map.from(dataManager.infoFromFiles)..removeWhere((k, v) => v.datetime.year != year);
    }
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
