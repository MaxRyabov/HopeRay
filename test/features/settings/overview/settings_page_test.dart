import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/settings/overview/settings_page.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('SettingsPage has no chain section even with a profile added', (tester) async {
    // Every section the page may link to, except chainOptions: the route is not registered while chain is
    // hidden, so a section still pointing at it would throw from namedLocation.
    final router = GoRouter(
      routes: [
        for (final name in ['general', 'routingOptions', 'dnsOptions', 'inboundOptions', 'tlsTricks', 'logs', 'about'])
          GoRoute(name: name, path: '/$name', builder: (_, _) => const SizedBox()),
      ],
    );
    addTearDown(router.dispose);

    final container = await pumpApp(
      tester,
      InheritedGoRouter(goRouter: router, child: SettingsPage()),
      overrides: [hasAnyProfileProvider.overrideWith((ref) => Stream.value(true))],
    );
    await tester.pumpAndSettle();

    // Without a profile the section is hidden anyway, so the checks below would prove nothing
    expect(await container.read(hasAnyProfileProvider.future), isTrue);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Chain'), findsNothing);
    expect(find.text('Extra security & Unblocker'), findsNothing);
  });
}
