import 'package:lateDiary/Data/infoFromFile.dart';

class Event {
  Map<dynamic, InfoFromFile> images;
  String note = '';

  Event({required this.images, required this.note});

  factory Event.fromImages({required images}) {
    return Event(images: images, note: "");
  }

  factory Event.fromJson({required json}) {
    var images = Map.fromIterables(
        json['images'].keys.toList(),
        List.generate(
            json['images'].values.length,
            (index) => InfoFromFile.fromJson(
                json: json['images'].values.toList().elementAt(index))));
    var note = json['note'];
    return Event(images: images, note: note);
  }

  void setNote(String note) {
    this.note = note;
  }

  Map toMap() {
    return {
      "images": Map.fromIterables(
          images.keys,
          List.generate(images.values.length,
              (index) => images.values.elementAt(index).toMap())),
      "note": note
    };
  }
}
