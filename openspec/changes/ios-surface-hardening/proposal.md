## Why

Ключ попадает в приложение только копированием или через QR, и бот с приложением технически не связан. При этом приложение регистрирует восемь URL-схем, в том числе `hiddify`, `v2ray`, `clash`, `sing-box`, по которым любая веб-страница или бот может инициировать импорт. Кроме того, iOS-сборка запрашивает лишние возможности: Network Extension типа app-proxy, dns-proxy и content-filter, а также push. Нет и декларации собираемых данных. Всё это увеличивает поверхность для App Review и расходится с описанием продукта.

## What Changes

- **BREAKING:** удаляется обработка URL-схем на всех платформах. Импорт по ссылке `hoperay://…` и другим схемам больше не работает, ключ добавляется из буфера обмена, QR-кодом или вручную.
  - iOS и macOS: удалить `CFBundleURLTypes`; на iOS также `FlutterDeepLinkingEnabled`.
  - Android: удалить `intent-filter` со схемами.
  - Linux: удалить `x-scheme-handler/*` из AppStream и AppImage.
  - Windows: не регистрировать обработчики и при запуске снимать ранее зарегистрированные.
  - Удалить подписку на `app_links` и ветки deep link в redirect роутера.
- iOS entitlements: у основного приложения и расширения остаётся только `packet-tunnel-provider`. Из основного приложения удаляется `aps-environment`, у приложения нет push. Из `Runner/Info.plist` удаляется `EXAppExtensionAttributes`.
- iOS privacy manifest: объявляются собираемые данные. Отчёты о сбоях (Crash Data, Performance Data) собираются только при включённой пользователем аналитике, не привязаны к личности и не используются для трекинга.
- `REBRAND.md`: исправляется bundle id iOS (`app.hoperay.com`).

## Capabilities

### New Capabilities
- `deep-links`: приложение не принимает команды импорта через URL-схемы.
- `ios-app-surface`: какие возможности iOS запрашивает приложение и какие данные декларирует.

### Modified Capabilities

## Impact

- `ios/Runner/Info.plist`, `ios/Runner/Runner.entitlements`, `ios/HiddifyPacketTunnel/HiddifyPacketTunnel.entitlements`, `ios/Runner/PrivacyInfo.xcprivacy`
- `macos/Runner/Info.plist`
- `android/app/src/main/AndroidManifest.xml`
- `linux/packaging/app.hoperay.com.appdata.xml`, `linux/packaging/appimage/make_config.yaml`
- `lib/core/router/deep_linking/my_app_links.dart`, `lib/core/router/go_router/refresh_listenable.dart`, `lib/core/router/go_router/routing_config_notifier.dart`
- Provisioning profiles в секретах CI содержат больше возможностей, чем нужно. Приложение может запрашивать их подмножество, перевыпуск не требуется. Проверяется сборкой TestFlight.
- `ITSAppUsesNonExemptEncryption` не меняется: решение по экспортному контролю принимается на этапе 0 плана.
