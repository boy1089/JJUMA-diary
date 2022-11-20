import 'package:path_provider/path_provider.dart';
import 'package:lateDiary/Data/Directories.dart';
import 'package:lateDiary/Location/Coordinate.dart';
import 'dart:io';
import 'dart:convert';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:geolocator/geolocator.dart';

enum items {
  language,
  directories,
  referenceCoordinate,
  minimumNuberOfPhoto,
  minimumTime,
}

class Settings {
  static String language = 'kor';
  static Map directories = Map.fromIterable(Directories.directories,
      key: (item) => item, value: (item) => true);
  static Coordinate referenceCoordinate = Coordinate(0, 0);
  static int minimumNumberOfPhoto = 0;
  static double minimumTime = 0.005;

  static void init() async {
    var currentCoordinate = await determinePosition();
    referenceCoordinate = Coordinate(
        currentCoordinate.latitude.abs(), currentCoordinate.longitude.abs());
    await readFile();
    apply();
  }

  static dynamic readItem(item) {
    switch (item) {
      case items.language:
        return Settings.language;
      case items.directories:
        return Settings.directories;
      case items.referenceCoordinate:
        return Settings.referenceCoordinate;
      case items.minimumNuberOfPhoto:
        return Settings.minimumNumberOfPhoto;
      case items.minimumTime:
        return Settings.minimumTime;
    }
  }

  static dynamic writeItem(item, value) {
    switch (item) {
      case items.language:
        Settings.language = value;
        break;
      case items.directories:
        Settings.directories = value;
        break;
      case items.referenceCoordinate:
        Settings.referenceCoordinate = value;
        break;
      case items.minimumNuberOfPhoto:
        Settings.minimumNumberOfPhoto = value;
        break;
      case items.minimumTime:
        Settings.minimumTime = value;
        break;
    }
  }

  static void writeFile() async {
    final Directory? directory = await getApplicationDocumentsDirectory();
    final String filename = '${directory?.path}/settings.json';
    File file = File(filename);
    Map settings = Map.fromIterable(items.values,
        key: (item) {
          return item.toString().split('.').elementAt(1);
        },
        value: (item) => Settings.readItem(item));

    settings['referenceCoordinate'] = {
      "latitude": settings['referenceCoordinate'].latitude,
      "longitude": settings['referenceCoordinate'].longitude
    };
    print('aaa');
    String json = jsonEncode(settings);
    await file.writeAsString(json);
  }

  static Future<void> readFile() async {
    final Directory? directory = await getApplicationDocumentsDirectory();
    final String filename = '${directory?.path}/settings.json';
    File file = File(filename);

    bool isExist = await file.exists();
    if (!isExist) return;

    String json = await file.readAsString();
    Map mapFromJson = jsonDecode(json);
    mapFromJson.forEach((key, value) {
      print("read settings.. $key, $value");
      if (key == 'referenceCoordinate') {
        Coordinate referenceCoordinate =
            Coordinate(value['latitude'], value['longitude']);
        writeItem(items.values.byName(key), referenceCoordinate);
        return;
      }

      writeItem(items.values.byName(key), value);
    });
    print(Settings.directories);
  }

  static void apply() {
    // irectories = Settings.directories.keys
    //     .where((element) => Settings.directories[element]).toList() as List<String>;
    global.referenceCoordinate = Settings.referenceCoordinate;
    global.kMinimumTimeDifferenceBetweenImages_ZoomIn = Settings.minimumTime;
  }

  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
