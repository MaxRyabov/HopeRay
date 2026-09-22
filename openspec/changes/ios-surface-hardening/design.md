## Context

Как сейчас работает deep link:
- Схемы из `LinkParser.protocols` объявлены в манифестах iOS, macOS, Android и Linux. На Windows их при запуске регистрирует `myAppLinksProvider` (`registerProtocolHandler`).
- `RefreshListenable` слушает `myAppLinksProvider` и кладёт ссылку в `newUrlFromAppLink`.
- Redirect в `routing_config_notifier.dart` распознаёт схему, `newUrlFromAppLink` или `?url=` и открывает `showAddProfile(url:, triggeredByDeepLink: true)`, в том числе через `/intro?url=`.

`LinkParser.parse` используется и при добавлении из буфера обмена (`profile_notifier.dart`), поэтому сам парсер остаётся.

Как сейчас устроен iOS:
- Основное приложение запрашивает NE `app-proxy-provider`, `dns-proxy`, `packet-tunnel-provider` и `aps-environment=development`.
- Расширение дополнительно запрашивает `content-filter-provider`.
- Код использует только `NEPacketTunnelProvider` (`ExtensionProvider.swift`). Push не используется: вызов `UNUserNotificationCenter` закомментирован.
- Privacy manifest перечисляет только required-reason API.

## Goals / Non-Goals

**Goals:**
- Внешний источник не может вызвать импорт профиля.
- iOS запрашивает только то, что использует, и честно декларирует данные.

**Non-Goals:**
- `ITSAppUsesNonExemptEncryption`: решает ответственный за Apple-аккаунт на этапе 0.
- Переименование расширения `HiddifyPacketTunnel` и `SERVICE_IDENTIFIER=com.hiddify.app`: внутренние идентификаторы, см. `REBRAND.md`.
- Удаление пакета `app_links` из зависимостей. Решается по факту: если после правок у него нет использований, он удаляется в этом же change, и сборка проверяется в CI.
- Удаление `ProfileParser`/`LinkParser` и параметра `triggeredByDeepLink` у `showAddProfile`. Параметр становится невостребованным; если анализатор не жалуется, он остаётся, чтобы не трогать чужие вызовы.

## Decisions

- **Убрать схемы полностью, включая `hoperay`.** Ключ по решению продукта доставляется копированием или QR. Любая оставленная схема — это техническая связь бота с приложением и вектор для навязанного импорта.
- **Удалить ветки deep link в redirect, а не только регистрацию схем.** Если ОС когда-нибудь всё же доставит ссылку (старая регистрация на Windows, ручной запуск с аргументом), импорт не начнётся. Redirect оставляет логику интро и chain.
- **Windows: снимать старую регистрацию.** `unregisterProtocolHandler` для каждой схемы из `LinkParser.protocols` при запуске. Вызов идемпотентен, повторный запуск ничего не ломает. Где разместить вызов (bootstrap или провайдер вместо `myAppLinksProvider`) — решается при реализации, главное, чтобы он выполнялся только на Windows.
- **Privacy manifest декларирует Crash Data и Performance Data.** Их собирает Sentry, и только если пользователь сам включил аналитику (`disable-telemetry-by-default`). Apple требует декларировать и опциональный сбор. Альтернатива — не декларировать, раз по умолчанию сбор выключен. Отклонено: это расхождение с фактом и риск отказа на ревью.
- **Entitlements сокращаются до `packet-tunnel-provider`.** Provisioning profile может разрешать больше возможностей, чем запрашивает приложение, поэтому перевыпуск профилей в секретах CI не требуется. Это проверяется подписанной сборкой.

## Risks / Trade-offs

- [Пользователи и старые инструкции с кнопками `hoperay://` перестают работать] → бот отдаёт строку подписки и QR, как решено в плане.
- [Удаление entitlement ломает подписанную сборку, если профиль в секретах несовместим] → проверить ручным workflow iOS TestFlight до слияния, установить сборку и подключиться.
- [`app_links` может понадобиться другим плагинам] → удаление пакета только если нет использований и CI зелёный на всех платформах.

## Migration Plan

1. Слить изменения. Push-сборка в `main` проверяет подписанный путь.
2. Запустить ручной workflow «iOS TestFlight (manual)», установить сборку из TestFlight, подключиться с действующим ключом.
3. Откат: revert коммита. Прежние entitlements остаются совместимыми с теми же профилями.
