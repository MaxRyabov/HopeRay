## ADDED Requirements

### Requirement: Минимальный набор возможностей Network Extension
iOS-приложение и его расширение MUST запрашивать из возможностей Network Extension только `packet-tunnel-provider`.

#### Scenario: Entitlements основного приложения
- **WHEN** проверяется `ios/Runner/Runner.entitlements`
- **THEN** `com.apple.developer.networking.networkextension` содержит только `packet-tunnel-provider`, а ключа `aps-environment` нет

#### Scenario: Entitlements расширения
- **WHEN** проверяется `ios/HiddifyPacketTunnel/HiddifyPacketTunnel.entitlements`
- **THEN** `com.apple.developer.networking.networkextension` содержит только `packet-tunnel-provider`

#### Scenario: Туннель работает
- **WHEN** приложение из TestFlight подключается с действующим ключом
- **THEN** VPN-туннель поднимается, трафик идёт через сервер ключа

### Requirement: Нет лишних ключей в Info.plist
`ios/Runner/Info.plist` MUST NOT содержать ключей, относящихся к расширениям, которых у приложения нет.

#### Scenario: Ключ App Intents
- **WHEN** проверяется `ios/Runner/Info.plist`
- **THEN** ключа `EXAppExtensionAttributes` нет

### Requirement: Декларация «Data Not Collected»
Privacy manifest основного приложения MUST декларировать отсутствие сбора данных и трекинга. Это соответствует решению не передавать Sentry DSN в iOS-сборку (`disable-telemetry-by-default`).

#### Scenario: Содержимое privacy manifest
- **WHEN** проверяется `ios/Runner/PrivacyInfo.xcprivacy`
- **THEN** есть `NSPrivacyTracking = false`, пустой `NSPrivacyTrackingDomains` и пустой `NSPrivacyCollectedDataTypes`
- **AND** существующие `NSPrivacyAccessedAPITypes` сохранены

#### Scenario: Сводный отчёт о приватности
- **WHEN** для архива iOS-сборки формируется сводный privacy report (Xcode Organizer → Generate Privacy Report)
- **THEN** в отчёте нет собираемых типов данных, в том числе от подключённых SDK (Sentry)
