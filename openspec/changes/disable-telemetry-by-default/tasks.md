## 1. Аналитика

- [ ] 1.1 `AnalyticsController.build()`: `getBool(enableAnalyticsPrefKey) ?? false`
- [ ] 1.2 Проверить, что `EnableAnalyticsPrefTile` в интро и настройках показывает выключенное состояние на чистой установке

## 2. Регион в интро

- [ ] 2.1 Удалить запасной запрос к `api.ip.sb/geoip/` из `IntroPage.autoSelectRegion` и ставший ненужным импорт `DioHttpClient`

## 3. Per-app proxy

- [ ] 3.1 Удалить `PerAppProxyNotifier.shareOnGithub` и его вызов в `per_app_proxy_page.dart`
- [ ] 3.2 Удалить `dialogs.confirmation.perAppProxy.shareOnGithub` и другие ставшие неиспользуемыми ключи во всех локалях, `dart run slang`
- [ ] 3.3 `dart run build_runner build --delete-conflicting-outputs`, если менялись провайдеры

## 4. Тесты

- [ ] 4.1 Unit: `AnalyticsController` с пустыми `SharedPreferences` (`setMockInitialValues({})`) → `false`
- [ ] 4.2 Unit: с `enable_analytics = true` → `true`; с `false` → `false`

## 5. Проверка

- [ ] 5.1 `flutter analyze` без новых замечаний, `flutter test` зелёный (в CI)
- [ ] 5.2 Grep по `lib/`: нет `api.ip.sb`, `Android-GFW-Apps/issues`
