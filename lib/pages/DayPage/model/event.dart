import 'package:lateDiary/Data/infoFromFile.dart';

class Event {
  Map<dynamic, InfoFromFile> images;
  String note = '';

  Event({required this.images, required this.note});

  factory Event.fromImages({required images}) {
    return Event(images: images, note: "");
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
