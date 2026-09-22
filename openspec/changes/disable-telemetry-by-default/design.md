## Context

- `AnalyticsController.build()` возвращает `getBool(enable_analytics) ?? true`. `bootstrap.dart` при `true` вызывает `enableAnalytics()`, то есть `SentryFlutter.init`. Корень приложения обёрнут в `SentryUserInteractionWidget`. `ConnectionNotifier` вызывает `Sentry.captureException`. DSN приходит через `--dart-define sentry_dsn` (`Makefile` `BUILD_ARGS`/`DISTRIBUTOR_ARGS`, `SENTRY_DSN` в CI).
- `sentry-cocoa` 8.46.0 (`ios/Podfile.lock`) в своём `PrivacyInfo.xcprivacy` объявляет CrashData, PerformanceData и OtherDiagnosticData. Проверено по тегу 8.46.0 в `getsentry/sentry-cocoa`. Поэтому, пока SDK слинкован, сводный privacy report iOS-архива не может быть «Data Not Collected». Исключить Sentry только из iOS нельзя: Flutter-плагин общий для всех платформ.
- `IntroPage.autoSelectRegion` сначала определяет регион по часовому поясу. При исключении он запрашивает `https://api.ip.sb/geoip/`.
- `PerAppProxyNotifier.shareOnGithub` открывает в браузере issue в `hiddify/Android-GFW-Apps` со списком пакетов пользователя.

## Goals / Non-Goals

**Goals:**
- Приложение не отправляет данных третьим сторонам без явного действия пользователя.
- Сводный privacy report iOS-архива пуст, App Privacy — «Data Not Collected».

**Non-Goals:**
- Проверки IP на главном экране (`proxy_repository.dart`: ipwho.is, api.ip.sb, ipinfo.io и другие). Они показывают внешний IP после подключения и идут через туннель. Отдельное решение.
- Автопроверка обновлений при старте (`UpgradeAlert` в `app.dart`: iTunes lookup на iOS, `appcast`/GitHub на остальных). Данных пользователя не передаёт. Решение отложено до своего сервера обновлений.
- Автовыбор per-app proxy со списками из `hiddify/Android-GFW-Apps` (`auto_selection_repository.dart`) и выбор региона в интро (флаги IR/CN/RU/AF). Это маршрутизация; по решению продукта остаётся как есть, вопрос позиционирования («GFW», флаги) отложен.
- Privacy manifest приложения: в change `ios-surface-hardening`.

## Decisions

- **Удалить Sentry целиком**, а не выключить по умолчанию. Только так iOS получает честное «Data Not Collected». Альтернатива — оставить SDK и задекларировать Crash/Performance/Diagnostic Data. Отклонено решением продукта.
- **Удаляемое:**
  - пакеты `sentry_flutter`, `sentry_dart_plugin` и секция `sentry:` в `pubspec.yaml`;
  - `lib/core/analytics/` (`analytics_controller`, `analytics_filter`, `analytics_logger`), `lib/utils/sentry_riverpod_observer.dart`, `lib/utils/sentry_utils.dart` и их экспорт в `utils.dart`;
  - `SentryUserInteractionWidget` в `bootstrap.dart` и вызов `enableAnalytics`;
  - `Sentry.captureException` в `connection_notifier.dart` (ошибка уже логируется);
  - `EnableAnalyticsPrefTile` и его строки перевода;
  - `Environment.sentryDSN`;
  - `import Sentry` в `AppDelegate.swift`.

  Регистранты плагинов и lock-файлы обновляются через `flutter pub get` на CI. `ios/Podfile.lock` обновится при `pod install` в CI; его нужно закоммитить из артефакта или с мака, иначе он будет расходиться с Podfile.
- **Сохранённый ключ `enable_analytics` в SharedPreferences не чистится.** Его больше никто не читает.
- **CI и Makefile:** убрать `--dart-define sentry_dsn` из `BUILD_ARGS` и `DISTRIBUTOR_ARGS`, `SENTRY_DSN` из env сборки, шаг «Upload Debug Symbols» из `build.yml`, `SENTRY_DSN` из `ios-testflight.yml`. Секреты `SENTRY_*` в репозитории можно удалить отдельно.
- **Удалить запасной geo-IP запрос**, а не заменить другим сервисом. Регион по часовому поясу срабатывает почти всегда. При неудаче `RegionDetector` возвращает значение по умолчанию, и пользователь может выбрать регион на экране интро.
- **Удалить `shareOnGithub` целиком**, вместе с кнопкой на `per_app_proxy_page.dart` и строками перевода.

## Risks / Trade-offs

- [Нет отчётов о сбоях с устройств пользователей] → диагностика через логи (`LogsPage`, экспорт логов). Если понадобится сбор, это отдельное решение с декларацией в App Privacy.
- [`ios/Podfile.lock` на Windows не обновить] → берётся из CI или с мака. Проверяется тем, что в `Podfile.lock` нет `Sentry` (сценарий «Зависимости»).
- [Снимок трафика показывает запросы проверки обновлений] → они явно исключены в спеке, см. Non-Goals.
