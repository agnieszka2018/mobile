import 'package:client/pages/authenticate/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget makeTestable(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('Log in test', (WidgetTester tester) async {
    LogInPage page = LogInPage();
    await tester.pumpWidget(makeTestable(page));

    Finder emailFormField = find.byKey(Key('loginEmail'));
    await tester.enterText(emailFormField, '');

    Finder passwordFormField = find.byKey(Key('loginPassword'));
    await tester.enterText(passwordFormField, '');

    await tester.tap(find.byKey(Key('signIn')));
    await tester.pump();

    expect(find.text("Wpisz e-mail"), findsOneWidget);
    expect(find.text("Wpisz hasło o długości 6+ znaków"), findsOneWidget);
  });
}
