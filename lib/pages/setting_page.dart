import 'package:permission_handler/permission_handler.dart';
import 'package:lateDiary/Permissions/PermissionManager.dart';

import '../Location/coordinate.dart';
import 'android_notifications_screen.dart';
import '../navigation.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/Util/Util.dart';

import 'package:lateDiary/Data/directories.dart';
import 'package:lateDiary/Settings.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:numberpicker/numberpicker.dart';

enum buttons { googleAccount, Location, Audio, Phone }

class AndroidSettingsScreen extends StatefulWidget {
  static String id = 'setting';
  AndroidSettingsScreen({
    Key? key,
  })  :
        super(key: key);

  @override
  State<AndroidSettingsScreen> createState() =>
      _AndroidSettingsScreenState();
}

class _AndroidSettingsScreenState extends State<AndroidSettingsScreen> {
  Map directories = Settings.directories;
  String urlOfTerm =
      "https://www.termsfeed.com/live/c780905a-d580-4e20-83a0-3f88929eca2e";
  String email = "latediary.info@gmail.com";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          // style: TextStyle(color: Colors.black54),
        ),
        // backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.black12,
      body: SettingsList(

        platform: DevicePlatform.android,
        sections: [
          SettingsSection(
            title: Text("Common"),
            tiles: [
              // SettingsTile(title: Text("Language"), onPressed: (context) {}),
              SettingsTile(
                title: Text("About"),
                onPressed: (context) {
                  showAboutDialog(
                      context: context,
                      applicationIcon: const Image(
                        image: AssetImage('images/playstore.png'),
                        width: 40,
                        height: 40,
                      ),
                      applicationVersion: "version 1.0",
                      applicationName: "lateD",
                      anchorPoint: Offset(0, 0),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  launchUrl(Uri.parse(
                                      'mailto:$email?subject=&body='));
                                },
                                child: Text(email)),
                          ],
                        ),
                      ]);
                },
              ),
              SettingsTile(
                  title: Text("Term of Service"),
                  onPressed: (context) {
                    launch(urlOfTerm);
                  }),
            ],
          ),
          //
          SettingsSection(
            title: Text("Photo"),
            tiles: [
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
            ],
          )
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

String termOfService = "";
