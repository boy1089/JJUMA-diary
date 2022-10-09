

class DataManager {

  var sensorDataAll;
  var photoDataAll;

  void getSensorData(){}

  void getPhotoData(){}

  List<dynamic> subsampleData(List list, int factor) {
    List<List<dynamic>> newList = [];
    for (int i = 0; i < list.length; i++) {
      if (i % factor == 0) newList.add(list[i]);
    }
    return newList;
  }

}