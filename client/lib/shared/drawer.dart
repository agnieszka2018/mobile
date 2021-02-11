import 'dart:io';
import 'package:client/services/user/userManager.dart';
import 'package:client/shared/exceptions/authException.dart';
import 'package:client/shared/showNewDialog.dart';
import 'package:flutter/material.dart';

class SideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Container(
              alignment: Alignment(-1.0, 1.0),
              child: Text('Kategorie', style: TextStyle(fontSize: 20))),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
        ),
        ListTile(
          title: Text("Profil"),
          leading: Icon(Icons.alternate_email_sharp),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/profile');
          },
        ),
        ListTile(
          title: Text("Procedury"),
          leading: Icon(Icons.format_list_numbered),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/procedures');
          },
        ),
        ListTile(
          title: Text("Wydarzenia"),
          leading: Icon(Icons.addchart),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/events');
          },
        ),
        ListTile(
          title: Text("Kalendarz"),
          leading: Icon(Icons.calendar_today),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/calendar');
          },
        ),
        ListTile(
          title: Text("Program specjalizacji"),
          leading: Icon(Icons.article),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/pdf');
          },
        ),
        ListTile(
          title: Text("Ustawienia"),
          leading: Icon(Icons.settings),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/updatepassword');
          },
        ),
        ListTile(
          title: Text("O aplikacji"),
          leading: Icon(Icons.question_answer),
          onTap: () {
            showAboutDialog(
                applicationName: "Aplikacja",
                context: context,
                applicationVersion: "0.0.1",
                applicationLegalese:
                    "Aplikacja stworzona w ramach pracy inżynierskiej");
          },
        ),
        Divider(),
        ListTile(
          title: Text("Wyloguj"),
          leading: Icon(Icons.arrow_back),
          onTap: () async {
            try {
              await UserManager.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/authenticate', (Route<dynamic> route) => false);
            } on SocketException {
              showNewDialog(context, Text('Błąd'),
                  Text('Sprawdź stan połączenia z Internetem'));
            } on AuthException {
              showNewDialogLogout(context);
            } catch (e) {
              showNewDialog(
                  context,
                  Text('Błąd'),
                  Text(
                      'Wystąpił błąd podczas wylogowywania, spróbuj jeszcze raz'));
            }
          },
        ),
      ],
    ));
  }
}
