import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/settings/data/config_option_repository.dart';
import 'package:hiddify/features/settings/model/config_option_failure.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/singbox/model/singbox_config_option.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../helpers/config_options.dart';

void main() {
  late ProviderContainer container;
  late SingboxConfigOption defaults;

  setUp(() async {
    container = await configOptionsContainer();
    addTearDown(container.dispose);
    defaults = container.read(ConfigOptions.singboxConfigOptions);
  });

  ConfigOptionRepository repositoryWith(SingboxConfigOption options) => ConfigOptionRepository(
    preferences: container.read(sharedPreferencesProvider).requireValue,
    getConfigOptions: () => options,
  );

  ChainStatus? chainStatusOf(Either<ConfigOptionFailure, SingboxConfigOption> options) =>
      options.toNullable()?.chainStatus;

  group('chain is forced off before the core', () {
    test('stored extraSecurity is dropped with no profile override', () {
      final repo = repositoryWith(defaults.copyWith(chainStatus: ChainStatus.extraSecurity));

      expect(chainStatusOf(repo.fullOptionsOverrided(null)), ChainStatus.off);
      expect(chainStatusOf(repo.fullOptionsOverrided('{}')), ChainStatus.off);
      expect(chainStatusOf(repo.fullOptions()), ChainStatus.off);
    });

    test('stored unblocker is dropped', () {
      final repo = repositoryWith(defaults.copyWith(chainStatus: ChainStatus.unblocker));

      expect(chainStatusOf(repo.fullOptionsOverrided(null)), ChainStatus.off);
      expect(chainStatusOf(repo.fullOptionsOverrided('{}')), ChainStatus.off);
      expect(chainStatusOf(repo.fullOptions()), ChainStatus.off);
    });

    test('profile override cannot switch chain on', () {
      final repo = repositoryWith(defaults.copyWith(chainStatus: ChainStatus.off));

      final options = repo.fullOptionsOverrided('{"chain-status":"extra_security","extra-security":{"mode":"warp"}}');

      expect(chainStatusOf(options), ChainStatus.off);
    });

    test('other profile overrides still apply', () {
      final repo = repositoryWith(defaults);

      final options = repo.fullOptionsOverrided('{"connection-test-url":"https://example.com/generate_204"}');

      expect(options.toNullable()?.connectionTestUrl, 'https://example.com/generate_204');
    });
  });

  test('unblocker mode is taken from its own preference', () async {
    final modesContainer = await configOptionsContainer(
      prefs: {'extra-security-mode': 'warp', 'unblocker-mode': 'psiphon'},
    );
    addTearDown(modesContainer.dispose);

    final options = modesContainer.read(ConfigOptions.singboxConfigOptions);

    expect(options.extraSecurity.mode, ChainMode.warp);
    expect(options.unblocker.mode, ChainMode.psiphon);
  });
}
