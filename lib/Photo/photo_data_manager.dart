import 'package:JJUMA.d/Data/file_info_model.dart';
import 'package:JJUMA.d/Util/DateHandler.dart';
import 'package:JJUMA.d/Util/Util.dart';
import 'package:JJUMA.d/Data/data_manager_interface.dart';
import 'package:JJUMA.d/Util/global.dart' as global;

class PhotoDataManager {
  DataManagerInterface dataManager = DataManagerInterface(global.kOs);

  Future getPhotoOfDate(String date) async {
    List<int?> indexOfDate =
        List<int?>.generate(dataManager.dates.length, (i) {
      if (dataManager.dates.elementAt(i) == date) return i;
      return null;
    });

    indexOfDate = indexOfDate.whereType<int>().toList();
    List files = dataManager.infoFromFiles.keys.toList();
    // List files = dataManager.filesInfo.data.header.toList().sublist(1);

    List filesOfDate = List.generate(
        indexOfDate.length, (i) => files.elementAt(indexOfDate.elementAt(i)!));

    List dateOfDate = List.generate(
        indexOfDate.length,
        (i) => formatDatetime(dataManager.datetimes
            .elementAt(indexOfDate.elementAt(i)!)!));

    List distanceOfDate = List.generate(
        filesOfDate.length,
        (i) => floorDistance(dataManager.infoFromFiles[filesOfDate[i]]!.distance));

    List list = transpose([dateOfDate, filesOfDate, distanceOfDate]);
    // List list = transpose([dateOfDate, filesOfDate]);

    list.sort((a, b) => int.parse(a[0].substring(9, 13))
        .compareTo(int.parse(b[0].substring(9, 13))));
    print("getPhotoOfDate, $list");

    return transpose(list);
  }
}
