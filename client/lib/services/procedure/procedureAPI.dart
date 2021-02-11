import 'dart:async';
import 'dart:io';
import 'package:client/shared/exceptions/authException.dart';
import 'package:client/shared/requestsAPI.dart';

class ProcedureAPI {
  static Future<dynamic> getNewProcedures(String cookie) async {
    HttpClientResponse response =
        await httpGetRequestCookie('procedures', cookie);

    if (response.statusCode == 200) {
      return await readResponse(response);
    } else if (response.statusCode == 401) {
      throw AuthException();
    } else {
      throw Exception("Error while fetching procedures");
    }
  }

  static Future<void> addProcedure(String hash, String name, int quantity,
      bool completed, String cookie) async {
    final body = {
      'hash': hash,
      'name': name,
      'quantity': quantity,
      'completed': completed
    };

    HttpClientResponse response =
        await httpPostRequestCookie(body, 'procedures', cookie);

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw AuthException();
    } else {
      throw Exception("Error while reading procedures");
    }
  }

  static Future<void> updateProcedure(String hash, String name, int quantity,
      bool completed, String cookie) async {
    final body = {
      'hash': hash,
      'name': name,
      'quantity': quantity,
      'completed': completed,
    };

    HttpClientResponse response =
        await httpPutRequestCookie(body, 'procedures', cookie);

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw AuthException();
    } else {
      throw Exception('Error while updating procedures');
    }
  }

  static Future<void> deleteProcedure(String hash, String cookie) async {
    HttpClientResponse response =
        await httpDeleteRequestCookie('procedures/$hash', cookie);

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw AuthException();
    } else {
      throw Exception('Error while deleting procedures');
    }
  }
}
