import 'package:flutter/material.dart';
import 'package:test_location_2nd/Note/NoteManager.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import '../Util/global.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Photo/PhotoDataManager.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';

import 'package:test_location_2nd/Util/global.dart' as global;

import 'package:test_location_2nd/Location/AddressFinder.dart';
import 'package:test_location_2nd/Location/Coordinate.dart';
import 'package:geocoding/geocoding.dart';

class DayPageStateProvider with ChangeNotifier {
  PhotoDataManager photoDataManager = PhotoDataManager();
  SensorDataManager sensorDataManager = SensorDataManager();
  NoteManager noteManager = NoteManager();

  double zoomInAngle = 0.0;
  bool isZoomIn = false;
  bool isBottomNavigationBarShown = true;
  int lastNavigationIndex = 0;
  bool isZoomInImageVisible = false;
  String date = formatDate(DateTime.now());

  List<String> availableDates = [];
  Map summaryOfGooglePhotoData = {};
  List photoForPlot = [];
  dynamic photoData = [[]];
  dynamic sensorDataForPlot = [[]];
  List<List<dynamic>> photoDataForPlot = [[]];
  Map<int, String?> addresses = {};
  String note = "";


  Future<void> updateDataForUi() async {
    photoForPlot = [];
    photoDataForPlot = [];
    photoData = [[]];
    try {
      photoData = await updatePhotoData();
      photoForPlot = selectPhotoForPlot(photoData);
    } catch (e) {
      print("while updating Ui, error is occrued : $e");
    }

    // //convert data type..
    photoDataForPlot = List<List>.generate(
        photoForPlot.length, (index) => photoForPlot.elementAt(index));
    addresses = await updateAddress();
    await updateSensorData();
    try {
      note = await noteManager.readNote(date);
    } catch (e) {
      print("while updating UI, reading note, error is occured : $e");
    }
    print("updateUi done");
  }

  Future updatePhotoData() async {
    print("dayPage, updatePhotoFromLocal, date : $date");
    List<List<dynamic>> data = await photoDataManager.getPhotoOfDate(date);
    print("dayPage, updatePhotoFromLocal, files : $data");
    photoData = modifyListForPlot(data, executeTranspose: true);
    return photoData;
  }

  List selectPhotoForPlot(List input) {
    print("DayPage selectImageForPlot : ${input}");
    if (input[0] == null) return photoForPlot;
    if (input[0].length == 0) return photoForPlot;

    photoForPlot.add([input.first[0], input.first[1], input.first[2], true]);
    print(photoForPlot);
    int j = 0;
    for (int i = 1; i < input.length - 2; i++) {
      if ((input[i][0] - photoForPlot[j][0]).abs() >
          global.kMinimumTimeDifferenceBetweenImages) {
        photoForPlot.add([input[i][0], input[i][1], input[i][2], true]);
        j = i;
      } else {
        photoForPlot.add([input[i][0], input[i][1], input[i][2], false]);
      }
    }

    photoForPlot.add([input.last[0], input.last[1], input.last[2], true]);
    print("selectImagesForPlot done, $photoForPlot");
    return photoForPlot;
  }

  Future<void> updateSensorData() async {
    var sensorData = await this.sensorDataManager.openFile(date);
    try {
      sensorDataForPlot = modifyListForPlot(subsampleList(sensorData, 10));
    } catch (e) {
      sensorDataForPlot = [[]];
      print("error during updating sensorData : $e");
    }
    print("sensorDataForPlot : $sensorDataForPlot");
  }

  Future<Map<int, String?>> updateAddress() async {
    Map<int, int> selectedIndex = {};
    Map<int, String?> addresses = {};
    List<Placemark?> addressOfFiles = [];

    files = transpose(photoForPlot)[1];

    selectedIndex = selectIndexForLocation(files);
    addressOfFiles = await getAddressOfFiles(selectedIndex.values.toList());
    addresses = Map<int, String?>.fromIterable(
        List.generate(selectedIndex.keys.length, (i) => i),
        key: (item) => selectedIndex.keys.elementAt(item),
        // value: (item) => "${addressOfFiles
        //     .elementAt(item)
        //     ?.locality}, ${addressOfFiles.elementAt(item)?.thoroughfare}" );
        value: (item) => "${addressOfFiles.elementAt(item)?.locality}");
    return addresses;
  }

  Map<int, int> selectIndexForLocation(files) {
    Map<int, int> indexForSelectedFile = {};
    List<DateTime?> datetimes = List<DateTime?>.generate(files.length,
        (i) => global.infoFromFiles[files.elementAt(i)]?.datetime);
    datetimes = datetimes.whereType<DateTime>().toList();
    List<int> times =
        List<int>.generate(datetimes.length, (i) => datetimes[i]!.hour);
    Set<int> setOfTimes = times.toSet();
    for (int i = 0; i < setOfTimes.length; i++)
      indexForSelectedFile[setOfTimes.elementAt(i)] =
          (times.indexOf(setOfTimes.elementAt(i)));
    return indexForSelectedFile;
  }

  Future<List<Placemark?>> getAddressOfFiles(List<int> index) async {
    List<Placemark?> listOfAddress = [];
    for (int i = 0; i < index.length; i++) {
      Coordinate? coordinate =
          global.infoFromFiles[files[index.elementAt(i)]]!.coordinate;
      print(coordinate);
      if (coordinate == null) {
        listOfAddress.add(null);
      }
      Placemark? address = await AddressFinder.getAddressFromCoordinate(
          coordinate?.latitude, coordinate?.longitude);
      listOfAddress.add(address);
    }
    return listOfAddress;
  }


  void writeNote() {
    if(note != "")
      noteManager.writeNote(date, note);
    if(note =="")
      noteManager.tryDeleteNote(date);
  }

  void deleteNote(){
    noteManager.tryDeleteNote(date);
  }

  void setDate(String date) {
    this.date = date;
    print("date : ${this.date}");
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

  void setLastNavigationIndex(int index) {
    lastNavigationIndex = index;
  }

  void setSummaryOfGooglePhotoData(data) {
    summaryOfGooglePhotoData = data;
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
    // print("provider set zoomInAngle to $angle");
    this.note = note;
    notifyListeners();
  }

  @override
  void dispose() {
    print("provider disposed");
  }
}
