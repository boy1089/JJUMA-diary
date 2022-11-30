import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/Data/DataManager.dart';
import 'package:lateDiary/Data/DataManagerInterface.dart';
import 'package:lateDiary/Util/global.dart' as global;

class PhotoDataManager {

  DataManagerInterface dataManager = DataManagerInterface(global.kOs);


  Future getPhotoOfDate(String date) async {
    List<int?> indexOfDate = List<int?>.generate(dataManager.dates.length, (i) {
      if (dataManager.dates.elementAt(i) == date) return i;
      return null;
    });

    indexOfDate = indexOfDate.whereType<int>().toList();
    List files = dataManager.infoFromFiles.keys.toList();
    List filesOfDate = List.generate(
        indexOfDate.length, (i) => files.elementAt(indexOfDate.elementAt(i)!));

    List dateOfDate = List.generate(
        indexOfDate.length,
        (i) => formatDatetime(
            dataManager.datetimes.elementAt(indexOfDate.elementAt(i)!)));


    List list = transpose([dateOfDate, filesOfDate]);
    list.sort((a, b) => int.parse(a[0].substring(9, 13))
        .compareTo(int.parse(b[0].substring(9, 13))));

    print("getPhotoOfDate, $list");

    return transpose(list);
  }
}
