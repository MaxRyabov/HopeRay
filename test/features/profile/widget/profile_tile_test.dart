import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hiddify/features/profile/model/profile_entity.dart';
import 'package:hiddify/features/profile/widget/profile_tile.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final profile = ProfileEntity.remote(
    id: 'id',
    active: true,
    name: 'Work',
    url: 'https://example.com/sub',
    lastUpdate: DateTime(2026),
    subInfo: SubscriptionInfo(
      upload: 0,
      download: 1024,
      total: 10240,
      expire: DateTime(2030),
      supportUrl: 'https://t.me/somebot',
      webPageUrl: 'https://example.com/shop',
    ),
  );

  for (final isMain in [true, false]) {
    testWidgets('ProfileTile(isMain: $isMain) does not show stored support and web page links', (tester) async {
      await pumpApp(tester, ProfileTile(profile: profile, isMain: isMain));
      await tester.pump();

      expect(find.text('Work'), findsOneWidget);
      expect(find.textContaining('somebot'), findsNothing);
      expect(find.textContaining('t.me'), findsNothing);
      expect(find.textContaining('example.com/shop'), findsNothing);
      expect(find.byIcon(FontAwesomeIcons.telegram), findsNothing);
      expect(find.byIcon(FontAwesomeIcons.headset), findsNothing);

      // UpdateProfileNotifier keeps itself alive for a minute after the tile unmounts
      // (ref.disposeDelay); let that timer fire before the test binding checks for pending timers
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(minutes: 1));
    });
  }
}
