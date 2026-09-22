## ADDED Requirements

### Requirement: Нет SDK отчётов о сбоях и аналитики
Приложение MUST NOT содержать SDK отчётов о сбоях и аналитики (Sentry и аналогов) ни на одной платформе. Оно MUST NOT предлагать пользователю включить аналитику.

#### Scenario: Зависимости
- **WHEN** проверяются `pubspec.yaml` и `ios/Podfile.lock`
- **THEN** в них нет `sentry_flutter`, `sentry_dart_plugin` и `Sentry`

#### Scenario: Код приложения
- **WHEN** по `lib/`, `ios/Runner/`, `ios/Runner.xcodeproj/`, `macos/`, `android/app/src/`, `windows/flutter/`, `linux/flutter/` ищется регулярное выражение `\bsentry` без учёта регистра
- **THEN** совпадений нет

#### Scenario: Экраны интро и общих настроек
- **WHEN** пользователь открывает интро или общие настройки
- **THEN** переключателя аналитики нет

#### Scenario: Сборка
- **WHEN** проверяются `Makefile`, `.github/workflows/build.yml` и `.github/workflows/ios-testflight.yml`
- **THEN** в них нет `sentry_dsn`, `SENTRY_DSN` и шагов загрузки символов Sentry

### Requirement: Регион без сетевых запросов
Интро MUST определять регион без сетевых запросов к сторонним сервисам геолокации.

#### Scenario: Код интро без запросов геолокации
- **WHEN** проверяется код `lib/features/intro/`
- **THEN** в нём нет HTTP-клиентов и адресов сервисов геолокации (`api.ip.sb` и аналогов)

### Requirement: Нет публикации данных пользователя во внешние репозитории
Приложение MUST NOT предлагать публиковать данные пользователя (список установленных приложений и другие) в публичные репозитории и трекеры задач.

#### Scenario: Экран per-app proxy
- **WHEN** пользователь открывает экран per-app proxy на Android
- **THEN** на экране нет действия «Поделиться на GitHub», и приложение не открывает `github.com/hiddify/Android-GFW-Apps/issues/new`

### Requirement: Нет фоновых запросов к сторонним хостам при первом запуске
При первом запуске, пока пользователь не добавил ключ, приложение MUST NOT обращаться к сторонним хостам. Исключение — проверка обновлений (см. design, Non-Goals).

#### Scenario: Снимок трафика чистой установки
- **WHEN** приложение впервые устанавливается и запускается на Android, трафик устройства снимается через PCAPdroid (захват через VpnService, видны DNS и SNI; системный прокси не годится — Dio задаёт свой `findProxy`), пользователь проходит интро и открывает окно добавления профиля
- **THEN** в снимке трафика нет запросов к `sentry.io`, `api.ip.sb`, `raw.githubusercontent.com/hiddify/hiddify-app` и другим хостам, кроме хостов проверки обновлений
