import 'package:location/location.dart';
import 'package:flutter/foundation.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class PermissionManager {
  PermissionManager() {
    debugPrint("permission Manager created");
  }

  void getLocationPermission() async {
    var location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    if (!(serviceEnabled)) return;

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    debugPrint('permission?');
    if (permissionGranted == PermissionStatus.denied) return;
    debugPrint('ok!');
  }

  void getAudioPermission() async {
    final audioRecorder = Record();
    if (await audioRecorder.hasPermission() == false) return;
  }

  void getStoragePermission() async {
    final audioRecorder = Record();
    if (await audioRecorder.hasPermission() == false) return;
  }
}
