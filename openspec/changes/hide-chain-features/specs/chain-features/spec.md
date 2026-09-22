## ADDED Requirements

### Requirement: Chain недоступен из интерфейса
Приложение MUST NOT показывать элементы управления цепочками Extra security / Unblocker (WARP, Psiphon). Экран настроек chain MUST быть недостижим.

#### Scenario: Настройки без пункта chain
- **WHEN** пользователь с добавленным профилем открывает «Настройки»
- **THEN** в списке нет раздела chain («Extra security & Unblocker»)

#### Scenario: Быстрые настройки без chain
- **WHEN** пользователь открывает быстрые настройки
- **THEN** в них нет переключателей Extra security, Unblocker, WARP и Psiphon

#### Scenario: Прямой переход по пути
- **WHEN** приложение пытается открыть путь `/settings/chain-options`
- **THEN** экран chain не открывается

### Requirement: Ядро всегда получает выключенный chain
Опции, которые передаются ядру, MUST содержать `chainStatus = off`, независимо от сохранённой пользовательской настройки, заголовков подписки и пользовательских переопределений профиля.

#### Scenario: Chain был включён до обновления
- **WHEN** в настройках сохранено `chain-status = extraSecurity` или `unblocker` и строятся опции ядра
- **THEN** итоговые опции содержат `chainStatus = off`

#### Scenario: Сервер присылает enable-warp
- **WHEN** у профиля в заголовках есть `enable-warp: true` и строятся опции ядра с переопределениями этого профиля
- **THEN** итоговые опции содержат `chainStatus = off`
- **AND** `ProfileParser.profileOverride` не возвращает ключей `chain-status` и `extra-security`

#### Scenario: Пользовательский флаг enableWarp
- **WHEN** у профиля в `UserOverride` стоит `enableWarp = true`
- **THEN** `ProfileParser.profileOverride` не возвращает ключей `chain-status` и `extra-security`

### Requirement: Сохранённый chain сбрасывается при запуске
При запуске приложения, если функция chain выключена, а в настройках сохранено `chain-status` не `off`, приложение MUST сбросить настройку в `off` и передать ядру актуальные опции.

#### Scenario: Обновление поверх установки с включённым chain
- **WHEN** приложение запускается впервые после обновления, и в настройках сохранено `chain-status = extraSecurity`
- **THEN** после запуска в настройках `chain-status = off`
- **AND** последующий запуск туннеля без UI (плитка быстрых настроек Android) идёт без WARP и Psiphon

### Requirement: WARP-профили не принимаются
Приложение MUST NOT добавлять, обновлять и подключать профиль, содержимое которого задаёт WARP: строки со схемой `warp://` или конфигурацию с outbound или endpoint типа `warp`. Это касается содержимого в открытом виде и в base64.

#### Scenario: Вставка warp:// из буфера обмена
- **WHEN** пользователь добавляет из буфера обмена текст `warp://auto#WARP`
- **THEN** профиль не добавляется, пользователь видит ошибку о неподдерживаемой конфигурации

#### Scenario: Подписка содержит WARP
- **WHEN** удалённая подписка (в том числе в base64) содержит строку `warp://…` или JSON с `"type": "warp"`
- **THEN** профиль не добавляется или не обновляется, ранее сохранённое содержимое профиля не перезаписывается

#### Scenario: WARP-профиль, сохранённый до обновления
- **WHEN** активный профиль, добавленный до обновления, содержит WARP, и пользователь нажимает «Подключиться»
- **THEN** подключение не выполняется, пользователь видит ошибку о неподдерживаемой конфигурации

### Requirement: Нет диалога WARP без включённого WARP
Диалог согласия с лицензией Cloudflare WARP MUST показываться только когда chain включён и активная ступень использует режим WARP. Когда chain выключен, диалог MUST NOT показываться.

#### Scenario: Первое подключение после установки
- **WHEN** пользователь впервые подключается, согласия на WARP нет, а `extraSecurityMode` имеет значение по умолчанию `warp`
- **THEN** диалог лицензии WARP не показывается и подключение продолжается

### Requirement: Режим Unblocker берётся из своей настройки
Поле `unblocker.mode` в опциях ядра MUST заполняться из настройки `unblockerMode`, а не из `extraSecurityMode`.

#### Scenario: Разные режимы ступеней
- **WHEN** `extraSecurityMode = warp`, `unblockerMode = psiphon` и строятся опции ядра
- **THEN** `extraSecurity.mode == warp` и `unblocker.mode == psiphon`
