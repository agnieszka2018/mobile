import 'package:client/database/Database.dart';
import 'package:client/models/User.dart';
import 'package:client/shared/drawer.dart';
import 'package:client/shared/exceptions/authException.dart';
import 'package:client/shared/showNewDialog.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User user = User();
  bool isLoading = true;

  @override
  initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      appBar: AppBar(
        title: Text('Profil'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.green[300],
                    Colors.white,
                  ],
                  tileMode: TileMode.repeated,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 0.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: AvatarGlow(
                            endRadius: 80.0,
                            child: Material(
                              elevation: 8.0,
                              shape: CircleBorder(),
                              child: CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                backgroundImage: AssetImage(
                                  'assets/stethoscope.jpg',
                                ),
                                radius: 40.0,
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          height: 90.0,
                          color: Colors.grey[600],
                        ),
                        Text(
                          'IMIĘ',
                          style: TextStyle(
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          user.name ?? '',
                          style: TextStyle(
                            color: Colors.grey[400],
                            letterSpacing: 2.0,
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Text(
                          'SPECJALIZACJA',
                          style: TextStyle(
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          user.specialization ?? '',
                          style: TextStyle(
                            color: Colors.grey[400],
                            letterSpacing: 2.0,
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.email,
                              color: Colors.grey[400],
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              user.email ?? '',
                              style: TextStyle(
                                fontSize: 18.0,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  getUser() async {
    try {
      user = await DatabaseProvider.db.getUser();
    } on SocketException {
      showNewDialog(
          context, Text('Błąd'), Text('Sprawdź stan połączenia z Internetem'));
    } on AuthException {
      showNewDialogLogout(context);
    } catch (e) {
      showNewDialog(
          context, Text('Błąd'), Text('Wystąpił błąd, zaloguj się ponownie'));
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/authenticate', (Route<dynamic> route) => false);
    }

    setState(() {
      isLoading = false;
    });
  }
}
