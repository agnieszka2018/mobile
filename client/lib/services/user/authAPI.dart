import 'dart:async';
import 'dart:io';
import 'package:client/shared/exceptions/credentialsException.dart';
import 'package:client/shared/exceptions/duplicateException.dart';
import 'package:client/shared/exceptions/authException.dart';
import 'package:client/shared/requestsAPI.dart';

class AuthAPI {
  static Future<void> checkEmail(String email) async {
    final body = {'email': email};
    HttpClientResponse response = await httpPostRequest(body, 'checkemail');

    if (response.statusCode == 400) {
      throw DuplicateException("E-mail already exists");
    }
  }

  static Future<void> setCookie(HttpClientResponse response) async {
    if (response.cookies[0].value != null) {
      return response.cookies[0].value;
    } else {
      return '';
    }
  }

  static Future<dynamic> login(String email, String password) async {
    final body = {'email': email, 'password': password};

    HttpClientResponse response = await httpPostRequest(body, 'login');

    if (response.statusCode == 200) {
      return await setCookie(response);
    } else if (response.statusCode == 400) {
      throw CredentialsException("Incorrect e-mail or password");
    } else {
      throw Exception("Error while logging in");
    }
  }

  static Future<dynamic> register(
      String name, String email, String password, String specialization) async {
    await checkEmail(email);

    final body = {
      'name': name,
      'email': email,
      'password': password,
      'specialization': specialization
    };

    HttpClientResponse response = await httpPostRequest(body, 'register');

    if (response.statusCode == 200) {
      return await setCookie(response);
    } else {
      throw Exception("Error while registration");
    }
  }

  static Future<dynamic> getUserInfo(String cookie) async {
    HttpClientResponse response = await httpGetRequestCookie('user', cookie);

    if (response.statusCode == 200) {
      return await readResponse(response);
    } else if (response.statusCode == 401) {
      throw AuthException();
    } else {
      throw Exception("Error while fetching user info");
    }
  }

  static Future<void> recoverPassword(String email) async {
    final body = {'email': email};

    HttpClientResponse response = await httpPostRequest(body, 'recover');

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw CredentialsException("E-mail does not exist");
    } else {
      throw Exception("Could not send an e-mail with token");
    }
  }

  static Future<void> resetPassword(String password, String token) async {
    final body = {'password': password};

    HttpClientResponse response = await httpPostRequest(body, 'reset/$token');

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw AuthException("Invalid token");
    } else {
      throw Exception("Could not reset password with given token");
    }
  }

  static Future<void> updatePassword(
      String oldpassword, String newpassword, String cookie) async {
    final body = {'oldpassword': oldpassword, 'newpassword': newpassword};

    HttpClientResponse response =
        await httpPostRequestCookie(body, 'updatepassword', cookie);

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw AuthException();
    } else if (response.statusCode == 400) {
      throw CredentialsException("Incorrect password");
    } else {
      throw Exception("Could not update password");
    }
  }

  static Future<void> logout(String cookie) async {
    HttpClientResponse response = await httpGetRequestCookie('logout', cookie);

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw AuthException();
    } else {
      throw Exception("Could not log out");
    }
  }
}
