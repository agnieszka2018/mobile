import 'dart:io';
import 'package:client/services/user/userManager.dart';
import 'package:client/shared/exceptions/credentialsException.dart';
import 'package:client/shared/showNewDialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import '../../shared/constants.dart';

class RecoverPage extends StatefulWidget {
  @override
  _RecoverPageState createState() => _RecoverPageState();
}

class _RecoverPageState extends State<RecoverPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  String email = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text('Podaj e-mail'),
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
                    key: Key('recoverEmail'),
                    decoration: formFieldDecoration.copyWith(
                        hintText: 'E-mail', labelText: 'E-mail'),
                    validator: (val) => EmailValidator.validate(val.trim())
                        ? null
                        : "Wpisz e-mail",
                    onChanged: (val) {
                      setState(() => email = val.trim().toLowerCase());
                    },
                  ),
                  SizedBox(height: 20.0),
                  RaisedButton(
                    key: Key('recover'),
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      'Resetuj hasło',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Wysyłam token'),
                          ),
                        );

                        try {
                          await UserManager.recoverPassword(email);
                          Navigator.pushNamed(context, '/reset');
                        } on SocketException {
                          showNewDialog(context, Text('Błąd'),
                              Text('Sprawdź stan połączenia z Internetem'));
                        } on CredentialsException {
                          showNewDialog(context, Text('Błąd'),
                              Text('Nieprawidłowy e-mail'));
                        } catch (e) {
                          showNewDialog(context, Text('Błąd'),
                              Text('Wystąpił błąd, spróbuj jeszcze raz'));
                        }
                      }
                    },
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14.0),
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
