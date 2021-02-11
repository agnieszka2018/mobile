import 'dart:io';
import 'package:client/database/Database.dart';
import 'package:client/shared/exceptions/authException.dart';
import 'package:client/shared/exceptions/removedException.dart';
import 'package:client/shared/showNewDialog.dart';
import 'package:client/models/Procedure.dart';
import 'package:client/services/procedure/procedureManager.dart';
import 'package:client/shared/drawer.dart';
import 'package:flutter/material.dart';
import './procedure_helper.dart';
import '../../models/Procedure.dart';

class ProcedurePage extends StatefulWidget {
  @override
  _ProcedurePageState createState() => _ProcedurePageState();
}

class _ProcedurePageState extends State<ProcedurePage>
    with SingleTickerProviderStateMixin {
  bool isLoading;

  @override
  void initState() {
    super.initState();
    _setUpProcedures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      appBar: AppBar(
        title: Text(
          'Procedury',
          key: Key('main-app-name'),
        ),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.add_circle_outline_sharp, size: 30.0),
              onPressed: () => goToNewProcedureView(),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Procedure>>(
        future: DatabaseProvider.db.procedures(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Procedure>> snapshot) {
          if (snapshot.hasData) {
            return buildListView(snapshot);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _setUpProcedures() async {
    setState(() {
      isLoading = true;
    });

    await loadProcedures();

    setState(() {
      isLoading = false;
    });
  }

  Widget buildListView(AsyncSnapshot<List<Procedure>> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        return buildProcedure(snapshot.data[index], index);
      },
    );
  }

  Widget buildProcedure(Procedure procedure, int index) {
    return Dismissible(
      key: Key('${procedure.hashCode}'),
      background: Container(
        color: Colors.redAccent[100],
        child: Icon(Icons.delete, color: Colors.white),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 12.0),
      ),
      onDismissed: (direction) {
        setState(() {});
      },
      direction: DismissDirection.startToEnd,
      child: buildListTile(procedure, index),
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Potwierdzenie"),
              content:
                  const Text("Czy jesteś pewny, że chcesz usunąć procedurę?"),
              actions: <Widget>[
                FlatButton(
                  child: const Text("USUŃ"),
                  onPressed: () async {
                    try {
                      await ProcedureManager.getProcedureFromServer();
                      await ProcedureManager.deleteItem(procedure);
                      setState(() {});
                      Navigator.of(context).pop(true);
                    } on SocketException {
                      Navigator.of(context).pop(false);
                      showNewDialog(context, Text('Błąd'),
                          Text('Sprawdź stan połączenia z Internetem'));
                    } on AuthException {
                      Navigator.of(context).pop(false);
                      showNewDialogLogout(context);
                    } catch (e) {
                      Navigator.of(context).pop(false);
                      showNewDialog(context, Text('Błąd'),
                          Text('Wystąpił błąd, spróbuj jeszcze raz'));
                    }
                  },
                ),
                FlatButton(
                  child: const Text("COFNIJ"),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildListTile(Procedure procedure, int index) {
    return Card(
      child: InkWell(
        onTap: () => changeProcedureCompleteness(procedure),
        onLongPress: () => goToEditProcedureView(procedure),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    procedure.name,
                    key: Key('procedure-$index'),
                    style: TextStyle(
                        color: procedure.completed ? Colors.grey : Colors.black,
                        decoration: procedure.completed
                            ? TextDecoration.lineThrough
                            : null),
                  ),
                  flex: 6,
                ),
                Expanded(
                  child: IconButton(
                    icon: new Icon(Icons.remove_circle_outline,
                        color: Theme.of(context).primaryColor),
                    iconSize: 20,
                    onPressed: () async {
                      if (procedure.quantity > 1) {
                        int tmp = procedure.quantity - 1;
                        await editProcedureQuantity(procedure, tmp);
                      }
                    },
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: Text(
                    '${procedure.quantity}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: IconButton(
                    icon: new Icon(Icons.add_circle_outline,
                        color: Theme.of(context).primaryColor),
                    padding: const EdgeInsets.all(0),
                    iconSize: 20,
                    onPressed: () async {
                      if (procedure.quantity < 999) {
                        int tmp = procedure.quantity + 1;
                        await editProcedureQuantity(procedure, tmp);
                      }
                    },
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: Icon(
                    procedure.completed
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: procedure.completed ? Colors.grey : Colors.black,
                    key: Key('completed-icon-$index'),
                  ),
                  flex: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loadProcedures() async {
    try {
      await ProcedureManager.getProcedureFromServer();
    } on SocketException {
      showNewDialog(
          context, Text('Błąd'), Text('Sprawdź stan połączenia z Internetem'));
    } on AuthException {
      showNewDialogLogout(context);
    } catch (e) {
      showNewDialog(
          context, Text('Błąd'), Text('Wystąpił błąd, spróbuj jeszcze raz'));
    }
  }

  void changeProcedureCompleteness(Procedure procedure) async {
    bool tmp = !procedure.completed;
    await editProcedureCompletness(procedure, tmp);
  }

  void goToNewProcedureView() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NewProcedureView();
    })).then((data) {
      if (data != null) {
        int timestamp = DateTime.now().microsecondsSinceEpoch;

        addProcedure(Procedure(
          hash: timestamp.toString(),
          name: data['name'],
          quantity: data['quantity'],
          completed: false,
        ));
      }
    });
  }

  Future<void> addProcedure(Procedure procedure) async {
    try {
      await ProcedureManager.getProcedureFromServer();
      await ProcedureManager.addItem(procedure);

      setState(() {});
    } on SocketException {
      showNewDialog(
          context, Text('Błąd'), Text('Sprawdź stan połączenia z Internetem'));
    } on AuthException {
      showNewDialogLogout(context);
    } catch (e) {
      showNewDialog(
          context, Text('Błąd'), Text('Wystąpił błąd, spróbuj jeszcze raz'));
    }
  }

  void goToEditProcedureView(Procedure procedure) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NewProcedureView(procedure: procedure);
    })).then((data) {
      if (data != null) {
        editProcedure(Procedure(
          hash: procedure.hash,
          name: data['name'],
          quantity: data['quantity'],
          completed: procedure.completed,
        ));
      }
    });
  }

  Future<void> editProcedure(Procedure procedure) async {
    try {
      await ProcedureManager.getProcedureFromServer();
      await ProcedureManager.updateItem(procedure);

      setState(() {});
    } on SocketException {
      showNewDialog(
          context, Text('Błąd'), Text('Sprawdź stan połączenia z Internetem'));
    } on AuthException {
      showNewDialogLogout(context);
    } on RemovedException {
      showNewDialog(
          context,
          Text('Błąd'),
          Text(
              'Dana procedura została wcześniej usunięta na innym urządzeniu'));
      setState(() {});
    } catch (e) {
      showNewDialog(
          context, Text('Błąd'), Text('Wystąpił błąd, spróbuj jeszcze raz'));
    }
  }

  Future<void> editProcedureQuantity(Procedure procedure, int tmp) async {
    try {
      await ProcedureManager.getProcedureFromServer();
      await ProcedureManager.updateItem(Procedure(
          hash: procedure.hash,
          name: procedure.name,
          quantity: tmp,
          completed: procedure.completed));

      setState(() {});
    } on SocketException {
      showNewDialog(
          context, Text('Błąd'), Text('Sprawdź stan połączenia z Internetem'));
    } on AuthException {
      showNewDialogLogout(context);
    } on RemovedException {
      showNewDialog(
          context,
          Text('Błąd'),
          Text(
              'Dana procedura została wcześniej usunięta na innym urządzeniu'));
      setState(() {});
    } catch (e) {
      showNewDialog(
          context, Text('Błąd'), Text('Wystąpił błąd, spróbuj jeszcze raz'));
    }
  }

  Future<void> editProcedureCompletness(Procedure procedure, bool tmp) async {
    try {
      await ProcedureManager.getProcedureFromServer();
      await ProcedureManager.updateItem(Procedure(
          hash: procedure.hash,
          name: procedure.name,
          quantity: procedure.quantity,
          completed: tmp));

      setState(() {});
    } on SocketException {
      showNewDialog(
          context, Text('Błąd'), Text('Sprawdź stan połączenia z Internetem'));
    } on AuthException {
      showNewDialogLogout(context);
    } on RemovedException {
      showNewDialog(
          context,
          Text('Błąd'),
          Text(
              'Dana procedura została wcześniej usunięta na innym urządzeniu'));
      setState(() {});
    } catch (e) {
      showNewDialog(
          context, Text('Błąd'), Text('Wystąpił błąd, spróbuj jeszcze raz'));
    }
  }
}
