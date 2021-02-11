import 'dart:io';
import 'package:client/services/user/userManager.dart';
import 'package:client/shared/constants.dart';
import 'package:client/shared/exceptions/credentialsException.dart';
import 'package:client/shared/drawer.dart';
import 'package:client/shared/exceptions/authException.dart';
import 'package:client/shared/showNewDialog.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text('Ustawienia'),
      ),
      body: Builder(
        builder: (context) => Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  TextFormField(
                    key: Key('oldPassword'),
                    controller: oldPasswordController,
                    decoration: formFieldDecoration.copyWith(
                        hintText: 'Aktualne hasło',
                        labelText: 'Aktualne hasło'),
                    validator: (val) => val.length < 6
                        ? 'Wpisz hasło o długości 6+ znaków'
                        : null,
                    obscureText: true,
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    key: Key('newPassword'),
                    controller: newPasswordController,
                    decoration: formFieldDecoration.copyWith(
                        hintText: 'Nowe hasło', labelText: 'Nowe hasło'),
                    validator: (val) => val.length < 6
                        ? 'Wpisz hasło o długości 6+ znaków'
                        : null,
                    obscureText: true,
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    key: Key('confirmNewPassword'),
                    controller: passwordConfirmController,
                    decoration: formFieldDecoration.copyWith(
                        hintText: 'Potwierdź nowe hasło',
                        labelText: 'Potwierdź nowe hasło'),
                    validator: (val) => newPasswordController.text != val
                        ? 'Hasła muszą być identyczne'
                        : null,
                    obscureText: true,
                  ),
                  SizedBox(height: 20.0),
                  RaisedButton(
                    key: Key('change'),
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      'Zmień hasło',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        try {
                          await UserManager.updatePassword(
                              oldPasswordController.text,
                              newPasswordController.text);
                          showNewDialog(context, Text("Powodzenie"),
                              Text("Hasło zostało pomyślnie zmienione"));
                        } on SocketException {
                          showNewDialog(context, Text('Błąd'),
                              Text('Sprawdź stan połączenia z Internetem'));
                        } on AuthException {
                          showNewDialogLogout(context);
                        } on CredentialsException {
                          showNewDialog(context, Text('Błąd'),
                              Text('Nieprawidłowe aktualne hasło'));
                        } catch (e) {
                          showNewDialog(context, Text('Błąd'),
                              Text('Wystąpił błąd, spróbuj jeszcze raz'));
                        }
                        oldPasswordController.clear();
                        newPasswordController.clear();
                        passwordConfirmController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
