import 'dart:async';
import 'dart:io';
import 'package:client/shared/exceptions/authException.dart';
import 'package:client/shared/requestsAPI.dart';

class EventAPI {
  static Future<dynamic> getNewEvents(String cookie) async {
    HttpClientResponse response = await httpGetRequestCookie('events', cookie);

    if (response.statusCode == 200) {
      return await readResponse(response);
    } else if (response.statusCode == 401) {
      throw AuthException();
    } else {
      throw Exception("Error while fetching events");
    }
  }

  static Future<void> addEvent(String hash, String name, String note, int color,
      String fromdate, String todate, String cookie) async {
    final body = {
      'hash': hash,
      'name': name,
      'note': note,
      'color': color,
      'fromdate': fromdate,
      'todate': todate,
    };

    HttpClientResponse response =
        await httpPostRequestCookie(body, 'events', cookie);

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw AuthException();
    } else {
      throw Exception("Error while reading events");
    }
  }

  static Future<void> updateEvent(String hash, String name, String note,
      int color, String fromdate, String todate, String cookie) async {
    final body = {
      'hash': hash,
      'name': name,
      'note': note,
      'color': color,
      'fromdate': fromdate,
      'todate': todate,
    };

    HttpClientResponse response =
        await httpPutRequestCookie(body, 'events', cookie);

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw AuthException();
    } else {
      throw Exception('Error while updating events');
    }
  }

  static Future<void> deleteEvent(String hash, String cookie) async {
    HttpClientResponse response =
        await httpDeleteRequestCookie('events/$hash', cookie);

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw AuthException();
    } else {
      throw Exception('Error while deleting events');
    }
  }
}
