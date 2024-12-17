import 'package:flutter/material.dart';
import 'event.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];

  List<Event> get events => _events;

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(String id, Event updatedEvent) {
    final index = _events.indexWhere((event) => event.id == id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
    }
  }

  void deleteEvent(String id) {
    _events.removeWhere((event) => event.id == id);
    notifyListeners();
  }
}