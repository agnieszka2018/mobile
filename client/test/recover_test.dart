import 'package:client/pages/password/recover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget makeTestable(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('RecoverPage test', (WidgetTester tester) async {
    RecoverPage page = RecoverPage();
    await tester.pumpWidget(makeTestable(page));

    Finder emailFormField = find.byKey(Key('recoverEmail'));
    await tester.enterText(emailFormField, '');

    await tester.tap(find.byKey(Key('recover')));
    await tester.pump();

    expect(find.text("Wpisz e-mail"), findsOneWidget);
  });
}
