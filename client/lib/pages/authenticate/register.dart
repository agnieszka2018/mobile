import 'dart:io';
import 'package:client/services/user/userManager.dart';
import 'package:client/shared/exceptions/duplicateException.dart';
import 'package:client/shared/showNewDialog.dart';
import 'package:flutter/material.dart';
import '../../shared/constants.dart';
import '../../shared/specializations_list.dart';
import 'package:email_validator/email_validator.dart';

class RegisterPage extends StatefulWidget {
  final Function toggleView;
  RegisterPage({this.toggleView});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isConsent = false;
  String name = '';
  String email = '';
  String password = '';
  String passwordConfirm = '';
  String specialization = '';

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: Text('Zarejestruj'),
              actions: <Widget>[
                FlatButton.icon(
                    onPressed: () {
                      widget.toggleView();
                    },
                    icon: Icon(Icons.person),
                    label: Text('Zaloguj')),
              ],
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
                          key: Key('registerName'),
                          decoration: formFieldDecoration.copyWith(
                              hintText: 'Imię', labelText: "Imię"),
                          validator: (val) => val.isEmpty ? 'Wpisz imię' : null,
                          onChanged: (val) {
                            setState(() => name = val.trim());
                          },
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          key: Key('registerEmail'),
                          decoration: formFieldDecoration.copyWith(
                              hintText: 'E-mail', labelText: 'E-mail'),
                          validator: (val) =>
                              EmailValidator.validate(val.trim())
                                  ? null
                                  : "Wpisz e-mail",
                          onChanged: (val) {
                            setState(() => email = val.trim());
                          },
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          key: Key('registerPassword'),
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
                          key: Key('confirmRegisterPassword'),
                          decoration: formFieldDecoration.copyWith(
                              hintText: 'Potwierdź hasło',
                              labelText: 'Potwierdź hasło'),
                          validator: (val) => password != val
                              ? 'Hasła muszą być identyczne'
                              : null,
                          obscureText: true,
                          onChanged: (val) {
                            setState(() => passwordConfirm = val);
                          },
                        ),
                        SizedBox(height: 20.0),
                        DropdownButtonFormField(
                          isExpanded: true,
                          decoration: formFieldDecoration.copyWith(
                              labelText: 'Specjalizacja'),
                          items: specializations.map((specialization) {
                            return DropdownMenuItem(
                              value: specialization,
                              child: Text('$specialization'),
                            );
                          }).toList(),
                          validator: (val) =>
                              (val == null) ? 'Wybierz specjalizację' : null,
                          onChanged: (val) =>
                              setState(() => specialization = val),
                        ),
                        SizedBox(height: 20.0),
                        RaisedButton(
                          key: Key('register'),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Rejestracja'),
                                ),
                              );

                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Wymagana zgoda'),
                                    content: Text(
                                        'Czy wyrażasz zgodę na stosowanie ciasteczek?'),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          isConsent = true;
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      FlatButton(
                                        child: Text('COFNIJ'),
                                        onPressed: () {
                                          isConsent = false;
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                },
                              );

                              if (isConsent) {
                                try {
                                  await UserManager.register(
                                    name,
                                    email,
                                    password,
                                    specialization,
                                  );
                                  Navigator.pushReplacementNamed(
                                      context, '/profile');
                                } on SocketException {
                                  showNewDialog(
                                      context,
                                      Text('Błąd'),
                                      Text(
                                          'Nieudało się połączyć z serwerem, sprawdź stan połączenia z Internetem'));
                                } on DuplicateException {
                                  showNewDialog(
                                      context,
                                      Text('Błąd'),
                                      Text(
                                          'Podano nieprawidłowe dane do rejestracji'));
                                } catch (e) {
                                  showNewDialog(
                                      context,
                                      Text('Błąd'),
                                      Text(
                                          'Wystąpił błąd podczas rejestracji'));
                                }
                              }
                            }
                          },
                          child: Text('Zarejestruj'),
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
