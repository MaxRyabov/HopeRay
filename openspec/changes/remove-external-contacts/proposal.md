## Why

Приложение позиционируется как корпоративный клиент защищённого доступа. Оно не должно ссылаться на Telegram и на каналы выдачи ключей. Сейчас такие ссылки есть в двух местах. Первое — жёстко прописанный контакт в экране «О программе». Второе — ссылки из заголовков подписки (`support-url`, `profile-web-page-url`): приложение показывает их с иконками мессенджеров, поэтому сервер ключей может вывести пользователю ссылку на бота.

## What Changes

- Удаляется пункт «Написать в Telegram» из экрана «О программе», константа `Constants.telegramChannelUrl` и ключ перевода `pages.about.telegramChannel` во всех локалях.
- Парсер подписки перестаёт сохранять `support-url` и `profile-web-page-url` в `SubscriptionInfo`. Заголовки убираются из `allowedProfileHeaders`.
- Карточка профиля (`ProfileTileMain`) и `NewSiteSubscriptionInfo` больше не показывают ссылки сайта и поддержки, даже если они уже сохранены в БД у существующих установок. Удаляются распознавание Telegram, Instagram, X, Facebook и Hiddify в ссылках и список `verifiedLinks`.
- `CODE_OF_CONDUCT.md`: контакт Telegram заменяется нейтральным.
- **BREAKING** для пользователей, у которых сервер подписки отдаёт ссылку поддержки: ссылка больше не видна в приложении.

## Capabilities

### New Capabilities
- `external-contacts`: какие внешние контакты и ссылки приложение показывает пользователю. Мессенджеров нет, ссылки из подписки не показываются.

### Modified Capabilities

## Impact

- `lib/core/model/constants.dart`, `lib/features/about/widget/about_page.dart`
- `lib/features/profile/data/profile_parser.dart`
- `lib/features/profile/widget/profile_tile_main.dart`, `lib/features/profile/widget/profile_tile.dart`
- `assets/translations/*.i18n.json` (11 локалей), затем `dart run slang`
- `test/features/profile/data/profile_parser_test.dart`: сейчас проверяет `support-url`, ожидания меняются
- Порядок слияния change: **1-й** из шести (remove-external-contacts → key-only-onboarding → hide-chain-features → disable-telemetry-by-default → neutral-positioning-texts → ios-surface-hardening). Правки переводов в 11 локалях пересекаются с другими change, поэтому каждый следующий ветвится от результата предыдущего.
- В этом change заводится общая обвязка для widget-тестов `test/helpers/pump_app.dart` (оверрайды `sharedPreferencesProvider`, `translationsProvider`, MaterialApp). Остальные change её переиспользуют.
- Схема БД не меняется: колонки `web_page_url` и `support_url` остаются, но не заполняются и не читаются UI.
