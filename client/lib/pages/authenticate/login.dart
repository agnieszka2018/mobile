import 'dart:io';
import 'package:client/services/user/userManager.dart';
import 'package:client/shared/exceptions/credentialsException.dart';
import 'package:client/shared/showNewDialog.dart';
import 'package:flutter/material.dart';
import '../../shared/constants.dart';

class LogInPage extends StatefulWidget {
  final Function toggleView;
  LogInPage({this.toggleView});

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: Text('Zaloguj'),
              actions: <Widget>[
                FlatButton.icon(
                    onPressed: () {
                      widget.toggleView();
                    },
                    icon: Icon(Icons.person),
                    label: Text('Zarejestruj')),
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
                          key: Key('loginEmail'),
                          decoration: formFieldDecoration.copyWith(
                              hintText: 'E-mail', labelText: 'E-mail'),
                          validator: (val) =>
                              val.isEmpty ? 'Wpisz e-mail' : null,
                          onChanged: (val) {
                            setState(() => email = val.trim());
                          },
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          key: Key('loginPassword'),
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
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              RaisedButton(
                                color: Colors.grey[400],
                                child: Text(
                                  'Resetuj hasło',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  Navigator.pushNamed(context, '/recover');
                                },
                              ),
                              RaisedButton(
                                key: Key('signIn'),
                                color: Theme.of(context).primaryColor,
                                textColor: Colors.white,
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Logowanie'),
                                      ),
                                    );

                                    try {
                                      await UserManager.login(email, password);
                                      Navigator.pushReplacementNamed(
                                          context, '/profile');
                                    } on SocketException {
                                      showNewDialog(
                                          context,
                                          Text('Błąd'),
                                          Text(
                                              'Nieudało się połączyć z serwerem, sprawdź stan połączenia z Internetem'));
                                    } on CredentialsException {
                                      showNewDialog(
                                          context,
                                          Text('Błąd'),
                                          Text(
                                              'Nieprawidłowy e-mail lub hasło'));
                                    } catch (e) {
                                      showNewDialog(
                                          context,
                                          Text('Błąd'),
                                          Text(
                                              'Wystąpił błąd podczas logowania'));
                                    }
                                  }
                                },
                                child: Text('Zaloguj'),
                              ),
                            ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
