import 'package:test_location_2nd/Event.dart';

class EventList{
  List<Event> eventList = [];
  EventList(){
  }

  void getEventList(List<Event> list){
    eventList = list;
  }

  void add(Event event){
    eventList.add(event);
  }

  int length(){
    if (eventList != null){
      print(eventList.length);
      return eventList.length;
    } else {
      return 0;
    }
  }
  void sortEvent(){}

  void clear(){
    eventList = [];
  }
}