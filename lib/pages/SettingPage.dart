import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';

import 'android_notifications_screen.dart';
import '../navigation.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:test_location_2nd/global.dart' as global;

class AndroidSettingsScreen extends StatefulWidget {
  // final GoogleAccountManager = googleAccountManager;
  //
  // static var googleAccountManager;
  var googleAccountManager;
  PermissionManager permissionManager;
  AndroidSettingsScreen(
    GoogleAccountManager googleAccountManager,
    PermissionManager permissionManager, {
    Key? key,
  })  : this.googleAccountManager = googleAccountManager,
        this.permissionManager = permissionManager,
        super(key: key);

  @override
  State<AndroidSettingsScreen> createState() => _AndroidSettingsScreenState();
}

class _AndroidSettingsScreenState extends State<AndroidSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    print("setting page build : ${global.currentUser}");
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
            tiles: [
              SettingsTile(
                onPressed: (context) async {
                  await _onPressed(context);
                  setState(() {});
                },
                title: Text('Google Account'),
                description: global.currentUser == null
                    ? Text('Sign in')
                    : Text('Logged in with ${global.currentUser?.email}'),
                leading: Container(
                    width: 30,
                    height: 30,
                    child: Image.network(
                        'http://pngimg.com/uploads/google/google_PNG19635.png',
                        fit: BoxFit.cover)),
              ),

              SettingsTile(
                onPressed: (context) =>
                    widget.permissionManager.getLocationPermission(),
                title: Text('Location'),
                description: Text('Location permission'),
                leading: Icon(Icons.location_on),
              ),
              SettingsTile(
                onPressed: (context) =>
                    widget.permissionManager.getAudioPermission(),
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

  Future _onPressed(BuildContext context) async {
    if (global.currentUser == null) {
      await GoogleAccountManager.signInWithGoogle();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Signed in with ${global.currentUser?.email}")));
    } else {
      await GoogleAccountManager.signOut(context: context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signed out of google account")));
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
