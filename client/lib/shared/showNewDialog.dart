import 'package:client/services/user/userManager.dart';
import 'package:flutter/material.dart';

void showNewDialog(BuildContext context, Text titleText, Text contentText) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: titleText,
        content: contentText,
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

void showNewDialogLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Błąd'),
        content:
            Text('Sesja wygasła, zostaniesz przekierowany na stronę logowania'),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () async {
              await UserManager.logoutSessionExpired();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/authenticate', (Route<dynamic> route) => false);
            },
          )
        ],
      );
    },
  );
}
