## Why

Корпоративный клиент не должен без явного согласия отправлять данные третьим сторонам. Сейчас аналитика (Sentry) включена по умолчанию. Интро определяет регион запросом к `api.ip.sb`, а экран per-app proxy предлагает опубликовать список приложений пользователя в публичном репозитории Hiddify на GitHub. Кроме того, для App Store нужно, чтобы privacy manifest и App Privacy соответствовали фактическому сбору данных.

## What Changes

- Аналитика выключена по умолчанию. Если пользователь явно её не включал, Sentry не инициализируется. На Android и десктопе включить аналитику по-прежнему можно в интро и в настройках.
- **iOS собирается без Sentry DSN, и аналитики на iOS нет совсем:** переключатель скрыт, контроллер всегда возвращает `false`. Для App Store это даёт честную декларацию App Privacy «Data Not Collected».
- Интро определяет регион только по часовому поясу устройства (`RegionDetector`). Запасной запрос к `api.ip.sb/geoip/` удаляется.
- На экране per-app proxy удаляется действие «Поделиться на GitHub» (`shareOnGithub`) вместе с диалогом подтверждения и строками перевода.

## Capabilities

### New Capabilities
- `telemetry`: какие данные и когда приложение отправляет третьим сторонам без явного действия пользователя.

### Modified Capabilities

## Impact

- Порядок слияния: **4-й**, после `hide-chain-features`.
- `Makefile` (`ios-release`: пустой `sentry_dsn`), `lib/features/common/general_pref_tiles.dart` (`EnableAnalyticsPrefTile`)
- `lib/core/analytics/analytics_controller.dart`
- `lib/features/intro/widget/intro_page.dart`
- `lib/features/per_app_proxy/overview/per_app_proxy_notifier.dart`, `per_app_proxy_page.dart`
- `assets/translations/*.i18n.json` (`dialogs.confirmation.perAppProxy.shareOnGithub`) → `dart run slang`
- Пользователи, у которых настройка аналитики не сохранена, перестают отправлять отчёты о сбоях.
