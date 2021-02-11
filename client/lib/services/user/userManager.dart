import 'package:client/database/Database.dart';
import 'package:client/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './authAPI.dart';

class UserManager {
  static String cookie = '';

  static Future<void> login(String email, String password) async {
    cookie = await AuthAPI.login(email, password);
    await saveCookie(cookie);

    final body = await AuthAPI.getUserInfo(cookie);
    if (body["msg"] != "OK") {
      throw Exception('Error while fetching user info (in manager)');
    }

    final data = body["user"];
    await DatabaseProvider.db.insertUser(User(
        name: data["name"],
        email: data["email"],
        specialization: data["specialization"]));
  }

  static Future<void> register(
      String name, String email, String password, String specialization) async {
    cookie = await AuthAPI.register(name, email, password, specialization);

    await saveCookie(cookie);
    int res = 0;
    while (1 != res) {
      res = await DatabaseProvider.db.insertUser(
          User(name: name, email: email, specialization: specialization));
    }
  }

  static Future<dynamic> recoverPassword(String email) async {
    await AuthAPI.recoverPassword(email);
  }

  static Future<dynamic> resetPassword(String password, String token) async {
    await AuthAPI.resetPassword(password, token);
  }

  static Future<dynamic> updatePassword(
      String oldpassword, String newpassword) async {
    await AuthAPI.updatePassword(oldpassword, newpassword, cookie);
  }

  static Future<void> logout() async {
    await AuthAPI.logout(cookie);

    destroyCookie();
    DatabaseProvider.db.deleteAllEvents();
    DatabaseProvider.db.deleteAllProcedures();
    DatabaseProvider.db.deleteUser();
  }

  static Future<void> logoutSessionExpired() async {
    destroyCookie();
    DatabaseProvider.db.deleteAllEvents();
    DatabaseProvider.db.deleteAllProcedures();
    DatabaseProvider.db.deleteUser();
  }

  static Future<void> saveCookie(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cookie', value);
  }

  static Future<void> destroyCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    cookie = '';
  }
}
