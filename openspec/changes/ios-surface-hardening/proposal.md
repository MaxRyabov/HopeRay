## Why

Ключ попадает в приложение только копированием или через QR, и бот с приложением технически не связан. При этом приложение регистрирует восемь URL-схем, в том числе `hiddify`, `v2ray`, `clash`, `sing-box`, по которым любая веб-страница или бот может инициировать импорт. Кроме того, iOS-сборка запрашивает лишние возможности: Network Extension типа app-proxy, dns-proxy и content-filter, а также push. Нет и декларации собираемых данных. Всё это увеличивает поверхность для App Review и расходится с описанием продукта.

## What Changes

- **BREAKING:** удаляется обработка URL-схем на всех платформах. Импорт по ссылке `hoperay://…` и другим схемам больше не работает, ключ добавляется из буфера обмена, QR-кодом или вручную.
  - iOS и macOS: удалить `CFBundleURLTypes`; на iOS также `FlutterDeepLinkingEnabled`.
  - Android: удалить `intent-filter` со схемами.
  - Linux: удалить `x-scheme-handler/*` из AppStream, deb и AppImage.
  - Windows: удалить `protocol_activation` из MSIX, не регистрировать обработчики и при запуске снимать ранее зарегистрированные, но только свои (команда указывает на exe HopeRay). Регистрации других клиентов не трогаются.
  - Удалить подписку Dart на `app_links` и ветки deep link в redirect роутера. Нативная часть `app_links` на Windows остаётся, на ней держится активация уже открытого окна.
- iOS entitlements: у основного приложения и расширения остаётся только `packet-tunnel-provider`. Из основного приложения удаляется `aps-environment`, у приложения нет push. Из `Runner/Info.plist` удаляется `EXAppExtensionAttributes`.
- Privacy manifest приложения и расширения включаются в Resources своих таргетов: сейчас они есть в проекте, но в сборку не копируются.
- iOS privacy manifest: «Data Not Collected» (`NSPrivacyTracking=false`, пустой `NSPrivacyCollectedDataTypes`), потому что Sentry удалён из приложения в `disable-telemetry-by-default`. Итог проверяется сводным privacy report архива.
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
- Порядок слияния: **6-й**, последний.
- `linux/packaging/app.hoperay.com.appdata.xml`, `linux/packaging/appimage/make_config.yaml`, `linux/packaging/deb/make_config.yaml`, `windows/packaging/msix/make_config.yaml`
- `lib/core/router/deep_linking/url_protocol/windows_protocol.dart`, `protocol.dart`, `api.dart` (проверка владельца регистрации)
- `lib/core/router/deep_linking/my_app_links.dart`, `lib/core/router/go_router/refresh_listenable.dart`, `lib/core/router/go_router/routing_config_notifier.dart`
- Provisioning profiles в секретах CI содержат больше возможностей, чем нужно. Приложение может запрашивать их подмножество, перевыпуск не требуется. Проверяется ручной сборкой TestFlight на ветке до MR.
- `ITSAppUsesNonExemptEncryption` не меняется: решение по экспортному контролю принимается на этапе 0 плана.
