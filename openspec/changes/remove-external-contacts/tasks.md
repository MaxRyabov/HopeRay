## 1. Контакт Telegram

- [ ] 1.1 Удалить `Constants.telegramChannelUrl` из `lib/core/model/constants.dart`
- [ ] 1.2 Удалить `ListTile` с `t.pages.about.telegramChannel` из `lib/features/about/widget/about_page.dart`
- [ ] 1.3 Удалить ключ `pages.about.telegramChannel` из всех `assets/translations/*.i18n.json`, запустить `dart run slang`
- [ ] 1.4 Заменить контакт Telegram в `CODE_OF_CONDUCT.md` на нейтральный (адрес email проекта или ссылку на issues репозитория)

## 2. Парсер подписки

- [ ] 2.1 Убрать `support-url` и `profile-web-page-url` из `ProfileParser.allowedProfileHeaders`
- [ ] 2.2 Удалить заполнение `webPageUrl` и `supportUrl` в `ProfileParser.parse`
- [ ] 2.3 Обновить ожидания в `test/features/profile/data/profile_parser_test.dart`: `webPageUrl` и `supportUrl` равны `null`
- [ ] 2.4 Добавить тест: заголовки `support-url: https://t.me/somebot` и `profile-web-page-url` → в `subInfo` оба поля `null`, трафик и срок заполнены
- [ ] 2.5 Добавить тест: `populateHeaders` не возвращает ключи `support-url` и `profile-web-page-url` ни из HTTP-заголовков, ни из строки `#support-url: …` в теле подписки

## 3. UI карточки профиля

- [ ] 3.1 В `profile_tile_main.dart` удалить блок ссылок сайта и поддержки, `_launchUrlWithCheck`, `_getLinkIcon`, `_formatSupportLink`, `verifiedDomains`, `verifiedLinks` и неиспользуемые импорты
- [ ] 3.2 В `profile_tile.dart` удалить `NewSiteSubscriptionInfo`, если у него нет вызовов
- [ ] 3.3 Если у `showUnknownDomainsWarning` не осталось вызовов, удалить его и связанный диалог
- [ ] 3.4 Widget-тест: `ProfileTileMain` для профиля с заполненными `supportUrl: https://t.me/x` и `webPageUrl` не содержит текстов `@x` и `profileSupport`/`profileSite` и не содержит иконки Telegram

## 4. Проверка

- [ ] 4.1 `dart run build_runner build --delete-conflicting-outputs`, `dart run slang`
- [ ] 4.2 `flutter analyze` без новых замечаний, `flutter test` зелёный (в CI)
- [ ] 4.3 Grep по `lib/` и `assets/translations/`: нет `t.me`, `telegram.me`, `telegramChannel`
