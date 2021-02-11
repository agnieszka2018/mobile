import 'package:client/models/Procedure.dart';
import 'package:client/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';

class NewProcedureView extends StatefulWidget {
  final Procedure procedure;
  const NewProcedureView({this.procedure});

  @override
  _NewProcedureViewState createState() => _NewProcedureViewState();
}

class _NewProcedureViewState extends State<NewProcedureView> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController;
  int _currentVal;
  String quantityButtonText;

  @override
  void initState() {
    super.initState();
    nameController = new TextEditingController(
        text: widget.procedure != null ? widget.procedure.name : null);

    if (widget.procedure != null) {
      _currentVal = widget.procedure.quantity;
    } else {
      _currentVal = 1;
    }

    if (widget.procedure != null) {
      quantityButtonText = 'Liczba = $_currentVal';
    } else {
      quantityButtonText = 'Wybierz liczbę';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.procedure != null ? 'Edytuj procedurę' : 'Nowa procedura',
            key: Key('newProcedure')),
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
                  key: Key('procedureName'),
                  controller: nameController,
                  autofocus: true,
                  decoration: formFieldDecoration.copyWith(labelText: 'Nazwa'),
                  validator: (val) => val.isEmpty ? 'Wpisz nazwę' : null,
                ),
                SizedBox(height: 20.0),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      child: Text(
                        quantityButtonText,
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
                      onPressed: () => showMaterialNumberPicker(
                        context: context,
                        title: "Wybierz liczbę",
                        cancelText: "COFNIJ",
                        maxNumber: 999,
                        minNumber: 1,
                        selectedNumber: _currentVal,
                        onChanged: (value) => setState(() {
                          _currentVal = value;
                          quantityButtonText = 'Liczba = $_currentVal';
                        }),
                      ),
                    ),
                    RaisedButton(
                      key: Key('saveProcedure'),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submit() {
    Navigator.of(context).pop({
      'name': nameController.text,
      'quantity': _currentVal,
    });
  }
}
