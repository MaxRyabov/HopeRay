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
- **Выключение в `ConfigOptionRepository`, а не в провайдере.** `fullOptions()` и `fullOptionsOverrided()` после наложения переопределений делают `copyWith(chainStatus: ChainStatus.off)`, если флаг выключен. Это последняя точка перед ядром, её обходят и настройки, и переопределения. К тому же репозиторий тестируется без Riverpod: достаточно передать `getConfigOptions`.
- **`profileOverride` не порождает ключи chain при выключенном флаге.** `enable-warp` и `UserOverride.enableWarp` игнорируются, а `chain-status` и `extra-security` удаляются из результата. Вместе с предыдущим пунктом это двойная защита, и каждую часть можно проверить unit-тестом.
- **Условие диалога WARP — чистая функция** `bool requiresWarpConsent(SingboxConfigOption o)`:
  - `chainStatus == extraSecurity && extraSecurity.mode.isWarp()`, или
  - `chainStatus == unblocker && unblocker.mode.isWarp()`.

  Используется в `applyConfigOption`. Функция чистая, поэтому тестируется без UI.
- **Маршрут `chainOptions` регистрируется только при включённом флаге.** Если маршрута нет, go_router на `/settings/chain-options` показывает страницу ошибки, а не экран chain. Существующий redirect для `chain-options` удаляется вместе с маршрутом.
- **Исправить `unblocker.mode`** на `ref.watch(unblockerMode)`.

## Risks / Trade-offs

- [Пользователи, у которых работал только WARP без ключа, теряют доступ] → это требование продукта.
- [Недостижимый код устаревает и перестаёт компилироваться при рефакторинге] → он продолжает компилироваться и проходит `flutter analyze`, потому что остаётся в сборке.
- [Для тестов нужен экземпляр `SingboxConfigOption` со множеством обязательных полей] → фикстура через `SingboxConfigOption.fromJson` из JSON-файла в `test/fixtures/`, либо фабрика в тестовых утилитах.
