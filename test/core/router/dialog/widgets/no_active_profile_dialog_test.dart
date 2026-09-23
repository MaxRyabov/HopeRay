import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/router/dialog/widgets/no_active_profile_dialog.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('NoActiveProfileDialog asks for an issued key and links nowhere', (tester) async {
    await pumpApp(tester, const NoActiveProfileDialog());
    await tester.pump();

    expect(find.text('Add an access key'), findsOneWidget);
    expect(find.textContaining('access key issued by your organization'), findsOneWidget);

    // "Show me how" -> hiddify.com/manager/ is gone, only "OK" is left
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.textContaining('hiddify.com'), findsNothing);
    expect(find.textContaining(RegExp('free', caseSensitive: false)), findsNothing);
    expect(find.textContaining(RegExp('server', caseSensitive: false)), findsNothing);
  });
}
