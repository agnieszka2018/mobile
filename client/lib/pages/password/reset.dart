import 'dart:io';
import 'package:client/services/user/userManager.dart';
import 'package:client/shared/exceptions/authException.dart';
import 'package:client/shared/showNewDialog.dart';
import 'package:flutter/material.dart';
import '../../shared/constants.dart';

class ResetPage extends StatefulWidget {
  @override
  _ResetPageState createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final tokenController = TextEditingController();
  String password = '';
  String token = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text('Zmień hasło'),
      ),
      body: Builder(
        builder: (context) => Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    key: Key('token'),
                    controller: tokenController,
                    decoration: formFieldDecoration.copyWith(
                        hintText: 'Token', labelText: 'Token'),
                    validator: (val) => val.isEmpty ? 'Wpisz token' : null,
                    onChanged: (val) {
                      setState(() => token = val.trim());
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    key: Key('setResetPassword'),
                    controller: passwordController,
                    decoration: formFieldDecoration.copyWith(
                        hintText: 'Hasło', labelText: 'Hasło'),
                    validator: (val) => val.length < 6
                        ? 'Wpisz hasło o długości 6+ znaków'
                        : null,
                    obscureText: true,
                    onChanged: (val) {
                      setState(() => password = val);
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    key: Key('confirmResetPassword'),
                    controller: passwordConfirmController,
                    decoration: formFieldDecoration.copyWith(
                        hintText: 'Potwierdź hasło',
                        labelText: 'Potwierdź hasło'),
                    validator: (val) => passwordController.text != val
                        ? 'Hasła muszą być identyczne'
                        : null,
                    obscureText: true,
                    onChanged: (val) {
                      setState(() => password = val);
                    },
                  ),
                  SizedBox(height: 20.0),
                  RaisedButton(
                    key: Key('reset'),
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      'Zmień hasło',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Zmieniam hasło'),
                          ),
                        );

                        try {
                          await UserManager.resetPassword(password, token);
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/authenticate', (Route<dynamic> route) => false);
                        } on SocketException {
                          showNewDialog(context, Text('Błąd'),
                              Text('Sprawdź stan połączenia z Internetem'));
                        } on AuthException {
                          showNewDialog(
                              context,
                              Text('Błąd'),
                              Text(
                                  'Wpisano nieprawidłowy token lub stracił on ważność'));
                        } catch (e) {
                          showNewDialog(context, Text('Błąd'),
                              Text('Wystąpił błąd, spróbuj jeszcze raz'));
                        }
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
