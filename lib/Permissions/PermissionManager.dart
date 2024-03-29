// import 'package:location/location.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as PermissionHandler;
// import 'package:record/record.dart';
import 'package:jjuma.d/Util/global.dart' as global;

class PermissionManager {
  bool isLocationPermissionGranted = false;
  bool isAudioPermissionGranted = false;
  bool isStoragePermissionGranted = false;
  bool isPhonePermissionGranted = false;
  bool isMediaLibraryPermissionGranted = false;
  bool isCameraPermissionGranted = false;

  Future<void> init() async {

    await checkPermissions();
    if(!isStoragePermissionGranted)
    await getStoragePermission();
    if(!isMediaLibraryPermissionGranted && (global.kOs =='ios'))
      await getMediaLibraryPermission();

    debugPrint("permissionManager initiation done");
  }

 Future<void> checkPermissions() async {
    await checkStoragePermission();
    if(global.kOs=="ios")
    await checkMediaLibraryPermission();
  }

  Future<void> checkMediaLibraryPermission() async{
    isMediaLibraryPermissionGranted = await PermissionHandler.Permission.mediaLibrary.isGranted;
    print("PermissionManager, checkMediaLibraryPermission : $isMediaLibraryPermissionGranted");
  }

  void checkCameraPermission() async{
    isCameraPermissionGranted = await PermissionHandler.Permission.camera.isGranted;
    print("PermissionManager, checkCameraPermission : $isCameraPermissionGranted");
  }

  Future<void> checkLocationPermission() async{
    isLocationPermissionGranted = await PermissionHandler.Permission.location.isGranted;
    print("PermissionManager, checkLocationPermission : $isLocationPermissionGranted");
  }

  void checkAudioPermission() async{
    isAudioPermissionGranted = await PermissionHandler.Permission.microphone.isGranted;
    if (kDebugMode) {
      print("PermissionManager, checkAudioPermission : $isAudioPermissionGranted");
    }
  }

  Future<void> checkStoragePermission() async {
    isStoragePermissionGranted = await PermissionHandler.Permission.storage.isGranted;
    print("PermissionManager, checkStoragePermission : $isStoragePermissionGranted");
  }

  // void checkPhonePermission() async {
  //   isPhonePermissionGranted = await PermissionHandler.Permission.phone.isGranted;
  //   print("PermissionManager, checkPhonePermission : $isAudioPermissionGranted");
  // }

  Future getLocationPermission() async {
    if (!isLocationPermissionGranted){
      await PermissionHandler.Permission.location.request();
      // await PermissionHandler.Permission.location.
      // await PermissionHandler.Permission.locationAlways.request();
    }
    if (isLocationPermissionGranted){
      await PermissionHandler.Permission.locationAlways.value;
    }

    isLocationPermissionGranted = await PermissionHandler.Permission.location.isGranted;
    print("PermissionManager, getLocationPermission : $isLocationPermissionGranted");
  }

  // Future getAudioPermission() async {
  //   final audioRecorder = Record();
  //   if (await audioRecorder.hasPermission() == false) return;
  //
  // }

  Future<void> getStoragePermission() async {
    if (!isStoragePermissionGranted){
      await PermissionHandler.Permission.storage.request();
    }
    if (!isStoragePermissionGranted){
      await PermissionHandler.Permission.manageExternalStorage.request();

    }

    isStoragePermissionGranted = await PermissionHandler.Permission.storage.isGranted;
    print("PermissionManager, getStoragePermission : $isStoragePermissionGranted");
  }

  Future<void> getMediaLibraryPermission() async{
    if (!isMediaLibraryPermissionGranted){
      await PermissionHandler.Permission.mediaLibrary.request();
    }
    isMediaLibraryPermissionGranted = await PermissionHandler.Permission.mediaLibrary.isGranted;
    print("PermissionManager, getMediaLibraryPermission : $isMediaLibraryPermissionGranted");
  }

  // Future getPhonePermission() async {
  //   if (!isPhonePermissionGranted){
  //     PermissionHandler.Permission.phone.request();
  //   }
  //   isPhonePermissionGranted = await PermissionHandler.Permission.phone.isGranted;
  //   print("PermissionManager, getPhonePermission : $isPhonePermissionGranted");
  // }
  Future getCameraPermission() async {
    if (!isCameraPermissionGranted){
      await PermissionHandler.Permission.camera.request();
    }
    isCameraPermissionGranted = await PermissionHandler.Permission.camera.isGranted;
    print("PermissionManager, getCameraPermission : $isCameraPermissionGranted");
  }


}
