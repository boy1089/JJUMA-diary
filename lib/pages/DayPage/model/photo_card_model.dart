import 'package:lateDiary/Data/infoFromFile.dart';

class PhotoCardModel {
  Map<dynamic, InfoFromFile> event;
  bool isMagnified = false;
  double height = 100;

  PhotoCardModel(
      {required this.event, this.isMagnified = false, this.height = 100});
}
