import 'package:permission_handler/permission_handler.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';

import 'android_notifications_screen.dart';
import '../navigation.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Util/Util.dart';

enum buttons { googleAccount, Location, Audio, Phone }

class AndroidSettingsScreen extends StatefulWidget {
  // final GoogleAccountManager = googleAccountManager;
  //
  // static var googleAccountManager;
  var googleAccountManager;
  PermissionManager permissionManager;
  AndroidSettingsScreen(
    PermissionManager permissionManager, {
    Key? key,
  })  : permissionManager = permissionManager,
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
    print("settingScreen build");
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
            title: Text("Common"),
            tiles: [
              SettingsTile(title: Text("Language"), onPressed: (context) {}),
              SettingsTile(
                title: Text("About"),
                onPressed: (context) {
                  showDialog(
                      context: (context),
                      builder: (BuildContext context) {
                        return AlertDialog(
                            content: Container(
                              height: physicalHeight / 5,
                              child: Row(
                                children: [
                                  Column(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("version"),
                                        Text("madeby"),
                                        Text("email")
                                      ]),
                                  Column(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(" : 1.0"),
                                        Text(" : Team ?"),
                                        Text(" : boytoboy0108@gmail.com")
                                      ]),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                  child: const Text("close"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  })
                            ]);
                      });
                },
              ),
              SettingsTile(title: Text("Reset"), onPressed: (context) {})
            ],
          ),
          //
          // SettingsSection(
          //   title: Text("Parameters"),
          //   tiles: [
          //     SettingsTile(
          //         title: Text("Reset Reference Coordinate"),
          //         onPressed: (context) {
          //           showDialog(
          //               context: (context),
          //               builder: (BuildContext context) {
          //                 return AlertDialog(
          //                     content: Text(
          //                         "Current coordinate will be set as reference coordiante, and contents will be updated with it."),
          //                     actions: [
          //                       TextButton(
          //                           child: const Text("ok"),
          //                           onPressed: () {
          //                             Navigator.of(context).pop();
          //                           }),
          //                       TextButton(
          //                           child: const Text("close"),
          //                           onPressed: () {
          //                             Navigator.of(context).pop();
          //                           })
          //                     ]);
          //               });
          //         }),
          //
          //     SettingsTile(
          //         title: Row(children: [Text("Minimum number of images for graph")]),
          //         onPressed: (context) {}),
          //     SettingsTile(
          //         title: Text("Minimum time bewteen images"),
          //         onPressed: (context) {})
          //   ],
          // )
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

          if (permissionManager.isLocationPermissionGranted) openAppSettings();
        }
        break;

      case buttons.Audio:
        {
          if (!permissionManager.isAudioPermissionGranted)
            await permissionManager.getAudioPermission();
          if (permissionManager.isAudioPermissionGranted) openAppSettings();
        }
        break;

      case buttons.Phone:
        {
          if (!permissionManager.isPhonePermissionGranted)
            await permissionManager.getPhonePermission();
          if (permissionManager.isPhonePermissionGranted) openAppSettings();
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
