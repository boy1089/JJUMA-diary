import 'package:flutter/material.dart';
import 'package:lateDiary/Permissions/PermissionManager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:flutter_shake_animated/flutter_shake_animated.dart';

class PermissionPage extends StatefulWidget {
  late PermissionManager permissionManager;
  PermissionPage(this.permissionManager, {Key? key}) : super(key: key);

  bool isOkToProceed = false;

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  bool isOkToProceed = false;
  bool shakeButton = false;
  @override
  void initState() {
    checkOkToProceed();
  }

  Future<void> checkOkToProceed() async {
    await checkPermission();
    isOkToProceed = widget.permissionManager.isMediaLibraryPermissionGranted &
        widget.permissionManager.isLocationPermissionGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [


              Offstage(
                offstage:
                    widget.permissionManager.isStoragePermissionGranted,
                child: const Text(
                  "Access to photo is needed to display photo in the device.",
                  style: const TextStyle(
                      fontSize: 20, color: global.kColor_backgroundText),
                ),
              ),

              SizedBox(height: 50),

              Offstage(
                offstage: widget.permissionManager.isLocationPermissionGranted,
                child: const Text(
                    "Access to location is needed to analyze the meta data of photo.",
                    style: TextStyle(
                        fontSize: 20, color: global.kColor_backgroundText)),
              ),
              SizedBox(height: 50),

              ElevatedButton(
                  onPressed: () async {
                    await openAppSettings();
                    await onClicked();
                    setState(() {});
                  },
                  child: const Text("Allow permission")),

              ShakeWidget(
                duration: Duration(milliseconds: global.animationTime),
                shakeConstant: ShakeHorizontalConstant1(),
                autoPlay: shakeButton,
                child: ElevatedButton(
                    onPressed: () async {
                      await checkOkToProceed();
                      if (isOkToProceed) {
                        Navigator.pop(context, true);
                        // Navigation.navigateTo(
                        //     context: context,
                        //     screen: MyApp(),
                        //     style: NavigationRouteStyle.material);
                      }

                      setState(() {
                        shakeButton = true;
                      });
                      await Future.delayed(Duration(milliseconds: 300));
                      setState(() {
                        shakeButton = false;
                      });
                    },
                    child: Text("continue")),
              ),
            ]));
  }

  Future<void> onClicked() async {
    await checkPermission();
    checkOkToProceed();
  }

  Future<void> checkPermission() async {
    await widget.permissionManager.checkLocationPermission();
    await widget.permissionManager.checkMediaLibraryPermission();
    return;
  }
}
