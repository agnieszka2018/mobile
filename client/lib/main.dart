import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:client/pages/password/recover.dart';
import 'package:client/pages/password/reset.dart';
import 'package:client/pages/settings/settings.dart';
import 'package:client/services/user/userManager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import './pages/procedure/procedure.dart';
import './pages/profile/profile.dart';
import './pages/authenticate/login.dart';
import './pages/authenticate/authenticate.dart';
import './pages/event/event.dart';
import './pages/pdf/pdf.dart';
import './pages/calendar/calendar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  UserManager.cookie = prefs.getString('cookie') ?? '';

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [const Locale('pl')],
      theme: ThemeData(fontFamily: 'Poppins', primarySwatch: Colors.lightGreen),
      routes: {
        '/authenticate': (context) => Authenticate(),
        '/login': (context) => LogInPage(),
        '/procedures': (context) => ProcedurePage(),
        '/events': (context) => EventPage(),
        '/profile': (context) => ProfilePage(),
        '/calendar': (context) => CalendarPage(),
        '/pdf': (context) => DocumentPage(),
        '/recover': (context) => RecoverPage(),
        '/reset': (context) => ResetPage(),
        '/updatepassword': (context) => SettingsPage(),
      },
      home: (UserManager.cookie == '') ? Authenticate() : ProfilePage(),
    );
  }
}
