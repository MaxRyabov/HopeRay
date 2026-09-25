import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/router/bottom_sheets/widgets/quick_settings_modal.dart';
import 'package:hiddify/features/chain/overview/chain_quick_settings.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('QuickSettingsModal offers only the service mode, without chain', (tester) async {
    await pumpApp(tester, const QuickSettingsModal());
    await tester.pump();

    expect(find.byWidgetPredicate((w) => w is SegmentedButton), findsOneWidget);
    expect(find.byType(ChainQuickSettings), findsNothing);
    // The divider only separated service mode from chain, it would be left hanging at the bottom
    expect(find.byType(Divider), findsNothing);
    for (final text in ['Extra security', 'Unblocker', 'WARP', 'Psiphon']) {
      expect(find.textContaining(text), findsNothing, reason: text);
    }
  });
}
