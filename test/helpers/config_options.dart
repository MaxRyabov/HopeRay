import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/route_rules/notifier/rules_notifier.dart';
import 'package:hiddify/hiddifycore/generated/v2/config/route_rule.pb.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Container that builds real `ConfigOptions.singboxConfigOptions` from mocked [prefs].
///
/// A fixture built by the provider itself cannot drift from `SingboxConfigOption` the way a hand-written
/// JSON file would. Route rules are replaced with an empty list: the real notifier reads a file from app
/// directories, which tests don't have.
Future<ProviderContainer> configOptionsContainer({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
      rulesNotifierProvider.overrideWith(_NoRules.new),
    ],
  );
  await container.read(sharedPreferencesProvider.future);
  return container;
}

class _NoRules extends RulesNotifier {
  @override
  List<Rule> build() => <Rule>[];
}
