import 'package:client/database/Database.dart';
import 'package:client/services/procedure/procedureAPI.dart';
import 'package:client/services/user/userManager.dart';
import 'package:client/shared/exceptions/removedException.dart';
import '../../models/Procedure.dart';

class ProcedureManager {
  static Future<void> getProcedureFromServer() async {
    final body = await ProcedureAPI.getNewProcedures(UserManager.cookie);
    if (body["msg"] != "OK") {
      throw Exception('Error while fetching procedures (in manager)');
    }
    List<Procedure> procedures = await DatabaseProvider.db.procedures();

    if (procedures != null) {
      List<String> tmp = [];
      final hashes = body["hashes"];

      for (int i = 0; i < hashes.length; ++i) {
        tmp.add(hashes[i]["hash"]);
      }

      for (int i = 0; i < procedures.length; ++i) {
        int index = tmp.indexWhere((hash) => hash == procedures[i].hash);

        if (index == -1) {
          DatabaseProvider.db.deleteProcedure(procedures[i].hash);
        }
      }
    }

    final data = body["procedures"];
    if (data.length == 0) {
      return;
    }

    if (procedures != null) {
      for (int i = 0; i < data.length; ++i) {
        Procedure procedure = Procedure.fromJson(data[i]);

        int index = procedures.indexWhere((p) => p.hash == procedure.hash);

        if (index == -1) {
          DatabaseProvider.db.insertProcedure(procedure);
        } else {
          DatabaseProvider.db.updateProcedure(procedure);
        }
      }
    } else {
      for (int i = 0; i < data.length; ++i) {
        Procedure procedure = Procedure.fromJson(data[i]);

        DatabaseProvider.db.insertProcedure(procedure);
      }
    }
  }

  static Future<void> addItem(Procedure procedure) async {
    await ProcedureAPI.addProcedure(procedure.hash, procedure.name,
        procedure.quantity, procedure.completed, UserManager.cookie);

    DatabaseProvider.db.insertProcedure(procedure);
  }

  static Future<void> updateItem(Procedure procedure) async {
    int res = await DatabaseProvider.db.updateProcedure(procedure);
    if (0 == res) {
      throw RemovedException();
    }

    await ProcedureAPI.updateProcedure(procedure.hash, procedure.name,
        procedure.quantity, procedure.completed, UserManager.cookie);
  }

  static Future<void> deleteItem(Procedure procedure) async {
    int res = await DatabaseProvider.db.deleteProcedure(procedure.hash);

    if (0 != res) {
      await ProcedureAPI.deleteProcedure(procedure.hash, UserManager.cookie);
    }
  }
}
