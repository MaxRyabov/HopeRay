import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps [widget] inside a [ProviderScope] with English translations and
/// mocked [SharedPreferences] already loaded, so widgets that call
/// `ref.watch(translationsProvider).requireValue` render on the first frame.
Future<ProviderContainer> pumpApp(
  WidgetTester tester,
  Widget widget, {
  Map<String, Object> prefs = const {},
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPreferences = await SharedPreferences.getInstance();
  final translations = await AppLocale.en.build();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
      translationsProvider.overrideWith((ref) => translations),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  await container.read(sharedPreferencesProvider.future);
  await container.read(translationsProvider.future);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: Scaffold(body: widget)),
    ),
  );
  return container;
}
