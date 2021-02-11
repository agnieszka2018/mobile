import 'package:client/services/event/eventAPI.dart';
import 'package:client/services/user/userManager.dart';
import 'package:client/shared/exceptions/removedException.dart';
import 'dart:async';
import 'package:client/models/Event.dart';
import '../../database/Database.dart';

class EventManager {
  static Future<void> getEventFromServer() async {
    final body = await EventAPI.getNewEvents(UserManager.cookie);

    if (body["msg"] != "OK") {
      throw Exception('Error while fetching events (in manager)');
    }
    List<Event> events = await DatabaseProvider.db.events();

    if (events != null) {
      List<String> tmp = [];
      final hashes = body["hashes"];

      for (int i = 0; i < hashes.length; ++i) {
        tmp.add(hashes[i]["hash"]);
      }

      for (int i = 0; i < events.length; ++i) {
        int index = tmp.indexWhere((hash) => hash == events[i].hash);

        if (index == -1) {
          DatabaseProvider.db.deleteEvent(events[i].hash);
        }
      }
    }

    final data = body["events"];
    if (data.length == 0) {
      return;
    }

    if (events != null) {
      for (int i = 0; i < data.length; ++i) {
        Event event = Event.fromJson(data[i]);

        int index = events.indexWhere((e) => e.hash == event.hash);
        if (index == -1) {
          DatabaseProvider.db.insertEvent(event);
        } else {
          DatabaseProvider.db.updateEvent(event);
        }
      }
    } else {
      for (int i = 0; i < data.length; ++i) {
        Event event = Event.fromJson(data[i]);
        DatabaseProvider.db.insertEvent(event);
      }
    }
  }

  static Future<void> addItem(Event event) async {
    String fromdate = event.fromdate.toIso8601String();
    String todate = event.todate.toIso8601String();

    await EventAPI.addEvent(event.hash, event.name, event.note, event.color,
        fromdate, todate, UserManager.cookie);

    DatabaseProvider.db.insertEvent(event);
  }

  static Future<void> updateItem(Event event) async {
    int res = await DatabaseProvider.db.updateEvent(event);
    if (0 == res) {
      throw RemovedException();
    }

    String fromdate = event.fromdate.toIso8601String();
    String todate = event.todate.toIso8601String();

    await EventAPI.updateEvent(event.hash, event.name, event.note, event.color,
        fromdate, todate, UserManager.cookie);
  }

  static Future<void> deleteItem(Event event) async {
    int res = await DatabaseProvider.db.deleteEvent(event.hash);

    if (0 != res) {
      await EventAPI.deleteEvent(event.hash, UserManager.cookie);
    }
  }
}
