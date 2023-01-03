import 'package:jjuma.d/Data/info_from_file.dart';

class Event {
  Map<dynamic, InfoFromFile> images;
  String note = '';

  Event({required this.images, required this.note}){
    try {
      images = Map.fromEntries(images.entries.toList()
        ..sort((e1, e2) => e1.value.datetime!.compareTo(e2.value.datetime!)));
    } catch(e){}

    // images.forEach((element)=>print(element));
  }

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
