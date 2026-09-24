import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/settings/data/chain_guard.dart';
import 'package:hiddify/features/settings/data/config_option_repository.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../helpers/config_options.dart';

void main() {
  group('resetDisabledChainStatus', () {
    test('stored extraSecurity is reset to off', () async {
      final container = await configOptionsContainer(prefs: {'chain-status': 'extraSecurity'});
      addTearDown(container.dispose);

      expect(await resetDisabledChainStatus(container), isTrue);

      expect(container.read(sharedPreferencesProvider).requireValue.getString('chain-status'), 'off');
      expect(container.read(ConfigOptions.chainStatus), ChainStatus.off);
    });

    test('stored unblocker is reset to off', () async {
      final container = await configOptionsContainer(prefs: {'chain-status': 'unblocker'});
      addTearDown(container.dispose);

      expect(await resetDisabledChainStatus(container), isTrue);

      expect(container.read(sharedPreferencesProvider).requireValue.getString('chain-status'), 'off');
    });

    test('stored off is left untouched', () async {
      final container = await configOptionsContainer(prefs: {'chain-status': 'off'});
      addTearDown(container.dispose);

      expect(await resetDisabledChainStatus(container), isFalse);

      expect(container.read(sharedPreferencesProvider).requireValue.getString('chain-status'), 'off');
    });

    test('nothing is written when the preference was never set', () async {
      final container = await configOptionsContainer();
      addTearDown(container.dispose);

      expect(await resetDisabledChainStatus(container), isFalse);

      expect(container.read(sharedPreferencesProvider).requireValue.containsKey('chain-status'), isFalse);
    });
  });
}
