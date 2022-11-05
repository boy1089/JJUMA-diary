import 'package:permission_handler/permission_handler.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';

import 'android_notifications_screen.dart';
import '../navigation.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:test_location_2nd/Util/global.dart' as global;

enum buttons { googleAccount, Location, Audio, Phone}

class AndroidSettingsScreen extends StatefulWidget {
  // final GoogleAccountManager = googleAccountManager;
  //
  // static var googleAccountManager;
  var googleAccountManager;
  PermissionManager permissionManager;
  AndroidSettingsScreen(
    PermissionManager permissionManager, {
    Key? key,
  })  :
        this.permissionManager = permissionManager,
        super(key: key);

  @override
  State<AndroidSettingsScreen> createState() =>
      _AndroidSettingsScreenState(permissionManager);
}

class _AndroidSettingsScreenState extends State<AndroidSettingsScreen> {
  late PermissionManager permissionManager;
  _AndroidSettingsScreenState(permissionManager) {
    this.permissionManager = permissionManager;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.black54),
        ),
        backgroundColor: Colors.white,
      ),
      body: SettingsList(
        platform: DevicePlatform.android,
        sections: [
          SettingsSection(
            title : Text("Common"),
            tiles : [SettingsTile(
              leading : Icon(Icons.language_outlined, color: Colors.black26, size: 30),
              title : Text("Language"),
            )]
          ),

          SettingsSection(
            title : Text('Permissions'),
            tiles: [

              SettingsTile(
                onPressed: (context) async {
                  await _onPressed(context, buttons.Location);
                  setState(() {});
                },
                title: Text('Location'),
                description: permissionManager.isLocationPermissionGranted
                    ? Text('Current location is under recording..')
                    : Text(
                        'Allow location permission to record current location'),
                leading: Icon(Icons.location_on, color: Colors.blue),
              ),
              SettingsTile(
                onPressed: (context) async {
                  await _onPressed(context, buttons.Audio);
                  setState(() {});
                },
                title: Text('Audio'),
                description: permissionManager.isAudioPermissionGranted
                    ? Text('Microphone is recording..')
                    : Text(
                        'Allow audio permission to record voice with photos'),
                leading: Icon(Icons.audio_file, color: Colors.orange),
              ),
              SettingsTile(
                onPressed: (context) async {
                  await _onPressed(context, buttons.Phone);
                  setState(() {});
                },
                title: Text('Phone'),
                description: permissionManager.isPhonePermissionGranted
                    ? Text('Call history is under fetching..')
                    : Text(
                    'Allow phone permission to get call history'),
                leading: Icon(Icons.phone_outlined, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future _onPressed(BuildContext context, button) async {
    switch (button) {


      case buttons.Location:
        {
          if (!permissionManager.isLocationPermissionGranted)
            await permissionManager.getLocationPermission();

          if (permissionManager.isLocationPermissionGranted)
            openAppSettings();
        }
        break;

      case buttons.Audio:
        {
          if (!permissionManager.isAudioPermissionGranted)
            await permissionManager.getAudioPermission();
          if (permissionManager.isAudioPermissionGranted)
            openAppSettings();
        }
        break;

      case buttons.Phone:
        {
          if (!permissionManager.isPhonePermissionGranted)
            await permissionManager.getPhonePermission();
          if (permissionManager.isPhonePermissionGranted)
            openAppSettings();
        }
        break;

    }


  }

  void toNotificationsScreen(BuildContext context) {
    Navigation.navigateTo(
      context: context,
      screen: AndroidNotificationsScreen(),
      style: NavigationRouteStyle.material,
    );
  }
}
