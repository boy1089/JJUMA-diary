import 'package:path_provider/path_provider.dart';
import 'package:test_location_2nd/Data/Directories.dart';
import 'package:test_location_2nd/Location/Coordinate.dart';
import 'dart:io';
import 'dart:convert';
import 'package:test_location_2nd/Util/global.dart' as global;

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
      key: (item) => item, value: (item) => false);
  static Coordinate referenceCoordinate = Coordinate(0, 0);
  static int minimumNumberOfPhoto = 0;
  static double minimumTime = 0.005;

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
        key: (item) => item.name, value: (item) => Settings.readItem(item));

    String json = jsonEncode(settings);
    await file.writeAsString(json);
  }

  static void readFile() async {
    final Directory? directory = await getApplicationDocumentsDirectory();
    final String filename = '${directory?.path}/settings.json';
    File file = File(filename);

    String json = await file.readAsString();
    Map mapFromJson = jsonDecode(json);

    mapFromJson.forEach((key, value) {
      writeItem(key, value);
    });
  }

  static void apply() {
    Directories.selectedDirectories = Settings.directories.keys
        .where((element) => Settings.directories[element]).toList() as List<String>;
    global.referenceCoordinate = Settings.referenceCoordinate;
    global.kMinimumTimeDifferenceBetweenImages_ZoomIn = Settings.minimumTime;
  }
}
