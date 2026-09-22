## Why

Функция chain (Extra security через Cloudflare WARP, Unblocker через Psiphon) даёт выход в интернет без выданного ключа. Кроме того, она регистрирует аккаунт у стороннего VPN-провайдера и описывается в интерфейсе как «обход блокировок». Это противоречит позиционированию «без действующего ключа сервис не работает». По решению руководства функция скрывается: код остаётся, чтобы её можно было вернуть.

## What Changes

- Из интерфейса убираются все входы в chain: пункт «Chain» в настройках, блок `ChainQuickSettings` в быстрых настройках. Маршрут `chainOptions` снимается с регистрации.
- В опции ядра всегда уходит `chainStatus = off`, независимо от сохранённой настройки и от заголовков подписки. У установок, где chain был включён, он перестаёт работать сразу после обновления.
- Заголовок подписки `enable-warp` и флаг `UserOverride.enableWarp` игнорируются, а ключи `chain-status` и `extra-security` удаляются из результата `ProfileParser.profileOverride`, пока функция выключена. Сами списки `allowedOverrideConfigs` и `allowedProfileHeaders` не меняются, чтобы функцию можно было вернуть одним флагом.
- При запуске, если сохранено `chain-status` не `off`, настройка сбрасывается в `off`, а ядро получает актуальные опции. Так туннель, который Android поднимает без UI (плитка быстрых настроек, запуск после обновления), не стартует с WARP или Psiphon.
- Профили, которые сами по себе являются WARP (строки `warp://…`, конфиги с outbound/endpoint типа `warp`), не добавляются и не подключаются. Это второй путь выхода в интернет без выданного ключа.
- Диалог согласия с лицензией Cloudflare WARP показывается только когда chain включён и режим — WARP. Сейчас он может появиться при обычном подключении: `extraSecurityMode` по умолчанию `warp`, а статус chain не проверяется.
- Исправляется ошибка: `unblocker.mode` берётся из `unblockerMode`, а не из `extraSecurityMode`. Это важно на случай, если функцию вернут.

## Capabilities

### New Capabilities
- `chain-features`: доступность цепочек Extra security / Unblocker (WARP, Psiphon) и связанных диалогов.

### Modified Capabilities

## Impact

- Порядок слияния: **3-й**, после `key-only-onboarding`.
- `lib/features/settings/data/config_option_repository.dart` (сборка `SingboxConfigOption`, `fullOptionsOverrided`)
- `lib/features/connection/data/connection_repository.dart` (условие диалога WARP)
- `lib/features/profile/data/profile_parser.dart` (`profileOverride`, новая проверка содержимого на WARP)
- `lib/features/profile/data/profile_repository.dart` (`validateConfig`)
- `lib/bootstrap.dart` (сброс сохранённого `chain-status`)
- `lib/features/settings/overview/settings_page.dart`, `lib/core/router/bottom_sheets/widgets/quick_settings_modal.dart`, `lib/core/router/go_router/routing_config_notifier.dart`
- Код `lib/features/chain/` и `chain_options_page.dart` остаётся, но становится недостижимым.
