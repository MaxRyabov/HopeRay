## 1. Удаление Sentry из кода

- [ ] 1.1 Удалить `lib/core/analytics/`, `lib/utils/sentry_riverpod_observer.dart`, `lib/utils/sentry_utils.dart` и их экспорт из `lib/utils/utils.dart`
- [ ] 1.2 `lib/bootstrap.dart`: убрать чтение `analyticsControllerProvider`, `enableAnalytics()`, `SentryUserInteractionWidget` и комментарии про `SentryFlutter`
- [ ] 1.3 `lib/features/connection/notifier/connection_notifier.dart`: убрать `Sentry.captureException` и импорт
- [ ] 1.4 Удалить `EnableAnalyticsPrefTile` из `general_pref_tiles.dart`, `intro_page.dart`, `general_page.dart`; удалить вызов `disableAnalytics` в FAB интро
- [ ] 1.5 Удалить `Environment.sentryDSN`
- [ ] 1.6 `ios/Runner/AppDelegate.swift`: удалить `import Sentry` и использование, если есть
- [ ] 1.7 Удалить закомментированный `SentryWidgetsFlutterBinding` в `lib/main.dart`

## 2. Зависимости и сборка

- [ ] 2.1 `pubspec.yaml`: удалить `sentry_flutter`, `sentry_dart_plugin` и секцию `sentry:`; `flutter pub get`
- [ ] 2.2 `ios/Podfile.lock` и `macos/Podfile.lock`: вручную удалить записи `Sentry`, `Sentry/HybridSDK`, `sentry_flutter` в PODS, DEPENDENCIES, EXTERNAL SOURCES, SPEC CHECKSUMS (`PODFILE CHECKSUM` считается от Podfile и не меняется); результат проверяется iOS- и macOS-сборками в CI без diff в lock
- [ ] 2.3 `Makefile`: убрать `sentry_dsn` из `BUILD_ARGS`, `DISTRIBUTOR_ARGS` и явных `--build-dart-define=sentry_dsn=...` в windows/linux/android-целях
- [ ] 2.4 `.github/workflows/build.yml`: убрать `SENTRY_DSN` из env шага сборки, шаг «Upload Debug Symbols» и `--dart-define sentry_dsn=` в PR-сборке iOS; `.github/workflows/ios-testflight.yml`: убрать `SENTRY_DSN`
- [ ] 2.4a `ios/Runner.xcodeproj/project.pbxproj`: удалить ссылки на `Sentry.xcframework`, `SentryPrivate`, `sentry_flutter`
- [ ] 2.4b Закоммитить перегенерированные регистранты плагинов (`windows/flutter/`, `linux/flutter/`, `macos/Flutter/GeneratedPluginRegistrant.swift`)
- [ ] 2.4c `CLAUDE.md`: убрать упоминание обязательного `SENTRY_DSN` для release-сборок
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
- [ ] 6.2 Widget-тесты (через `test/helpers/pump_app.dart`) общих настроек и `IntroPage`: нет переключателя аналитики

## 7. Проверка

- [ ] 7.1 CI зелёный: шаг `flutter analyze` (без ошибок), `flutter test` и все сборки
- [ ] 7.2 Grep регулярным выражением `\bsentry` без учёта регистра по `lib/`, `ios/Runner/`, `ios/Runner.xcodeproj/`, `ios/Podfile.lock`, `macos/`, `android/app/src/`, `windows/flutter/`, `linux/flutter/`, `Makefile`, `.github/workflows/`, `pubspec.yaml`: совпадений нет; по `lib/features/intro/`: нет `api.ip.sb` и `DioHttpClient`; по `lib/`: нет `Android-GFW-Apps/issues`
- [ ] 7.3 Снимок трафика: чистая установка на Android, захват PCAPdroid (DNS и SNI) → интро → окно добавления профиля. Нет запросов к `sentry.io`, `api.ip.sb`, `raw.githubusercontent.com/hiddify/hiddify-app`; запросы проверки обновлений перечислить в отчёте MR
