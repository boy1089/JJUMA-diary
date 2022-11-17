

import "package:external_path/external_path.dart";

class Directories {
  //
  static List<String> directories = [
    ExternalPath.DIRECTORY_DCIM,
    ExternalPath.DIRECTORY_PICTURES,
    ExternalPath.DIRECTORY_DOWNLOADS,
    ExternalPath.DIRECTORY_SCREENSHOTS,
    ExternalPath.DIRECTORY_DOCUMENTS,
  ];

  static List<String> selectedDirectories = [
  ];

  static Future<void> init(selectedDirectories) async {
    selectedDirectories = await getPathOfDirectory(selectedDirectories);
  }

  static Future<List<String>> getPathOfDirectory(List<String> selectedDirectories ) async {
    List<String> selectedDirectories_path = [];
    for(int i = 0; i< selectedDirectories.length; i++){
      selectedDirectories_path.add(await ExternalPath.getExternalStoragePublicDirectory(selectedDirectories.elementAt(i)));
    }
    return selectedDirectories_path;
  }

}