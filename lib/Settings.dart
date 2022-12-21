import 'package:path_provider/path_provider.dart';
import 'package:lateDiary/Data/directories.dart';
import 'package:lateDiary/Location/coordinate.dart';
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
  static Map directories = { for (var item in Directories.directories) item : true };
  static int minimumNumberOfPhoto = 0;
  static double minimumTime = 0.005;

  static Future<void> init() async {
    await readFile();
    apply();
  }

  static dynamic readItem(item) {
    switch (item) {
      case items.language:
        return Settings.language;
      case items.directories:
        return Settings.directories;

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

      case items.minimumNuberOfPhoto:
        Settings.minimumNumberOfPhoto = value;
        break;
      case items.minimumTime:
        Settings.minimumTime = value;
        break;
    }
  }

  static void writeFile() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filename = '${directory.path}/settings.json';
    File file = File(filename);
    Map settings = { for (var item in items.values) item.toString().split('.').elementAt(1) : Settings.readItem(item) };

    settings['referenceCoordinate'] = {
      "latitude": settings['referenceCoordinate'].latitude,
      "longitude": settings['referenceCoordinate'].longitude
    };
    print('aaa');
    String json = jsonEncode(settings);
    await file.writeAsString(json);
  }

  static Future<void> readFile() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filename = '${directory.path}/settings.json';
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
    global.kMinimumTimeDifferenceBetweenImages_ZoomIn = Settings.minimumTime;
  }

}
