import 'package:permission_handler/permission_handler.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';

import '../Location/Coordinate.dart';
import 'android_notifications_screen.dart';
import '../navigation.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Util/Util.dart';

import 'package:test_location_2nd/Data/Directories.dart';
import 'package:test_location_2nd/Settings.dart';

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
  Map directories = Settings.directories;

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
                                        Text("application"),
                                        Text("version"),
                                        Text("madeby"),
                                        Text("email")
                                      ]),
                                  Column(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(" : lateD"),
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
              SettingsTile(
                  title: Text("Term of Service"), onPressed: (context) {}),
            ],
          ),
          //
          SettingsSection(
            title: Text("Photo"),
            tiles: [
              SettingsTile(
                  title: Text("Reset Data"),
                  onPressed: (context) {
                    showDialog(
                        context: (context),
                        builder: (BuildContext context) {
                          return AlertDialog(content: Text("Existing analysis data will be reset.\nPlease restart the service afterward."),
                          actions : [
                              TextButton(
                              child : const Text("cancel"),
                          onPressed: (){
                                Navigator.of(context).pop();
                          },),
                            TextButton(
                            child : const Text("ok"),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                          )]);
                        });
                  }),
              SettingsTile(
                  title: Text("Directories"),
                  description: Column(
                      children: List<Widget>.generate(
                          Directories.directories.length, (i) {
                    String key = Settings.directories.keys.elementAt(i);
                    return CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(key),
                      onChanged: (flag) {
                        directories[key] = flag;
                        Settings.writeItem(items.directories, directories);
                        Settings.writeFile();
                        setState(() {});
                      },
                      value: directories[key],
                    );
                  }))),
              SettingsTile(
                  title: Text("Analysis settings"),
                  description: Column(children: [
                    ListTile(
                      title: Text("Reference Coordiante"),
                      subtitle: Text("${Settings.referenceCoordinate}"),
                      trailing: ElevatedButton(
                        child: Text("Get"),
                        onPressed: () async {
                          var position = await Settings.determinePosition();
                          Settings.writeItem(
                              items.referenceCoordinate,
                              Coordinate(position.latitude.abs(),
                                  position.longitude.abs()));
                          setState(() {});
                        },
                      ),
                    ),
                    ListTile(
                      title: Text("Minimum number of images in a day"),
                      // trailing :
                    ),
                    ListTile(
                      title: Text("Minimum time difference [min]"),
                      // trailing : Text('aa'),
                    ),
                  ])),
            ],
          )
        ],
      ),
    );
  }

  // void setDirectory() {
  //   print(selectedDirectories);
  //   print(
  //       Directories.directories.where((i) => selectedDirectories.elementAt(i)));
  // Directories.init()
  // }

  void toNotificationsScreen(BuildContext context) {
    Navigation.navigateTo(
      context: context,
      screen: AndroidNotificationsScreen(),
      style: NavigationRouteStyle.material,
    );
  }
}
