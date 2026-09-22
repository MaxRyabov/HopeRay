## Context

Как сейчас работает deep link:
- Схемы из `LinkParser.protocols` (`hoperay`, `hiddify`, `v2ray`, `v2rayn`, `v2rayng`, `clash`, `clashmeta`, `sing-box`) объявлены:
  - в `ios/Runner/Info.plist` и `macos/Runner/Info.plist`;
  - в `AndroidManifest.xml`;
  - в Linux: AppStream, `deb/make_config.yaml` и `appimage/make_config.yaml`;
  - в MSIX: `windows/packaging/msix/make_config.yaml`, `protocol_activation`.
- На Windows `myAppLinksProvider` при каждом запуске регистрирует схемы в `HKCU\Software\Classes` через `WindowsProtocolHandler.register`.
- `RefreshListenable` слушает `myAppLinksProvider` и кладёт ссылку в `newUrlFromAppLink`.
- Redirect в `routing_config_notifier.dart` распознаёт схему, `newUrlFromAppLink` или `?url=` и открывает `showAddProfile(url:, triggeredByDeepLink: true)`, в том числе через `/intro?url=`.
- `windows/runner/main.cpp` подключает `app_links_plugin_c_api.h`: `SendAppLinkToInstance` находит уже открытое окно, передаёт ему ссылку и выводит его на передний план. На этом держится логика одного экземпляра.
- `WindowsProtocolHandler.unregister` делает `RegDeleteTree` без проверки, кому принадлежит ключ.

`LinkParser.parse` используется при добавлении из буфера обмена и QR (`addClipboard`), поэтому парсер остаётся.

Как сейчас устроен iOS:
- Основное приложение запрашивает NE `app-proxy-provider`, `dns-proxy`, `packet-tunnel-provider` и `aps-environment=development`.
- Расширение дополнительно запрашивает `content-filter-provider`.
- Код использует только `NEPacketTunnelProvider`, push не используется.
- Privacy manifest перечисляет только required-reason API.

## Goals / Non-Goals

**Goals:**
- Внешний источник не может вызвать импорт профиля.
- HopeRay не трогает регистрации схем, принадлежащие другим программам.
- iOS запрашивает только то, что использует, и декларирует «Data Not Collected».

**Non-Goals:**
- `ITSAppUsesNonExemptEncryption`: решает ответственный за Apple-аккаунт на этапе 0.
- Переименование расширения `HiddifyPacketTunnel` и `SERVICE_IDENTIFIER=com.hiddify.app`: внутренние идентификаторы, см. `REBRAND.md`.
- Удаление пакета `app_links`. Его нативная часть на Windows обеспечивает активацию уже открытого окна (`main.cpp`). Пакет остаётся, из Dart отписываемся.
- Удаление `LinkParser` и параметра `triggeredByDeepLink` у `showAddProfile`.
- Порядок: change идёт после `disable-telemetry-by-default`, иначе сводный privacy report не может быть пуст.

## Decisions

- **Убрать схемы полностью, включая `hoperay`.** Ключ по решению продукта доставляется копированием или QR. Любая оставленная схема — это техническая связь бота с приложением и вектор для навязанного импорта.
- **Удалить ветки deep link в redirect**, а не только регистрацию схем. Если ОС всё же доставит ссылку (старая регистрация, запуск с аргументом), импорт не начнётся. Ветку `chain-options` в redirect этот change не трогает: её убирает `hide-chain-features`.
- **Windows: снимать только свои регистрации.** Для каждой схемы из `LinkParser.protocols` читается значение по умолчанию `HKCU\Software\Classes\<scheme>\shell\open\command`. Ключ удаляется, только если команда содержит `Platform.resolvedExecutable` (сравнение путей без учёта регистра). В `WindowsProtocolHandler` добавляется метод `unregisterIfOwned(scheme)` с чтением значения через `RegGetValue`. Существующий `unregister` не используется. Вызов при каждом запуске дешёвый и идемпотентный, одноразовый флаг не нужен.
- **Удаляются `protocol_activation` в MSIX и `x-scheme-handler` в deb.** Иначе пакеты продолжат регистрировать схемы на уровне ОС.
- **`app_links` остаётся**, `myAppLinksProvider` удаляется. `main.cpp` не меняется: `SendAppLinkToInstance` продолжает активировать открытое окно, а ссылку, которую он передаёт, никто не слушает.
- **Удаляется мета-тег `flutter_deeplinking_enabled`** в `AndroidManifest.xml`. Строки `dialogs.confirmation.addProfileByDeepLinkWarning` остаются: их использует `bottom_sheets_notifier.dart` при `triggeredByDeepLink`, а удаление параметра — non-goal.
- **Privacy manifest: пустой `NSPrivacyCollectedDataTypes` у приложения и расширения.** Sentry удалён из приложения в `disable-telemetry-by-default`: его SDK объявлял Crash/Performance/Other Diagnostic Data. Итог проверяется сводным privacy report архива. Если отчёт покажет типы данных от другого SDK, это останавливает MR до решения.
- **Privacy manifest включается в Resources.** Сейчас оба `PrivacyInfo.xcprivacy` есть в `project.pbxproj` как ссылки на файлы, но не входят в `PBXResourcesBuildPhase` ни одного таргета (у расширения фаза пустая), то есть в бандл не копируются. Без этой правки декларация и required-reason API не попадают в сборку, возможен отказ ITMS-91053. Правка делается в pbxproj вручную (`PBXBuildFile` + запись в фазу Resources для каждого таргета) и проверяется содержимым `.ipa`.
- **Entitlements сокращаются до `packet-tunnel-provider`.** Provisioning profile может разрешать больше, чем запрашивает приложение, поэтому перевыпуск профилей в секретах CI не ожидается. Это проверяется подписанной сборкой **до слияния**.

## Risks / Trade-offs

- [Старые инструкции с кнопками `hoperay://` перестают работать] → бот отдаёт строку подписки и QR, как решено в плане.
- [Удаление entitlement ломает подписанную сборку, если профиль в секретах несовместим] → ручной workflow «iOS TestFlight (manual)» запускается на ветке до MR. Только после установки сборки и подключения открывается MR.
- [Другой pod объявляет данные в своём privacy manifest] → проверка сводным отчётом, см. Decisions.
- [Сравнение путей на Windows не сработает для старой регистрации из другого каталога установки] → такая регистрация остаётся и указывает на уже несуществующий exe. Импорта она не вызывает, потому что ветки deep link удалены.

## Migration Plan

1. На ветке до MR: CI зелёный, ручной workflow «iOS TestFlight (manual)» на ветке, установка из TestFlight, подключение с действующим ключом.
2. Слить. Push-сборка в `main` — контрольная.
3. Откат: revert коммита. Прежние entitlements совместимы с теми же профилями.
