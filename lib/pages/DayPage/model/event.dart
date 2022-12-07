import 'package:lateDiary/Data/infoFromFile.dart';


class Event{

  String? id = null;
  DateTime? dateTime = null;
  Map<dynamic, InfoFromFile> images;

  Event({required this.images, this.id});

  factory Event.fromId({required id}){
    //read file
    //parse, return
    Map<dynamic, InfoFromFile> images = {};
    return Event(images : images);
  }

  factory Event.fromImages({required images}){
    return Event(images : images);
  }


}