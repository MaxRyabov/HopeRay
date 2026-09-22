## Context

Как chain сейчас попадает в ядро:
- `ConfigOptions.singboxConfigOptions` собирает `SingboxConfigOption`. В нём `chainStatus` берётся из настройки, по умолчанию `off`.
- `ConfigOptionRepository.fullOptionsOverrided(profileOverride)` накладывает переопределения профиля через `ProfileParser.applyProfileOverride`.
- `ProfileParser.profileOverride` превращает `enable-warp: true` из заголовков или `UserOverride.enableWarp` в `chain-status: extra_security` + `extra-security.mode: warp`. Прямые ключи `chain-status` и `extra-security` из подписки сюда не доходят: их нет в `allowedProfileHeaders`, хотя в `allowedOverrideConfigs` они есть.
- `ConnectionRepository.applyConfigOption` показывает диалог WARP, если `unblocker.mode.isWarp() || extraSecurity.mode.isWarp()`, и не проверяет `chainStatus`. `extraSecurityMode` по умолчанию `warp`, а `unblocker.mode` ошибочно берётся из `extraSecurityMode` (строка `mode: ref.watch(extraSecurityMode)` в блоке `SingboxUnblockerOption`). Поэтому диалог WARP может появиться при первом подключении без всякого chain.

Входы в UI: `SettingsSection` → `chainOptions` в `settings_page.dart`, `ChainQuickSettings` в `quick_settings_modal.dart`, `goNamed('chainOptions')` внутри `lib/features/chain/overview/*`. Все они достижимы только из этих двух мест.

## Goals / Non-Goals

**Goals:**
- Ни пользователь, ни сервер подписки не могут включить chain.
- Диалог WARP не появляется, пока chain выключен.
- Вернуть функцию можно одним флагом.

**Non-Goals:**
- Удаление кода `lib/features/chain/`, `chain_options_page.dart`, WARP/Psiphon-настроек и строк перевода. Код остаётся недостижимым. Строки про «обход» убираются в `neutral-positioning-texts` вместе с остальными.
- Изменение нативного ядра.
- Предзагрузка `chainProfileNotifierProvider` в `bootstrap.dart`: она только синхронизирует id профилей и без UI ни на что не влияет.

## Decisions

- **Один флаг `kChainFeaturesEnabled = false`** в `lib/core/model/constants.dart` (или рядом с `ConfigOptions`). От него зависят UI-входы, маршрут и принудительное выключение. Альтернатива — удалить входы без флага; отклонено, потому что по решению руководства функция должна возвращаться быстро.
- **Выключение в `ConfigOptionRepository`, а не в провайдере.** `fullOptions()` и `fullOptionsOverrided()` после наложения переопределений делают `copyWith(chainStatus: ChainStatus.off)`, если флаг выключен. Ядро получает опции только через `fullOptionsOverrided` (`connection_repository.dart`, `profile_repository.dart`); у `fullOptions()` сейчас нет вызовов, но выключение ставится и туда, чтобы путь не открылся в будущем. Это последняя точка перед ядром, её обходят и настройки, и переопределения. К тому же репозиторий тестируется без Riverpod: достаточно передать `getConfigOptions`.
- **`profileOverride` не порождает ключи chain при выключенном флаге.** `enable-warp` и `UserOverride.enableWarp` игнорируются, а `chain-status` и `extra-security` удаляются из результата. Вместе с предыдущим пунктом это двойная защита, и каждую часть можно проверить unit-тестом.
- **Условие диалога WARP — чистая функция** `bool requiresWarpConsent(SingboxConfigOption o)`:
  - `chainStatus == extraSecurity && extraSecurity.mode.isWarp()`, или
  - `chainStatus == unblocker && unblocker.mode.isWarp()`.

  Используется в `applyConfigOption`. Функция чистая, поэтому тестируется без UI.
- **Маршрут `chainOptions` регистрируется только при включённом флаге.** Если маршрута нет, go_router на `/settings/chain-options` показывает страницу ошибки, а не экран chain. Существующий redirect для `chain-options` удаляется вместе с маршрутом.
- **Исправить `unblocker.mode`** на `ref.watch(unblockerMode)`.
- **Сброс сохранённого `chain-status` при запуске.** На Android туннель может подняться без Dart: `BootReceiver` (`ACTION_MY_PACKAGE_REPLACED`) и `TileService` вызывают `Mobile.start` с опциями, которые ядро сохранило раньше. Поэтому одного выключения в `ConfigOptionRepository` мало. В `bootstrap.dart` после инициализации ядра: если флаг выключен и сохранено не `off`, настройка сбрасывается в `off` и ядру отправляются актуальные опции через `changeOptions(fullOptionsOverrided(activeProfile.profileOverride()))`. Выключенный флаг означает, что сохранённый выбор пользователя теряется. Это осознанно: при возврате функции никто не получит WARP молча (см. Risks). Как именно ядро хранит опции между запусками, не проверено (сабмодуль `hiddify-core` не выкачан). Первая задача реализации — подтвердить это вручную на Android.
- **Проверка содержимого на WARP — чистая функция** `ProfileParser.containsWarp(String content)`. Контент декодируется через `safeDecodeBase64`, ищутся строки со схемой `warp://` и JSON с `"type": "warp"` (outbound или endpoint). Вызов стоит в `ProfileRepositoryImpl.validateConfig`, через который проходят все пути добавления и обновления (`upsertRemote`, `addLocal`, `offlineUpdate`, обновление подписки), до валидации ядром. При срабатывании возвращается `ProfileFailure.invalidConfig` с сообщением о неподдерживаемой конфигурации. Для профилей, сохранённых до обновления, та же проверка стоит в `ConnectionRepository` перед стартом: читается файл профиля из `profilePathResolver`. Обычный WireGuard к серверам Cloudflare таким способом не распознаётся; это вне scope, пользователь сам вводит ключи.

## Risks / Trade-offs

- [Пользователи, у которых работал только WARP без ключа, теряют доступ] → это требование продукта.
- [Недостижимый код устаревает и перестаёт компилироваться при рефакторинге] → он продолжает компилироваться и проходит `flutter analyze`, потому что остаётся в сборке.
- [При возврате функции у старых пользователей chain не включится сам] → это цель: сохранённый выбор сбрасывается при запуске, а `enable-warp` из старых `populatedHeaders` снова начнёт работать только при включённом флаге. При возврате нужно явно решить, что делать с `enable-warp` у существующих профилей.
- [Поиск `"type": "warp"` в JSON может задеть конфиг, где слово встречается в другом поле] → функция проверяет только значения ключа `type` у outbound и endpoint после разбора JSON, а в текстовых подписках — только схему строки.
- [Для тестов нужен экземпляр `SingboxConfigOption` со множеством обязательных полей] → фикстура через `SingboxConfigOption.fromJson` из JSON-файла в `test/fixtures/`, либо фабрика в тестовых утилитах.
