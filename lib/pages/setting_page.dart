import 'android_notifications_screen.dart';
import '../navigation.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:jjuma.d/Settings.dart';
import 'package:url_launcher/url_launcher.dart';

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
      "https://www.termsfeed.com/live/c94e4d69-3927-4e4c-9799-3019237c288c";
  String email = "jjuma.d.info@gmail.com";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
        ),
        // backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.black12,
      body: SettingsList(

        platform: DevicePlatform.android,
        sections: [
          SettingsSection(
            title: const Text("Common"),
            tiles: [
              // SettingsTile(title: Text("Language"), onPressed: (context) {}),
              SettingsTile(
                title: const Text("About"),
                onPressed: (context) {
                  showAboutDialog(
                      context: context,
                      applicationIcon: const Image(
                        image: AssetImage('images/playstore.png'),
                        width: 40,
                        height: 40,
                      ),
                      applicationVersion: "version 1.2",
                      applicationName: "jjuma.d",
                      anchorPoint: const Offset(0, 0),
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
                  title: const Text("Term of Service"),
                  onPressed: (context) {
                    launch(urlOfTerm);
                  }),
            ],
          ),
          //
          // SettingsSection(
          //   title: Text("Photo"),
          //   tiles: [
          //     SettingsTile(
          //         title: Text("Directories"),
          //         description: Column(
          //             children: List<Widget>.generate(
          //                 Directories.directories.length, (i) {
          //           String key = Settings.directories.keys.elementAt(i);
          //           return CheckboxListTile(
          //             controlAffinity: ListTileControlAffinity.leading,
          //             title: Text(key),
          //             onChanged: (flag) {
          //               directories[key] = flag;
          //               Settings.writeItem(items.directories, directories);
          //               Settings.writeFile();
          //               setState(() {});
          //             },
          //             value: directories[key],
          //           );
          //         }))),
          //   ],
          // )
        ],
      ),
    );
  }

  void toNotificationsScreen(BuildContext context) {
    Navigation.navigateTo(
      context: context,
      screen: const AndroidNotificationsScreen(),
      style: NavigationRouteStyle.material,
    );
  }
}

String termOfService = "";
