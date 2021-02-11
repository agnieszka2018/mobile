import 'package:client/database/Database.dart';
import 'package:client/models/Event.dart';
import 'package:client/services/event/eventManager.dart';
import 'package:client/shared/drawer.dart';
import 'package:client/shared/exceptions/authException.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../shared/holidays.dart';
import 'package:client/shared/showNewDialog.dart';
import 'dart:io';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarController _calendarController;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  bool isLoading;

  @override
  void initState() {
    super.initState();
    _setUpEvents();

    _calendarController = CalendarController();
    _events = {};
    _selectedEvents = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Kalendarz"),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            _setCalendar(CalendarFormat.month);
            return _chooseMode(CalendarFormat.month); // portrait mode
          } else {
            _setCalendar(CalendarFormat.week);
            return _chooseMode(CalendarFormat.week); // landscape mode
          }
        },
      ),
    );
  }

  void _setCalendar(CalendarFormat format) async {
    await Future.delayed(Duration(milliseconds: 1));
    _calendarController?.setCalendarFormat(format);
  }

  Widget _chooseMode(CalendarFormat format) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            _buildTableCalendar(format),
            const SizedBox(height: 8.0),
            const SizedBox(height: 8.0),
            Expanded(
              child: _buildEventList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCalendar(CalendarFormat format) {
    return TableCalendar(
      locale: 'pl_PL',
      calendarController: _calendarController,
      events: _events,
      holidays: holidays,
      initialCalendarFormat: format,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.none,
      availableCalendarFormats: const {
        CalendarFormat.month: 'miesiąc',
        CalendarFormat.week: 'tydzień',
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
      ),
      builders: CalendarBuilders(
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }
          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: _buildHolidaysMarker(),
              ),
            );
          }
          return children;
        },
      ),
      onDaySelected: (date, events, holidays) {
        _onDaySelected(date, events, holidays);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  void _onDaySelected(DateTime date, List events, List holidays) {
    setState(() {
      print(date.toIso8601String());
      _selectedEvents = List.from(events);
      if (holidays.isNotEmpty) {
        if (events.isNotEmpty) {
          _selectedEvents.insert(0, holidays.first);
        } else {
          _selectedEvents = List.from(holidays);
        }
      }
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    _selectedEvents = [];
    setState(() {});
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {}

  void _multiplyEvent(Event event) {
    DateTime start = event.fromdate;
    DateTime stop = event.todate;

    if (start.isAfter(stop)) {
      DateTime tmp = start;
      start = stop;
      stop = tmp;
    }
    var difference = stop.difference(start);
    int counter = difference.inDays;

    for (int i = 0; i <= counter; i++) {
      DateTime tmp = start.add(Duration(days: i));

      setState(() {
        if (_events[tmp] != null) {
          _events[tmp].add(event);
        } else {
          _events[tmp] = [event];
        }
      });
    }
  }

  Widget _buildEventsMarker(DateTime date, List<dynamic> events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date)
                ? Colors.brown[300]
                : Color(events.first.color),
      ),
      width: 120.0,
      height: 18.0,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2.0, right: 2.0),
          child: Text(
            events.length > 1 ? 'MULTI' : '',
            style: TextStyle().copyWith(
              color: Colors.white,
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.bookmark_outline_rounded,
      size: 17.0,
      color: Colors.red[400],
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map(
            (event) => Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.8),
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                title: Text(event.name),
                onTap: () => print('$event tapped!'),
              ),
            ),
          )
          .toList(),
    );
  }

  void _setUpEvents() async {
    setState(() {
      isLoading = true;
    });

    await loadEvents();

    List<Event> eventsFromDB = await DatabaseProvider.db.events();

    if (eventsFromDB != null) {
      eventsFromDB.forEach((event) => _multiplyEvent(event));
    }

    setState(() {
      isLoading = false;
    });
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
}
