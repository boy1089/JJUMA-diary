import 'package:flutter/material.dart';
import 'package:lateDiary/Note/NoteManager.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/Photo/PhotoDataManager.dart';

import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/Location/AddressFinder.dart';
import 'package:lateDiary/Location/Coordinate.dart';
import 'package:geocoding/geocoding.dart';

import '../Data/data_manager_interface.dart';

class DayPageStateProvider with ChangeNotifier {

  PhotoDataManager photoDataManager = PhotoDataManager();
  NoteManager noteManager = NoteManager();

  double zoomInAngle = 0.0;
  bool isZoomIn = false;
  bool isBottomNavigationBarShown = true;
  bool isZoomInImageVisible = false;
  String date = formatDate(DateTime.now());

  List<String> availableDates = [];
  List photoForPlot = [];
  dynamic photoData = [[]];
  List<List<dynamic>> photoDataForPlot = [[]];
  Map<int, String?> addresses = {};
  String note = "";

  double keyboardSize = 300;
  DataManagerInterface dataManager;
  DayPageStateProvider(this.dataManager){
    print("DayPageStateProvider created");
  }

  Future<void> updateDataForUi() async {
    photoForPlot = [];
    photoDataForPlot = [];
    photoData = [[]];

    photoData = await updatePhotoData();
    photoForPlot = selectPhotoForPlot(photoData, true);

    // //convert data type..
    photoDataForPlot = List<List>.generate(
        photoForPlot.length, (index) => photoForPlot.elementAt(index));

    // addresses = await updateAddress();

    note = await noteManager.readNote(date);
    print("updateUi done");
    // notifyListeners();
  }

  Future updatePhotoData() async {
    List<List<dynamic>> data = await photoDataManager.getPhotoOfDate(date);
    photoData = modifyListForPlot(data, executeTranspose: true);
    return photoData;
  }


  List selectPhotoForPlot(List input, bool sampleImages) {
    if (input[0] == null) return photoForPlot;
    if (input[0].length == 0) return photoForPlot;

    photoForPlot.add([input.first[0], input.first[1], input.first[2], input.first[3], true]);
    int j = 0;
    int k = 0;

    double timeDiffForZoomIn = 0.000;
    double timeDiffForZoomOut =
        global.kMinimumTimeDifferenceBetweenImages_ZoomOut;
    if (sampleImages)
      // timeDiffForZoomIn = global.kMinimumTimeDifferenceBetweenImages_ZoomIn;
      timeDiffForZoomIn = 0.005;

    for (int i = 1; i < input.length - 2; i++) {
      double timeDifferenceBetweenImagesForZoomOut =
          (input[i][0] - photoForPlot[k][0]).abs();
      double timeDifferenceBetweenImagesForZoomIn =
          (input[i][0] - photoForPlot[j][0]).abs();

      if (timeDifferenceBetweenImagesForZoomIn > timeDiffForZoomIn) {
        print(
            "$i/ ${input.length}, $j, $k, $timeDifferenceBetweenImagesForZoomIn");
        bool isGoodForZoomOut =
            timeDifferenceBetweenImagesForZoomOut > timeDiffForZoomOut;
        photoForPlot
            .add([input[i][0], input[i][1], input[i][2], input[i][3], isGoodForZoomOut]);
        j += 1;

        if (isGoodForZoomOut) {
          k = j;
        }
      }
    }

    photoForPlot.add([input.last[0], input.last[1], input.last[2], input.last[3], true]);
    return photoForPlot;
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
