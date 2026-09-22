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

### Requirement: Декларация собираемых данных
Privacy manifest основного приложения MUST перечислять данные, которые приложение может собирать. Каждый тип MUST быть помечен как не привязанный к личности и не используемый для трекинга. Для всех типов MUST быть указано `NSPrivacyTracking = false`.

#### Scenario: Содержимое privacy manifest
- **WHEN** проверяется `ios/Runner/PrivacyInfo.xcprivacy`
- **THEN** есть `NSPrivacyTracking = false`, пустой `NSPrivacyTrackingDomains` и `NSPrivacyCollectedDataTypes` с `NSPrivacyCollectedDataTypeCrashData` и `NSPrivacyCollectedDataTypePerformanceData`, у каждого `Linked = false`, `Tracking = false`, цель `NSPrivacyCollectedDataTypePurposeAppFunctionality`
- **AND** существующие `NSPrivacyAccessedAPITypes` сохранены
