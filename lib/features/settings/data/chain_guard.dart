import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/features/settings/data/config_option_repository.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Сбрасывает сохранённый `chain-status` в `off`, пока chain выключен флагом [kChainFeaturesEnabled].
///
/// Туннель на Android может подняться без Dart (плитка быстрых настроек, «Постоянная VPN») с опциями,
/// которые ядро сохранило раньше, поэтому выключения в `ConfigOptionRepository` мало. Возвращает `true`,
/// если настройку пришлось сбросить: тогда ядру нужно отправить актуальные опции.
Future<bool> resetDisabledChainStatus(ProviderContainer container) async {
  if (kChainFeaturesEnabled) return false;
  if (container.read(ConfigOptions.chainStatus).isOff()) return false;
  await container.read(ConfigOptions.chainStatus.notifier).update(ChainStatus.off);
  return true;
}
