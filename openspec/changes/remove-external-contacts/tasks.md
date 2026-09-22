## 1. Контакт Telegram

- [x] 1.1 Удалить `Constants.telegramChannelUrl` из `lib/core/model/constants.dart`
- [x] 1.2 Удалить `ListTile` с `t.pages.about.telegramChannel` из `lib/features/about/widget/about_page.dart`
- [x] 1.3 Удалить ключ `pages.about.telegramChannel` из всех `assets/translations/*.i18n.json`, запустить `dart run slang`
- [x] 1.4 Заменить контакт Telegram в `CODE_OF_CONDUCT.md` на нейтральный (адрес email проекта или ссылку на issues репозитория)

## 2. Парсер подписки

- [x] 2.1 Убрать `support-url` и `profile-web-page-url` из `ProfileParser.allowedProfileHeaders`
- [x] 2.2 Удалить заполнение `webPageUrl` и `supportUrl` в `ProfileParser.parse`
- [x] 2.3 Обновить ожидания в `test/features/profile/data/profile_parser_test.dart`: `webPageUrl` и `supportUrl` равны `null`
- [x] 2.4 Добавить тест: заголовки `support-url: https://t.me/somebot` и `profile-web-page-url` → в `subInfo` оба поля `null`, трафик и срок заполнены
- [x] 2.5 Добавить тест: `populateHeaders` не возвращает ключи `support-url` и `profile-web-page-url` ни из HTTP-заголовков, ни из строки `#support-url: …` в теле подписки

## 3. UI карточки профиля

- [x] 3.0 Завести `test/helpers/pump_app.dart`: `pumpApp(tester, widget, {prefs, overrides})` с `ProviderScope`, моками `SharedPreferences` (`setMockInitialValues`), готовым `translationsProvider` (en) и `MaterialApp`; её используют widget-тесты этого и следующих change

- [x] 3.1 Удалить `lib/features/profile/widget/profile_tile_main.dart` целиком (вызовов нет)
- [x] 3.2 В `profile_tile.dart` удалить `NewSiteSubscriptionInfo` и комментарий `TODO add support url`
- [x] 3.3 Если у `showUnknownDomainsWarning` не осталось вызовов, удалить его и связанный диалог
- [x] 3.4 Widget-тест: `ProfileTile` для профиля с заполненными `subInfo.supportUrl: https://t.me/x` и `webPageUrl` не содержит текстов `@x`, `t.me`, `t.components.subscriptionInfo.profileSupport`/`profileSite` и иконки Telegram

## 4. Проверка

- [x] 4.0 В job `test` в `.github/workflows/build.yml` добавить шаг `flutter analyze --no-fatal-infos --no-fatal-warnings` после `Prepare`: ошибки анализатора роняют CI, предупреждения не роняют

- [x] 4.1 `dart run build_runner build --delete-conflicting-outputs`, `dart run slang`
- [x] 4.2 CI зелёный: шаг `flutter analyze` (без ошибок) и `flutter test`
- [x] 4.3 Grep по `lib/` (без `lib/hiddifycore/generated/` и `lib/gen/`) и `assets/translations/` по регулярным выражениям `t\.me\b`, `telegram\.(me|org|dog)`, `tg://`, `telegramChannel`: совпадений нет
- [ ] 4.4 Вручную: экран «О программе» без пункта Telegram
