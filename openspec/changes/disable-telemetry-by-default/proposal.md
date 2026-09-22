## Why

Корпоративный клиент не должен отправлять данные третьим сторонам. Для App Store нужна честная декларация App Privacy «Data Not Collected». Сейчас это не так:
- аналитика (Sentry) включена по умолчанию;
- SDK `sentry-cocoa` сам объявляет в своём privacy manifest сбор Crash, Performance и Other Diagnostic Data, поэтому даже невключённый Sentry не даёт честного «Data Not Collected»;
- интро определяет регион запросом к `api.ip.sb`;
- экран per-app proxy предлагает опубликовать список приложений пользователя в публичном репозитории Hiddify на GitHub.

## What Changes

- **BREAKING:** Sentry удаляется из приложения на всех платформах:
  - пакеты `sentry_flutter` и `sentry_dart_plugin`, секция `sentry:` в `pubspec.yaml`;
  - `lib/core/analytics/*`, `lib/utils/sentry_*.dart`, `SentryUserInteractionWidget`, `Sentry.captureException`;
  - `import Sentry` в `ios/Runner/AppDelegate.swift`;
  - переключатель аналитики в интро и настройках (`EnableAnalyticsPrefTile`) и его строки перевода;
  - `Environment.sentryDSN`, `sentry_dsn` в `Makefile`, `SENTRY_DSN` и шаг «Upload Debug Symbols» в CI.

  Отчётов о сбоях больше нет; диагностика остаётся через логи приложения.
- Интро определяет регион только по часовому поясу устройства (`RegionDetector`). Запасной запрос к `api.ip.sb/geoip/` удаляется.
- На экране per-app proxy удаляется действие «Поделиться на GitHub» (`shareOnGithub`) вместе с диалогом подтверждения и строками перевода.

## Capabilities

### New Capabilities
- `telemetry`: какие данные и когда приложение отправляет третьим сторонам без явного действия пользователя.

### Modified Capabilities

## Impact

- Порядок слияния: **4-й**, после `hide-chain-features`.
- `pubspec.yaml`, `pubspec.lock`, `ios/Podfile.lock`, сгенерированные регистранты плагинов (`windows/flutter/`, `linux/flutter/`, `macos/Flutter/`) — через `flutter pub get`; `ios/Runner/AppDelegate.swift`
- `lib/bootstrap.dart`, `lib/main.dart`, `lib/core/analytics/`, `lib/utils/sentry_riverpod_observer.dart`, `lib/utils/sentry_utils.dart`, `lib/utils/utils.dart`, `lib/core/model/environment.dart`, `lib/features/connection/notifier/connection_notifier.dart`
- `lib/features/common/general_pref_tiles.dart`, `lib/features/intro/widget/intro_page.dart`, `lib/features/settings/overview/sections/general_page.dart`
- `lib/features/per_app_proxy/overview/per_app_proxy_notifier.dart`, `per_app_proxy_page.dart`
- `Makefile` (`sentry_dsn` в `BUILD_ARGS`/`DISTRIBUTOR_ARGS`), `.github/workflows/build.yml` (`SENTRY_DSN`, «Upload Debug Symbols»), `.github/workflows/ios-testflight.yml` (`SENTRY_DSN`)
- `assets/translations/*.i18n.json` → `dart run slang`
