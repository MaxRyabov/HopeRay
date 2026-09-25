import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/settings/data/chain_guard.dart';
import 'package:hiddify/features/settings/data/config_option_repository.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../helpers/config_options.dart';

void main() {
  group('resetDisabledChainStatus', () {
    late int coreCalls;

    setUp(() => coreCalls = 0);

    Future<bool> Function() core({required bool applies}) => () async {
      coreCalls++;
      return applies;
    };

    String? storedChainStatus(ProviderContainer container) =>
        container.read(sharedPreferencesProvider).requireValue.getString('chain-status');

    for (final stored in ['extraSecurity', 'unblocker']) {
      test('stored $stored is reset to off once the core has the new options', () async {
        final container = await configOptionsContainer(prefs: {'chain-status': stored});
        addTearDown(container.dispose);

        expect(await resetDisabledChainStatus(container, applyToCore: core(applies: true)), isTrue);

        expect(coreCalls, 1);
        expect(storedChainStatus(container), 'off');
        expect(container.read(ConfigOptions.chainStatus), ChainStatus.off);
      });

      test('stored $stored is kept when the core did not apply the options, to retry on next launch', () async {
        final container = await configOptionsContainer(prefs: {'chain-status': stored});
        addTearDown(container.dispose);

        expect(await resetDisabledChainStatus(container, applyToCore: core(applies: false)), isFalse);

        expect(coreCalls, 1);
        expect(storedChainStatus(container), stored);
      });
    }

    test('stored value is kept when the core throws', () async {
      final container = await configOptionsContainer(prefs: {'chain-status': 'extraSecurity'});
      addTearDown(container.dispose);

      await expectLater(
        resetDisabledChainStatus(container, applyToCore: () async => throw StateError('core is not initialized')),
        throwsStateError,
      );

      expect(storedChainStatus(container), 'extraSecurity');
    });

    test('stored off is left untouched and the core is not called', () async {
      final container = await configOptionsContainer(prefs: {'chain-status': 'off'});
      addTearDown(container.dispose);

      expect(await resetDisabledChainStatus(container, applyToCore: core(applies: true)), isFalse);

      expect(coreCalls, 0);
      expect(storedChainStatus(container), 'off');
    });

    test('nothing is written when the preference was never set', () async {
      final container = await configOptionsContainer();
      addTearDown(container.dispose);

      expect(await resetDisabledChainStatus(container, applyToCore: core(applies: true)), isFalse);

      expect(coreCalls, 0);
      expect(container.read(sharedPreferencesProvider).requireValue.containsKey('chain-status'), isFalse);
    });
  });
}
