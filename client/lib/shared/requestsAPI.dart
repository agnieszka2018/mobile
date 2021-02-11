import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:client/shared/constants.dart';

HttpClient setTimeout() {
  final client = HttpClient();
  client.connectionTimeout = Duration(seconds: 3);
  return client;
}

Future<dynamic> httpPostRequest(dynamic body, String route) async {
  final client = setTimeout();

  HttpClientRequest request = await client.postUrl(Uri.parse('$URL/$route'))
    ..headers.contentType = ContentType.json
    ..write(json.encode(body));

  HttpClientResponse response = await request.close();
  return response;
}

Future<dynamic> httpPostRequestCookie(
    dynamic body, String route, String cookie) async {
  final client = setTimeout();

  HttpClientRequest request = await client.postUrl(Uri.parse('$URL/$route'))
    ..headers.contentType = ContentType.json
    ..cookies.add(Cookie("connect.sid", "$cookie"))
    ..write(json.encode(body));

  HttpClientResponse response = await request.close();
  return response;
}

Future<dynamic> httpPutRequestCookie(
    dynamic body, String route, String cookie) async {
  final client = setTimeout();

  HttpClientRequest request = await client.putUrl(Uri.parse('$URL/$route'))
    ..headers.contentType = ContentType.json
    ..cookies.add(Cookie("connect.sid", "$cookie"))
    ..write(json.encode(body));

  HttpClientResponse response = await request.close();
  return response;
}

Future<dynamic> httpDeleteRequestCookie(String route, String cookie) async {
  final client = setTimeout();

  HttpClientRequest request = await client.deleteUrl(Uri.parse('$URL/$route'))
    ..headers.contentType = ContentType.json
    ..cookies.add(Cookie("connect.sid", "$cookie"));

  HttpClientResponse response = await request.close();
  return response;
}

Future<dynamic> httpGetRequestCookie(String route, String cookie) async {
  final client = setTimeout();

  HttpClientRequest request = await client.getUrl(Uri.parse('$URL/$route'))
    ..headers.contentType = ContentType.json
    ..cookies.add(Cookie("connect.sid", "$cookie"));

  HttpClientResponse response = await request.close();
  return response;
}

Future<dynamic> readResponse(HttpClientResponse response) async {
  final completer = Completer<String>();
  final contents = StringBuffer();
  response.transform(utf8.decoder).listen((data) {
    contents.write(data);
  }, onDone: () => completer.complete(contents.toString()));

  String body = await completer.future;
  return json.decode(body);
}
