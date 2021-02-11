import 'package:client/pages/procedure/procedure_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget makeTestable(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('NewProcedureView test', (WidgetTester tester) async {
    NewProcedureView page = NewProcedureView();
    await tester.pumpWidget(makeTestable(page));

    Finder procNameFormField = find.byKey(Key('procedureName'));
    await tester.enterText(procNameFormField, '');

    await tester.tap(find.byKey(Key('saveProcedure')));
    await tester.pump();

    expect(find.text("Wpisz nazwę"), findsOneWidget);
  });
}
