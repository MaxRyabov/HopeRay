import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/profile/add/add_profile_modal.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('AddProfileOptions offers no built-in key source', (tester) async {
    await pumpApp(tester, const AddProfileOptions());
    await tester.pump();

    // the "Free" toggle and the "Help" chip lived in the removed NavBar
    expect(find.byType(Switch), findsNothing);
    expect(find.byType(ActionChip), findsNothing);
    expect(find.byKey(const ValueKey('free')), findsNothing);
    expect(find.byKey(const ValueKey('help')), findsNothing);
    expect(find.text('Free'), findsNothing);
    expect(find.text('Help'), findsNothing);

    // importing an issued key is still possible
    expect(find.byKey(const ValueKey('add_from_clipboard_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('add_manually_button')), findsOneWidget);
  });

  testWidgets('AddProfileOptions lays out without overflow on a 360 px wide screen', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpApp(tester, const AddProfileOptions());
    await tester.pump();

    // a RenderFlex overflow would have been recorded as a framework exception
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('add_from_clipboard_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('add_manually_button')), findsOneWidget);
  });
}
