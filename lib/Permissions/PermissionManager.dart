import 'package:location/location.dart';

import 'package:record/record.dart';

class PermissionManager{

  PermissionManager(){
    print("permission Manager created");
  }

  void getLocationPermission() async {
    var location = Location();
    var _serviceEnabled;
    var _permissionGranted;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      if (!(await _serviceEnabled)) return;

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
      print('permission?');
      if (await _permissionGranted == PermissionStatus.denied) return;
      print('ok!');
  }

  void getAudioPermission() async{
    final _audioRecorder = Record();
    if (await _audioRecorder.hasPermission() == false) return;
  }
  void getStoragePermission() async{
    final _audioRecorder = Record();
    if (await _audioRecorder.hasPermission() == false) return;
  }


}