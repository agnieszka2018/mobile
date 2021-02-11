import 'package:client/pages/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget makeTestable(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('SettingsPage test', (WidgetTester tester) async {
    SettingsPage page = SettingsPage();
    await tester.pumpWidget(makeTestable(page));

    Finder oldPasswordFormField = find.byKey(Key('oldPassword'));
    await tester.enterText(oldPasswordFormField, '');

    Finder newPasswordFormField = find.byKey(Key('newPassword'));
    await tester.enterText(newPasswordFormField, '');

    Finder confirmNewPasswordFormField = find.byKey(Key('confirmNewPassword'));
    await tester.enterText(confirmNewPasswordFormField, '');

    await tester.tap(find.byKey(Key('change')));
    await tester.pump();

    expect(find.text("Wpisz hasło o długości 6+ znaków"), findsNWidgets(2));
  });
}
