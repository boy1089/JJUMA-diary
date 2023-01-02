import 'package:jjuma.d/Data/info_from_file.dart';

class PhotoCardModel {
  Map<dynamic, InfoFromFile> event;
  bool isMagnified = false;
  double height = 100;

  PhotoCardModel(
      {required this.event, this.isMagnified = false, this.height = 100});
}
