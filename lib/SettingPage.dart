import 'package:test_location_2nd/GoogleAccountManager.dart';

import 'GoogleAccountManager.dart';
import 'android_notifications_screen.dart';
import 'navigation.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:test_location_2nd/GoogleAccountManager.dart';

class AndroidSettingsScreen extends StatelessWidget {
  // final GoogleAccountManager = googleAccountManager;
  //
  // static var googleAccountManager;
  var googleAccountManager;
  AndroidSettingsScreen(GoogleAccountManager googleAccountManager, {
    Key? key,
  }) : this.googleAccountManager = googleAccountManager,
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
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Connected devices'),
                description: Text('Bluetooth, pairing'),
                leading: Icon(Icons.devices_other),
              ),
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Apps'),
                description: Text('Assistant, recent apps, default apps'),
                leading: Icon(Icons.apps),
              ),
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Notifications'),
                description: Text('Notification history, conversations'),
                leading: Icon(Icons.notifications_none),
              ),
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Battery'),
                description: Text('100%'),
                leading: Icon(Icons.battery_full),
              ),
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Storage'),
                description: Text('30% used - 5.60 GB free'),
                leading: Icon(Icons.storage),
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