import 'package:client/pages/event/event_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget makeTestable(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('NewEventView test', (WidgetTester tester) async {
    NewEventView page = NewEventView();
    await tester.pumpWidget(makeTestable(page));

    Finder eventNameFormField = find.byKey(Key('eventName'));
    await tester.enterText(eventNameFormField, '');

    Finder descriptionFormField = find.byKey(Key('eventDescription'));
    await tester.enterText(descriptionFormField, '');

    await tester.tap(find.byKey(Key('saveEvent')));
    await tester.pump();

    expect(find.text("Wpisz nazwę"), findsOneWidget);
    expect(find.text("Podaj opis"), findsOneWidget);
  });
}
