import 'dart:io';
import 'package:client/models/Event.dart';
import 'package:client/services/event/eventManager.dart';
import 'package:client/shared/exceptions/authException.dart';
import 'package:client/shared/exceptions/removedException.dart';
import 'package:flutter/material.dart';
import 'package:client/shared/drawer.dart';
import './event_helper.dart';
import 'package:client/shared/showNewDialog.dart';
import '../../database/Database.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage>
    with SingleTickerProviderStateMixin {
  bool isLoading;

  @override
  void initState() {
    super.initState();
    _setUpEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      appBar: AppBar(
        title: Text(
          'Wydarzenia',
          key: Key('main-app-name-event'),
        ),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.add_circle_outline_sharp, size: 30.0),
              onPressed: () => goToNewEventView(),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: DatabaseProvider.db.events(),
        builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
          if (snapshot.hasData) {
            return buildListView(snapshot);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget emptyList() {
    return Center(child: Text('Brak dodanych wydarzeń'));
  }

  void _setUpEvents() async {
    setState(() {
      isLoading = true;
    });

    await loadEvents();

    setState(() {
      isLoading = false;
    });
  }

  Widget buildListView(AsyncSnapshot<List<Event>> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        return buildEvent(snapshot.data[index], index);
      },
    );
  }

  Widget buildEvent(Event event, int index) {
    return Dismissible(
      key: Key('${event.hashCode}'),
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
      child: buildListTile(event, index),
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Potwierdzenie"),
              content:
                  const Text("Czy jesteś pewny, że chcesz usunąć wydarzenie?"),
              actions: <Widget>[
                FlatButton(
                  child: const Text("USUŃ"),
                  onPressed: () async {
                    try {
                      await EventManager.getEventFromServer();
                      await EventManager.deleteItem(event);
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

  Widget buildListTile(Event event, int index) {
    return Card(
      child: InkWell(
        onLongPress: () => goToEditEventView(event),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: CircleAvatar(
                      backgroundColor: Color(event.color),
                      radius: 24.0,
                    ),
                    flex: 3),
                Expanded(child: SizedBox(width: 0.5), flex: 1),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child:
                                  Icon(Icons.calendar_today_outlined, size: 20),
                            ),
                            Container(
                              margin: const EdgeInsets.all(6.0),
                              padding: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Colors.black)),
                              child: Text(
                                  " ${event.fromdate.day}/${event.fromdate.month}/${event.fromdate.year} "),
                            ),
                            Container(
                              child: Text(
                                ':',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(6.0),
                              padding: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Colors.black)),
                              child: Text(
                                  " ${event.todate.day}/${event.todate.month}/${event.todate.year} "),
                            ),
                          ],
                        ),
                        Container(
                          child: Text(
                            '${event.name}',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          child: Text(
                            '${event.note}',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    flex: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loadEvents() async {
    try {
      await EventManager.getEventFromServer();
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

  void goToNewEventView() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NewEventView();
    })).then((data) {
      if (data != null) {
        int timestamp = DateTime.now().microsecondsSinceEpoch;

        addEvent(Event(
          hash: timestamp.toString(),
          name: data['name'],
          note: data['note'],
          color: data['color'],
          fromdate: data['fromdate'],
          todate: data['todate'],
        ));
      }
    });
  }

  Future<void> addEvent(Event event) async {
    try {
      await EventManager.getEventFromServer();
      await EventManager.addItem(event);

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

  void goToEditEventView(Event event) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NewEventView(event: event);
    })).then((data) {
      if (data != null) {
        editEvent(Event(
          hash: event.hash,
          name: data['name'],
          note: data['note'],
          color: data['color'],
          fromdate: data['fromdate'],
          todate: data['todate'],
        ));
      }
    });
  }

  Future<void> editEvent(Event event) async {
    try {
      await EventManager.getEventFromServer();
      await EventManager.updateItem(event);

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
              'Dane wydarzenie zostało wcześniej usunięte na innym urządzeniu'));
      setState(() {});
    } catch (e) {
      showNewDialog(
          context, Text('Błąd'), Text('Wystąpił błąd, spróbuj jeszcze raz'));
    }
  }
}
