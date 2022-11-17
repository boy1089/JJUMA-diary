import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:intl/intl.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';

class AudioRecorder {
  late PermissionManager permissionManager;

  var _cacheCount = 0;
  final _audioRecorder = Record();
  Location location = Location();

  AudioRecorder(this.permissionManager) {
    debugPrint("AudioRecorder instance created");
    // init();
  }

  Future<int> init() async {
    print("AudioRecorder initializing ...");
    if (permissionManager.isAudioPermissionGranted) {
      print("AudioRecorder initializing .. Audio permission not allowed");
      return 0;
    }
    await createDirectory();
    location.enableBackgroundMode(enable: true);
    _enableLogging();
    return 0;
  }

  void _enableLogging() async {
    location.onLocationChanged.listen((LocationData currentLocation) {
      _cacheCount +=1;
      print("audioRecorder, $_cacheCount");

      if (_cacheCount > 500) {
        _cacheCount = 0;
        writeAndStartRecord();
      }
    });
  }

  Future createDirectory() async {
    final Directory? directory = await getApplicationDocumentsDirectory();
    final String folder = '${directory?.path}/audioData';
    bool isFolderExists = await Directory(folder).exists();

    if (!isFolderExists) {
      Directory(folder).create(recursive: true);
    }
  }

  void writeAndStartRecord() async {
    final Directory? directory = await getApplicationDocumentsDirectory();
    final String folder = '${directory?.path}/audioData';

    bool isRecording = await _audioRecorder.isRecording();
    if (isRecording) await _audioRecorder.stop();

    await _audioRecorder.start(
      path:
      '${folder}/${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}_audio.m4a',
      encoder: AudioEncoder.aacLc, // by default
      bitRate: 128000, // by default
      samplingRate: 44100, // by default
    );
  }

}
