## 1. Аналитика

- [ ] 1.1 `AnalyticsController.build()`: `getBool(enableAnalyticsPrefKey) ?? false`
- [ ] 1.2 Проверить, что `EnableAnalyticsPrefTile` в интро и настройках показывает выключенное состояние на чистой установке
- [ ] 1.3 iOS: `AnalyticsController.build()` возвращает `false` на iOS; `EnableAnalyticsPrefTile` на iOS не рисуется (интро и `general_page.dart`)
- [ ] 1.4 `Makefile` `ios-release`: передавать `--build-dart-define sentry_dsn=` с пустым значением вместо `$(DISTRIBUTOR_ARGS)`-значения

## 2. Регион в интро

- [ ] 2.1 Удалить запасной запрос к `api.ip.sb/geoip/` из `IntroPage.autoSelectRegion` и ставший ненужным импорт `DioHttpClient`

## 3. Per-app proxy

- [ ] 3.1 Удалить `PerAppProxyNotifier.shareOnGithub` и его вызов в `per_app_proxy_page.dart`
- [ ] 3.2 Удалить во всех локалях `dialogs.confirmation.perAppProxy.shareOnGithub`, `pages.settings.routing.generalOptions.perAppProxy.options.shareToAll`, `pages.settings.routing.generalOptions.perAppProxy.autoSelection.toast.alreadyInAuto` (если после удаления `shareOnGithub` у него нет использований), `dart run slang`
- [ ] 3.3 `dart run build_runner build --delete-conflicting-outputs`, если менялись провайдеры

## 4. Тесты

- [ ] 4.1 Unit: `AnalyticsController` с пустыми `SharedPreferences` (`setMockInitialValues({})`) → `false`
- [ ] 4.2 Unit: с `enable_analytics = true` → `true`; с `false` → `false` (не на iOS; платформа подменяется через `debugDefaultTargetPlatformOverride`)
- [ ] 4.3 Unit: на iOS (`debugDefaultTargetPlatformOverride = TargetPlatform.iOS`) с `enable_analytics = true` → `false`

## 5. Проверка

- [ ] 5.1 CI зелёный: шаг `flutter analyze` (без ошибок) и `flutter test`
- [ ] 5.2 Grep по `lib/features/intro/`: нет `api.ip.sb` и `DioHttpClient`; по `lib/`: нет `Android-GFW-Apps/issues`
- [ ] 5.3 Вручную: чистая установка на Android → в логе приложения нет строки `enabling analytics`
- [ ] 5.4 Вручную: в логе CI-сборки iOS в команде fastforge `sentry_dsn=` пустой
