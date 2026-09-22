## 1. URL-схемы в манифестах и пакетах

- [ ] 1.1 `ios/Runner/Info.plist`: удалить `CFBundleURLTypes` и `FlutterDeepLinkingEnabled`
- [ ] 1.2 `macos/Runner/Info.plist`: удалить `CFBundleURLTypes`
- [ ] 1.3 `android/app/src/main/AndroidManifest.xml`: удалить `intent-filter` со схемами (VIEW + BROWSABLE) и мета-тег `flutter_deeplinking_enabled`
- [ ] 1.4 `linux/packaging/app.hoperay.com.appdata.xml`: удалить `x-scheme-handler/*` из `mime-types` (и сам блок, если он опустеет)
- [ ] 1.5 `linux/packaging/appimage/make_config.yaml` и `linux/packaging/deb/make_config.yaml`: удалить `x-scheme-handler/*` из `supported_mime_type`
- [ ] 1.6 `windows/packaging/msix/make_config.yaml`: удалить `protocol_activation`

## 2. Приём ссылок в приложении

- [ ] 2.1 Удалить `myAppLinksProvider` и `newUrlFromAppLink`; `RefreshListenable` слушает только `introCompleted`
- [ ] 2.2 В redirect `routing_config_notifier.dart` удалить распознавание схем, `newUrlFromAppLink` и `?url=`, а также вызовы `showAddProfile(url:, triggeredByDeepLink: true)`. Ветку `chain-options` не трогать
- [ ] 2.3 `WindowsProtocolHandler.unregisterIfOwned(scheme)`: прочитать `HKCU\Software\Classes\<scheme>\shell\open\command` (`RegGetValue`), удалить ключ, только если команда содержит `Platform.resolvedExecutable` (без учёта регистра)
- [ ] 2.4 При запуске на Windows вызывать `unregisterIfOwned` для каждой схемы из `LinkParser.protocols`; `register` больше нигде не вызывается
- [ ] 2.5 `app_links` и `windows/runner/main.cpp` не менять
- [ ] 2.6 `dart run build_runner build --delete-conflicting-outputs`

## 3. iOS

- [ ] 3.1 `Runner.entitlements`: в networkextension оставить только `packet-tunnel-provider`, удалить `aps-environment`
- [ ] 3.2 `HiddifyPacketTunnel.entitlements`: в networkextension оставить только `packet-tunnel-provider`
- [ ] 3.3 `ios/Runner/Info.plist`: удалить `EXAppExtensionAttributes`
- [ ] 3.4 `ios/Runner/PrivacyInfo.xcprivacy` и `ios/HiddifyPacketTunnel/PrivacyInfo.xcprivacy`: добавить `NSPrivacyTracking=false`, пустые `NSPrivacyTrackingDomains` и `NSPrivacyCollectedDataTypes`; `NSPrivacyAccessedAPITypes` не менять
- [ ] 3.5 `REBRAND.md`: bundle id iOS `app.hoperay.com`; строку про добавленную схему `hoperay://` заменить на «URL-схемы удалены»

## 4. Тесты

- [ ] 4.1 Unit: `LinkParser.parse('hiddify://import/https://example.com/sub#Work')` → url `https://example.com/sub`, name `Work`; то же для `hoperay://`
- [ ] 4.2 Тест манифестов: читает все файлы из сценария «Проверка манифестов и конфигураций пакетов» и проверяет, что в них нет `CFBundleURLSchemes`, `android:scheme`, `x-scheme-handler` и `protocol_activation`
- [ ] 4.3 Тест entitlements: в обоих `.entitlements` networkextension содержит ровно `packet-tunnel-provider`, в `Runner.entitlements` нет `aps-environment`
- [ ] 4.4 Тест privacy manifest: в обоих файлах `NSPrivacyTracking=false` и пустой `NSPrivacyCollectedDataTypes`; в манифесте приложения 4 записи `NSPrivacyAccessedAPITypes` на месте
- [ ] 4.5 Unit для логики «своя/чужая команда»: вынести сравнение в чистую функцию `isOwnCommand(command, exePath)` и проверить реальный формат, который пишет `register`: путь без кавычек с пробелами и `"%1"` (`C:\Program Files\HopeRay\hoperay.exe "%1"`); путь в кавычках; другой регистр; чужой exe

## 5. Проверка до MR

- [ ] 5.1 CI зелёный: `flutter analyze` (без ошибок), `flutter test` и все сборки
- [ ] 5.2 Ручной workflow «iOS TestFlight (manual)» на ветке: сборка загружена
- [ ] 5.3 На iPhone из TestFlight: подключение с действующим ключом работает; `hoperay://` из Safari не открывает приложение
- [ ] 5.4 Xcode Organizer → Generate Privacy Report для архива: собираемых типов данных нет. Если есть — остановиться и вынести решение
- [ ] 5.5 На Android: ссылка `hiddify://…` из браузера не открывает приложение
- [ ] 5.5a В debug-сборке: `context.go('/home?url=https://example.com/sub')` не открывает окно добавления профиля
- [ ] 5.6 На Windows: до запуска `reg query HKCU\Software\Classes\hiddify` показывает команду HopeRay, `reg query HKCU\Software\Classes\v2ray` — команду другой программы (создать вручную). После запуска новой версии первого ключа нет, второй на месте
- [ ] 5.7 На Windows: повторный запуск выводит открытое окно на передний план, второго окна нет

## 6. После слияния

- [ ] 6.1 Push-сборка в `main` зелёная (контроль)
