## 1. Удаление Sentry из кода

- [ ] 1.1 Удалить `lib/core/analytics/`, `lib/utils/sentry_riverpod_observer.dart`, `lib/utils/sentry_utils.dart` и их экспорт из `lib/utils/utils.dart`
- [ ] 1.2 `lib/bootstrap.dart`: убрать чтение `analyticsControllerProvider`, `enableAnalytics()` и `SentryUserInteractionWidget`
- [ ] 1.3 `lib/features/connection/notifier/connection_notifier.dart`: убрать `Sentry.captureException` и импорт
- [ ] 1.4 Удалить `EnableAnalyticsPrefTile` из `general_pref_tiles.dart`, `intro_page.dart`, `general_page.dart`
- [ ] 1.5 Удалить `Environment.sentryDSN`
- [ ] 1.6 `ios/Runner/AppDelegate.swift`: удалить `import Sentry` и использование, если есть
- [ ] 1.7 Удалить закомментированный `SentryWidgetsFlutterBinding` в `lib/main.dart`

## 2. Зависимости и сборка

- [ ] 2.1 `pubspec.yaml`: удалить `sentry_flutter`, `sentry_dart_plugin` и секцию `sentry:`; `flutter pub get`
- [ ] 2.2 `ios/Podfile.lock` обновить без `Sentry` (из CI-артефакта или на маке `pod install`), закоммитить
- [ ] 2.3 `Makefile`: убрать `sentry_dsn` из `BUILD_ARGS`, `DISTRIBUTOR_ARGS` и явных `--build-dart-define=sentry_dsn=...` в windows/linux/android-целях
- [ ] 2.4 `.github/workflows/build.yml`: убрать `SENTRY_DSN` из env шага сборки и шаг «Upload Debug Symbols»; `.github/workflows/ios-testflight.yml`: убрать `SENTRY_DSN`
- [ ] 2.5 `dart run build_runner build --delete-conflicting-outputs`

## 3. Регион в интро

- [ ] 3.1 Удалить запасной запрос к `api.ip.sb/geoip/` из `IntroPage.autoSelectRegion` и ставший ненужным импорт `DioHttpClient`

## 4. Per-app proxy

- [ ] 4.1 Удалить `PerAppProxyNotifier.shareOnGithub` и его вызов в `per_app_proxy_page.dart`

## 5. Строки перевода

- [ ] 5.1 Удалить во всех локалях:
  - строки переключателя аналитики;
  - `dialogs.confirmation.perAppProxy.shareOnGithub`;
  - `pages.settings.routing.generalOptions.perAppProxy.options.shareToAll`;
  - `pages.settings.routing.generalOptions.perAppProxy.autoSelection.toast.alreadyInAuto`, если у него не осталось использований.
- [ ] 5.2 `dart run slang`

## 6. Тесты

- [ ] 6.1 Тест зависимостей: читает `pubspec.yaml` и `ios/Podfile.lock`, проверяет отсутствие `sentry` (без учёта регистра)
- [ ] 6.2 Widget-тест (через `test/helpers/pump_app.dart`) общих настроек: нет переключателя аналитики

## 7. Проверка

- [ ] 7.1 CI зелёный: шаг `flutter analyze` (без ошибок), `flutter test` и все сборки
- [ ] 7.2 Grep по `lib/`, `ios/Runner/`, `macos/Runner/`, `android/app/src/`, `Makefile`, `.github/workflows/`: нет `sentry` без учёта регистра; по `lib/features/intro/`: нет `api.ip.sb` и `DioHttpClient`; по `lib/`: нет `Android-GFW-Apps/issues`
- [ ] 7.3 Снимок трафика: чистая установка на Android через mitmproxy → интро → окно добавления профиля. Нет запросов к `sentry.io`, `api.ip.sb`, `raw.githubusercontent.com/hiddify/hiddify-app`; запросы проверки обновлений перечислить в отчёте MR
