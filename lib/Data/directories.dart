import "package:external_path/external_path.dart";
import "package:jjuma.d/Util/global.dart";

class Directories {

  static List<String> directories = [
    ExternalPath.DIRECTORY_DCIM,
    ExternalPath.DIRECTORY_PICTURES,
    ExternalPath.DIRECTORY_DOWNLOADS,
    ExternalPath.DIRECTORY_SCREENSHOTS,
    ExternalPath.DIRECTORY_DOCUMENTS,
  ];

  static List<String> selectedDirectories = [];

  static Future<void> init(directories) async {
    print("directories, init");
      selectedDirectories = await getPathOfDirectory(directories);
    print("selectedDirectories : $selectedDirectories");

  }

  static Future<List<String>> getPathOfDirectory(
      List<String> selectedDirectories) async {

    List<String> selectedDirectories_path = [];
    for (int i = 0; i < selectedDirectories.length; i++) {
      print("Directories, ${selectedDirectories.elementAt(i)}}");
      String path = await ExternalPath.getExternalStoragePublicDirectory(
          selectedDirectories.elementAt(i));
      selectedDirectories_path.add(
          path);
      // selectedDirectories_path.add(
      //     path + '/*');
      // selectedDirectories_path.add(
      //     path + '/*/*');

    }
    return selectedDirectories_path;
  }
}
