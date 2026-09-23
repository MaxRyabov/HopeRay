## Why

Приложение позиционируется как корпоративный клиент защищённого доступа. Оно не должно ссылаться на Telegram и на каналы выдачи ключей. Сейчас такие ссылки есть в двух местах. Первое — жёстко прописанный контакт в экране «О программе». Второе — ссылки из заголовков подписки (`support-url`, `profile-web-page-url`): приложение сохраняет их в базу, а в коде лежит готовый виджет `ProfileTileMain`, который рисует их с иконками мессенджеров. Сейчас он не используется, но его легко «оживить», и тогда сервер ключей сможет вывести пользователю ссылку на бота.

## What Changes

- Удаляется пункт «Написать в Telegram» из экрана «О программе», константа `Constants.telegramChannelUrl` и ключ перевода `pages.about.telegramChannel` во всех локалях.
- Парсер подписки перестаёт сохранять `support-url` и `profile-web-page-url` в `SubscriptionInfo`. Заголовки убираются из `allowedProfileHeaders`.
- Удаляются неиспользуемые виджеты `ProfileTileMain` (`profile_tile_main.dart` целиком) и `NewSiteSubscriptionInfo`, которые умеют показывать ссылки сайта и поддержки с иконками мессенджеров. Используемая карточка `ProfileTile` ссылок не показывает, и это закрепляется тестом.
- `CODE_OF_CONDUCT.md`: контакт Telegram заменяется нейтральным.
- **BREAKING** для пользователей, у которых сервер подписки отдаёт ссылку поддержки: ссылка больше не видна в приложении.

## Capabilities

### New Capabilities
- `external-contacts`: какие внешние контакты и ссылки приложение показывает пользователю. Мессенджеров нет, ссылки из подписки не показываются.

### Modified Capabilities

## Impact

- `lib/core/model/constants.dart`, `lib/features/about/widget/about_page.dart`
- `lib/features/profile/data/profile_parser.dart`
- `lib/features/profile/widget/profile_tile_main.dart` (удаляется), `lib/features/profile/widget/profile_tile.dart`
- `.github/workflows/build.yml` (шаг `flutter analyze`), `CODE_OF_CONDUCT.md`
- `test/helpers/pump_app.dart` (новая обвязка widget-тестов)
- `assets/translations/*.i18n.json` (11 локалей), затем `dart run slang`
- `test/features/profile/data/profile_parser_test.dart`: сейчас проверяет `support-url`, ожидания меняются
- Порядок слияния change: **1-й** из шести (remove-external-contacts → key-only-onboarding → hide-chain-features → disable-telemetry-by-default → neutral-positioning-texts → ios-surface-hardening). Правки переводов в 11 локалях пересекаются с другими change, поэтому каждый следующий ветвится от результата предыдущего.
- В этом change заводится общая обвязка для widget-тестов `test/helpers/pump_app.dart` (оверрайды `sharedPreferencesProvider`, `translationsProvider`, MaterialApp). Остальные change её переиспользуют.
- Схема БД не меняется: колонки `web_page_url` и `support_url` остаются, но не заполняются и не читаются UI.
