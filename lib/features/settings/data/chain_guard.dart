import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/features/settings/data/config_option_repository.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Resets the stored `chain-status` to `off` while chain is disabled by [kChainFeaturesEnabled].
///
/// On Android the tunnel may start without Dart (quick settings tile, Always-on VPN) with the options the core
/// saved earlier, so forcing `off` in `ConfigOptionRepository` is not enough: the core must receive fresh options.
/// [applyToCore] runs first and the preference is written only if it succeeds, so a failed attempt is retried on
/// the next launch. Core options never depend on the stored value: `ConfigOptionRepository` forces `off` anyway.
/// Returns `true` if the preference was reset.
Future<bool> resetDisabledChainStatus(
  ProviderContainer container, {
  required Future<bool> Function() applyToCore,
}) async {
  if (kChainFeaturesEnabled) return false;
  if (container.read(ConfigOptions.chainStatus).isOff()) return false;
  if (!await applyToCore()) return false;
  await container.read(ConfigOptions.chainStatus.notifier).update(ChainStatus.off);
  return true;
}
