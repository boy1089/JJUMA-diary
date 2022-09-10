

class Event {
  DateTime time = DateTime.now();
  String? note;

  Event(time, note) {
    this.time = time;
    this.note = note;
  }
}