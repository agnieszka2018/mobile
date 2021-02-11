import 'package:client/pages/authenticate/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget makeTestable(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('Register test', (WidgetTester tester) async {
    RegisterPage page = RegisterPage();
    await tester.pumpWidget(makeTestable(page));

    Finder nameFormField = find.byKey(Key('registerName'));
    await tester.enterText(nameFormField, '');

    Finder emailFormField = find.byKey(Key('registerEmail'));
    await tester.enterText(emailFormField, '');

    Finder passwordFormField = find.byKey(Key('registerPassword'));
    await tester.enterText(passwordFormField, '');

    Finder confirmPasswordFormField =
        find.byKey(Key('confirmRegisterPassword'));
    await tester.enterText(confirmPasswordFormField, '');

    await tester.tap(find.byKey(Key('register')));
    await tester.pump();

    expect(find.text("Wpisz imię"), findsOneWidget);
    expect(find.text("Wpisz e-mail"), findsOneWidget);
    expect(find.text("Wpisz hasło o długości 6+ znaków"), findsOneWidget);
  });
}
