## 1. URL-схемы в манифестах

- [ ] 1.1 `ios/Runner/Info.plist`: удалить `CFBundleURLTypes` и `FlutterDeepLinkingEnabled`
- [ ] 1.2 `macos/Runner/Info.plist`: удалить `CFBundleURLTypes`
- [ ] 1.3 `android/app/src/main/AndroidManifest.xml`: удалить `intent-filter` со схемами (VIEW + BROWSABLE)
- [ ] 1.4 `linux/packaging/app.hoperay.com.appdata.xml`: удалить `x-scheme-handler/*` из `mime-types` (и сам блок, если он опустеет)
- [ ] 1.5 `linux/packaging/appimage/make_config.yaml`: удалить `supported_mime_type` со схемами

## 2. Приём ссылок в приложении

- [ ] 2.1 Удалить `myAppLinksProvider` и `newUrlFromAppLink`; `RefreshListenable` слушает только `introCompleted`
- [ ] 2.2 В redirect `routing_config_notifier.dart` удалить распознавание схем, `newUrlFromAppLink` и `?url=`, а также вызовы `showAddProfile(url:, triggeredByDeepLink: true)`
- [ ] 2.3 Windows: при запуске вызывать `unregisterProtocolHandler` для каждой схемы из `LinkParser.protocols`
- [ ] 2.4 Если у `app_links` не осталось использований, удалить пакет из `pubspec.yaml`, `flutter pub get`
- [ ] 2.5 `dart run build_runner build --delete-conflicting-outputs`

## 3. iOS

- [ ] 3.1 `Runner.entitlements`: в networkextension оставить только `packet-tunnel-provider`, удалить `aps-environment`
- [ ] 3.2 `HiddifyPacketTunnel.entitlements`: в networkextension оставить только `packet-tunnel-provider`
- [ ] 3.3 `ios/Runner/Info.plist`: удалить `EXAppExtensionAttributes`
- [ ] 3.4 `ios/Runner/PrivacyInfo.xcprivacy`: добавить `NSPrivacyTracking=false`, пустой `NSPrivacyTrackingDomains`, `NSPrivacyCollectedDataTypes` (CrashData, PerformanceData; Linked=false, Tracking=false, Purpose=AppFunctionality); `NSPrivacyAccessedAPITypes` не менять
- [ ] 3.5 `REBRAND.md`: bundle id iOS `app.hoperay.com`

## 4. Тесты

- [ ] 4.1 Unit: `LinkParser.parse('hiddify://import/https://example.com/sub#Work')` → url `https://example.com/sub`, name `Work`; то же для `hoperay://`
- [ ] 4.2 Тест манифестов: читает `ios/Runner/Info.plist`, `macos/Runner/Info.plist`, `AndroidManifest.xml`, оба файла Linux и проверяет, что в них нет `CFBundleURLSchemes`, `android:scheme=` и `x-scheme-handler`
- [ ] 4.3 Тест entitlements: в обоих `.entitlements` networkextension содержит ровно `packet-tunnel-provider`, в `Runner.entitlements` нет `aps-environment`

## 5. Проверка

- [ ] 5.1 `flutter analyze` без новых замечаний, `flutter test` и все сборки CI зелёные
- [ ] 5.2 После слияния: зелёная push-сборка iOS в `main` и ручной workflow «iOS TestFlight (manual)»
- [ ] 5.3 На iPhone из TestFlight: подключение с действующим ключом работает; `hoperay://` из Safari не открывает приложение
- [ ] 5.4 На Android: ссылка `hiddify://…` из браузера не открывает приложение
