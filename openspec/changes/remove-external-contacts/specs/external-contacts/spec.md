## ADDED Requirements

### Requirement: Нет контактов мессенджеров
Приложение MUST NOT содержать в интерфейсе ссылок на Telegram и другие мессенджеры: ни пунктов меню, ни кнопок, ни текста с адресами `t.me` или `telegram.me`.

#### Scenario: Экран «О программе» без Telegram
- **WHEN** пользователь открывает экран «О программе»
- **THEN** на экране нет пункта «Contact on Telegram» / «Написать в Telegram» и нет ссылок на `t.me` или `telegram.me`

#### Scenario: Нет строк перевода про Telegram
- **WHEN** проверяются файлы `assets/translations/*.i18n.json`
- **THEN** ключа `pages.about.telegramChannel` нет ни в одной локали

### Requirement: Ссылки из заголовков подписки не сохраняются
Парсер профиля MUST игнорировать заголовки `support-url` и `profile-web-page-url`. Поля `SubscriptionInfo.supportUrl` и `SubscriptionInfo.webPageUrl` у профиля после парсинга MUST быть `null`, какие бы значения ни прислал сервер.

#### Scenario: Сервер присылает ссылку поддержки на бота
- **WHEN** удалённый профиль обновляется с заголовками `subscription-userinfo`, `support-url: https://t.me/somebot` и `profile-web-page-url: https://example.com`
- **THEN** у распарсенного профиля `subInfo.supportUrl == null` и `subInfo.webPageUrl == null`
- **AND** остальные поля `subInfo` (upload, download, total, expire) заполнены как раньше

#### Scenario: Заголовки не попадают в сохранённые заголовки профиля
- **WHEN** выполняется `ProfileParser.populateHeaders` для ответа с заголовками `support-url` и `profile-web-page-url`
- **THEN** в результате нет ключей `support-url` и `profile-web-page-url`

#### Scenario: Ссылка передана строкой в теле подписки
- **WHEN** тело подписки содержит в первых строках `#support-url: https://t.me/somebot`, а HTTP-заголовка нет
- **THEN** `ProfileParser.populateHeaders` не возвращает ключ `support-url`

### Requirement: Карточка профиля не показывает ссылки сайта и поддержки
Карточка профиля MUST NOT показывать ссылки сайта и поддержки провайдера, даже если они сохранены в базе у профилей, импортированных до обновления.

#### Scenario: Старый профиль с сохранённой ссылкой поддержки
- **WHEN** в базе есть профиль с непустыми `support_url` и `web_page_url` и пользователь открывает главный экран или список профилей
- **THEN** в карточке профиля нет блока ссылок сайта и поддержки и нет иконок мессенджеров
- **AND** показатели трафика и срока действия отображаются как раньше
