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

  static void init() async {
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
        }, value: (item) => Settings.readItem(item));

    settings['referenceCoordinate'] = {"latitude": settings['referenceCoordinate'].latitude,
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
      writeItem(items.values.byName(key), value);
      if(key == 'referenceCoordinate') {
        Coordinate referenceCoordinate = Coordinate(value['latitude'], value['longitude']);
        writeItem(items.values.byName(key), referenceCoordinate);
      }
    });
    print(Settings.directories);
  }

  static void apply() {
    // irectories = Settings.directories.keys
    //     .where((element) => Settings.directories[element]).toList() as List<String>;
    global.referenceCoordinate = Settings.referenceCoordinate;
    global.kMinimumTimeDifferenceBetweenImages_ZoomIn = Settings.minimumTime;
  }

}
