import 'package:client/models/Event.dart';
import 'package:client/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';

class NewEventView extends StatefulWidget {
  final Event event;
  const NewEventView({this.event});

  @override
  _NewEventViewState createState() => _NewEventViewState();
}

class _NewEventViewState extends State<NewEventView> {
  final _formKey = GlobalKey<FormState>();
  DateTime fromdate;
  DateTime todate;
  TextEditingController nameController;
  TextEditingController noteController;
  Color pickerColor;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    fromdate = widget.event != null ? widget.event.fromdate : today;
    todate = widget.event != null ? widget.event.todate : today;

    nameController = new TextEditingController(
        text: widget.event != null ? widget.event.name : null);

    noteController = new TextEditingController(
        text: widget.event != null ? widget.event.note : null);

    if (widget.event != null) {
      pickerColor = Color(widget.event.color);
    } else {
      pickerColor = Color(4278430196);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.event != null ? 'Edytuj wydarzenie' : 'Nowe wydarzenie',
            key: Key('newEvent')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20.0),
                TextFormField(
                  key: Key('eventName'),
                  controller: nameController,
                  autofocus: true,
                  decoration: formFieldDecoration.copyWith(labelText: 'Nazwa'),
                  validator: (val) => val.isEmpty ? 'Wpisz nazwę' : null,
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  key: Key('eventDescription'),
                  controller: noteController,
                  autofocus: true,
                  decoration: formFieldDecoration.copyWith(labelText: 'Opis'),
                  validator: (val) => val.isEmpty ? 'Podaj opis' : null,
                ),
                SizedBox(height: 20.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.8),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(
                        'Od: ${fromdate.day}/${fromdate.month}/${fromdate.year}'),
                    trailing: Icon(Icons.keyboard_arrow_down),
                    onTap: () async {
                      fromdate =
                          await _pickDate(fromdate, 'WYBIERZ DATĘ POCZĄTKOWĄ!');
                    }, // (from),
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.8),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(
                        'Do: ${todate.day}/${todate.month}/${todate.year}'),
                    trailing: Icon(Icons.keyboard_arrow_down),
                    onTap: () async {
                      todate = await _pickDate(todate, 'WYBIERZ DATĘ KOŃCOWĄ!');
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RaisedButton(
                      color: pickerColor ?? Theme.of(context).primaryColor,
                      child: Text(
                        'Wybierz kolor',
                        style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              .color,
                        ),
                      ),
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                      ),
                      onPressed: () => showMaterialPalettePicker(
                        title: 'Wybierz kolor',
                        cancelText: 'COFNIJ',
                        context: context,
                        selectedColor: pickerColor,
                        onChanged: (value) =>
                            setState(() => pickerColor = value),
                      ),
                    ),
                    RaisedButton(
                      key: Key('saveEvent'),
                      color: Colors.red,
                      child: Text(
                        'Zapisz',
                        style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              .color,
                        ),
                      ),
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                      ),
                      onPressed: () =>
                          {if (_formKey.currentState.validate()) submit()},
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<DateTime> _pickDate(DateTime editingDate, String helpText) async {
    DateTime date = await showDatePicker(
      locale: const Locale("pl", "PL"),
      helpText: helpText,
      cancelText: "COFNIJ",
      confirmText: "OK",
      context: context,
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime(DateTime.now().year + 10),
      initialDate: editingDate,
    );

    if (date != null) {
      setState(() {
        editingDate = date;
      });
    }

    return editingDate;
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void submit() {
    if (fromdate.isAfter(todate)) {
      DateTime tmp = fromdate;
      fromdate = todate;
      todate = tmp;
    }

    Navigator.of(context).pop({
      'name': nameController.text,
      'note': noteController.text,
      'color': pickerColor.value,
      'fromdate': fromdate,
      'todate': todate,
    });
  }
}
