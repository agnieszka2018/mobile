import 'package:client/pages/password/reset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget makeTestable(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('ResetPage test', (WidgetTester tester) async {
    ResetPage page = ResetPage();
    await tester.pumpWidget(makeTestable(page));

    Finder tokenFormField = find.byKey(Key('token'));
    await tester.enterText(tokenFormField, '');

    Finder passwordFormField = find.byKey(Key('setResetPassword'));
    await tester.enterText(passwordFormField, '');

    Finder confirmPasswordFormField = find.byKey(Key('confirmResetPassword'));
    await tester.enterText(confirmPasswordFormField, '');

    await tester.tap(find.byKey(Key('reset')));
    await tester.pump();

    expect(find.text("Wpisz token"), findsOneWidget);
    expect(find.text("Wpisz hasło o długości 6+ znaków"), findsOneWidget);
  });
}
