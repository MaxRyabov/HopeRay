import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/connection/data/connection_repository.dart';
import 'package:hiddify/features/settings/data/config_option_repository.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/singbox/model/singbox_config_option.dart';

import '../../../helpers/config_options.dart';

void main() {
  late SingboxConfigOption defaults;

  setUp(() async {
    final container = await configOptionsContainer();
    addTearDown(container.dispose);
    defaults = container.read(ConfigOptions.singboxConfigOptions);
  });

  SingboxConfigOption options(ChainStatus status, {ChainMode? extraSecurity, ChainMode? unblocker}) =>
      defaults.copyWith(
        chainStatus: status,
        extraSecurity: defaults.extraSecurity.copyWith(mode: extraSecurity ?? defaults.extraSecurity.mode),
        unblocker: defaults.unblocker.copyWith(mode: unblocker ?? defaults.unblocker.mode),
      );

  test('fresh install: extra security mode defaults to warp, yet no consent is asked', () {
    expect(defaults.chainStatus, ChainStatus.off);
    expect(defaults.extraSecurity.mode, ChainMode.warp);
    expect(requiresWarpConsent(defaults), isFalse);
  });

  test('chain off with warp in both modes does not ask for consent', () {
    expect(
      requiresWarpConsent(options(ChainStatus.off, extraSecurity: ChainMode.warp, unblocker: ChainMode.warp)),
      isFalse,
    );
  });

  test('extra security over warp asks for consent', () {
    expect(requiresWarpConsent(options(ChainStatus.extraSecurity, extraSecurity: ChainMode.warp)), isTrue);
  });

  test('extra security over psiphon does not ask, even if unblocker mode is warp', () {
    expect(
      requiresWarpConsent(
        options(ChainStatus.extraSecurity, extraSecurity: ChainMode.psiphon, unblocker: ChainMode.warp),
      ),
      isFalse,
    );
  });

  test('unblocker over psiphon does not ask, even if extra security mode is warp', () {
    expect(
      requiresWarpConsent(options(ChainStatus.unblocker, extraSecurity: ChainMode.warp, unblocker: ChainMode.psiphon)),
      isFalse,
    );
  });

  test('unblocker over warp asks for consent', () {
    expect(requiresWarpConsent(options(ChainStatus.unblocker, unblocker: ChainMode.warp)), isTrue);
  });
}
