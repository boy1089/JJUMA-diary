import 'package:test_location_2nd/GoogleAccountManager.dart';
import 'package:test_location_2nd/PermissionManager.dart';

import 'GoogleAccountManager.dart';
import 'android_notifications_screen.dart';
import 'navigation.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:test_location_2nd/GoogleAccountManager.dart';
import "package:test_location_2nd/PermissionManager.dart";

class AndroidSettingsScreen extends StatelessWidget {
  // final GoogleAccountManager = googleAccountManager;
  //
  // static var googleAccountManager;
  var googleAccountManager;
  var permissionManager;
  AndroidSettingsScreen(GoogleAccountManager googleAccountManager, PermissionManager permissionManager, {
    Key? key,
  }) : this.googleAccountManager = googleAccountManager,
      this.permissionManager = permissionManager,
       super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SettingsList(
        platform: DevicePlatform.android,
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                onPressed: (context) => googleAccountManager.signInWithGoogle(),
                title: Text('Google Account'),
                description: Text('Log-in/out Google Account'),
                leading: Icon(Icons.login),
              ),
              SettingsTile(
                onPressed: (context) => permissionManager.getLocationPermission(),
                title: Text('Location'),
                description: Text('Location permission'),
                leading: Icon(Icons.location_on),
              ),
              SettingsTile(
                onPressed: (context) => permissionManager.getAudioPermission(),
                title: Text('Audio'),
                description: Text('Audio Record permission'),
                leading: Icon(Icons.audio_file),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void toNotificationsScreen(BuildContext context) {
    Navigation.navigateTo(
      context: context,
      screen: AndroidNotificationsScreen(),
      style: NavigationRouteStyle.material,
    );
  }
}