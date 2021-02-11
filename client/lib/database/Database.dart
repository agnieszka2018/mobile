import 'dart:async';
import 'package:client/models/User.dart';
import 'package:client/models/Event.dart';
import 'package:client/models/Procedure.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDatabase();
    return _database;
  }

  initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'specialization.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE events (id INTEGER PRIMARY KEY, hash TEXT, name TEXT, note TEXT, color INTEGER, fromdate TEXT, todate TEXT)');

      await db.execute(
          'CREATE TABLE procedures (id INTEGER PRIMARY KEY, hash TEXT, name TEXT, quantity INTEGER, completed INTEGER)');

      await db.execute(
          'CREATE TABLE user (id INTEGER PRIMARY KEY, name TEXT, email TEXT, specialization TEXT)');
    });
  }

  Future<dynamic> insertEvent(Event event) async {
    final Database db = await database;

    var res = await db.insert(
      'events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  Future<dynamic> getEvent(int id) async {
    final Database db = await database;
    var res = await db.query('events', where: 'id = ?', whereArgs: [id]);

    return res.isNotEmpty ? Event.fromMap(res.first) : Null;
  }

  Future<List<Event>> events() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('events');

    return List.generate(maps.length, (i) {
      return Event(
        hash: maps[i]['hash'],
        name: maps[i]['name'],
        note: maps[i]['note'],
        color: maps[i]['color'],
        fromdate: DateTime.tryParse(maps[i]['fromdate']),
        todate: DateTime.tryParse(maps[i]['todate']),
      );
    });
  }

  Future<int> updateEvent(Event event) async {
    final Database db = await database;

    var res = await db.update(
      'events',
      event.toMap(),
      where: "hash = ?",
      whereArgs: [event.hash],
    );
    return res;
  }

  Future<int> deleteEvent(String hash) async {
    final Database db = await database;

    var res = await db.delete(
      'events',
      where: "hash = ?",
      whereArgs: [hash],
    );
    return res;
  }

  Future<void> deleteAllEvents() async {
    final Database db = await database;
    await db.delete('events');
  }

  Future<dynamic> insertProcedure(Procedure procedure) async {
    final Database db = await database;

    var res = await db.insert(
      'procedures',
      procedure.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  Future<dynamic> getProcedure(int id) async {
    final Database db = await database;
    var res = await db.query('procedures', where: 'id = ?', whereArgs: [id]);

    return res.isNotEmpty ? Procedure.fromMap(res.first) : Null;
  }

  Future<List<Procedure>> procedures() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('procedures');

    return List.generate(maps.length, (i) {
      return Procedure(
        hash: maps[i]['hash'],
        name: maps[i]['name'],
        quantity: maps[i]['quantity'],
        completed: maps[i]['completed'] == 1,
      );
    });
  }

  Future<int> updateProcedure(Procedure procedure) async {
    final Database db = await database;

    var res = await db.update(
      'procedures',
      procedure.toMap(),
      where: "hash = ?",
      whereArgs: [procedure.hash],
    );
    return res;
  }

  Future<int> deleteProcedure(String hash) async {
    final Database db = await database;

    var res = await db.delete(
      'procedures',
      where: "hash = ?",
      whereArgs: [hash],
    );
    return res;
  }

  Future<void> deleteAllProcedures() async {
    final Database db = await database;
    await db.delete('procedures');
  }

  Future<int> insertUser(User user) async {
    final Database db = await database;

    var res = await db.insert(
      'user',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  Future<dynamic> getUser() async {
    final Database db = await database;
    var res = await db.query('user', where: 'id = ?', whereArgs: [1]);

    return res.isNotEmpty ? User.fromMap(res.first) : Null;
  }

  Future<void> deleteUser() async {
    final Database db = await database;
    await db.delete('user');
  }
}
