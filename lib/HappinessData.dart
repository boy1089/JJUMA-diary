

class HappinessData {
  DateTime time = DateTime.now();
  int? happiness;
  String? note;


  HappinessData(time, happiness, note) {
    this.time = time;
    this.happiness = happiness;
    this.note = note;
  }
}

class Happiness{
  int fantastic = 5;
  int good = 4;
  int notbad = 3;
  int soso = 2;
  int bad = 1;
}
