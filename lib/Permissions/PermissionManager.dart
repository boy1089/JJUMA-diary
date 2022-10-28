import 'package:location/location.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as PermissionHandler;
import 'package:record/record.dart';

class PermissionManager {
  bool isLocationPermissionGranted = false;
  bool isAudioPermissionGranted = false;
  bool isStoragePermissionGranted = false;
  bool isPhonePermissionGranted = false;

  PermissionManager() {
    debugPrint("permission Manager created");
    checkPermissions();
    getStoragePermission();

  }

  void checkPermissions() async {
    checkLocationPermission();
    checkAudioPermission();
    checkStoragePermission();
    checkPhonePermission();
  }

  void checkLocationPermission() async{
    isLocationPermissionGranted = await PermissionHandler.Permission.locationAlways.isGranted;
    print("PermissionManager, checkLocationPermission : $isLocationPermissionGranted");
  }

  void checkAudioPermission() async{
    isAudioPermissionGranted = await PermissionHandler.Permission.microphone.isGranted;
    if (kDebugMode) {
      print("PermissionManager, checkAudioPermission : $isAudioPermissionGranted");
    }
  }

  void checkStoragePermission() async {
    isStoragePermissionGranted = await PermissionHandler.Permission.storage.isGranted;
    print("PermissionManager, checkStoragePermission : $isStoragePermissionGranted");

  }

  void checkPhonePermission() async {
    isPhonePermissionGranted = await PermissionHandler.Permission.phone.isGranted;
    print("PermissionManager, checkPhonePermission : $isAudioPermissionGranted");
  }

  Future getLocationPermission() async {
    if (!isLocationPermissionGranted){
      PermissionHandler.Permission.location.request();
      PermissionHandler.Permission.locationAlways.request();
    }
    if (isLocationPermissionGranted){
      PermissionHandler.Permission.locationAlways.value;
    }


      isLocationPermissionGranted = await PermissionHandler.Permission.locationAlways.isGranted;
    print("PermissionManager, getLocationPermission : $isLocationPermissionGranted");
  }

  Future getAudioPermission() async {
    final audioRecorder = Record();
    if (await audioRecorder.hasPermission() == false) return;

  }

  void getStoragePermission() async {
    if (!isStoragePermissionGranted){
      PermissionHandler.Permission.storage.request();
    }
    if (!isStoragePermissionGranted){
      PermissionHandler.Permission.manageExternalStorage.request();
    }

    isStoragePermissionGranted = await PermissionHandler.Permission.storage.isGranted;
    print("PermissionManager, getStoragePermission : $isStoragePermissionGranted");
  }

  Future getPhonePermission() async {
    if (!isPhonePermissionGranted){
      PermissionHandler.Permission.phone.request();
    }
    isPhonePermissionGranted = await PermissionHandler.Permission.phone.isGranted;
    print("PermissionManager, getPhonePermission : $isPhonePermissionGranted");
  }


}
