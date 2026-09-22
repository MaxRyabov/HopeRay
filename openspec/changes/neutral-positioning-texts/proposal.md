## Why

Тексты, которые видит пользователь, описывают HopeRay как средство «для интернета без ограничений». Так же его описывают метаданные пакета Linux. Это противоречит позиционированию корпоративного клиента защищённого доступа: такие тексты оценивают App Review и магазины.

## What Changes

- Баннер интро (`intro.banner`) во всех 11 локалях: «All you need for an unrestricted internet» заменяется на «Secure access to your organization's resources» (ru: «Защищённый доступ к ресурсам вашей организации»).
- Метаданные AppStream (`linux/packaging/app.hoperay.com.appdata.xml`): summary, description и keywords переписываются нейтрально, без Psiphon и OpenVPN в ключевых словах.
- `pubspec.yaml` `description` меняется на нейтральное описание. Строка `flutter:` не трогается.
- Проверка словаря: в текстах, которые видит пользователь, нет слов про обход, разблокировку, свободный интернет и бесплатные серверы.

## Capabilities

### New Capabilities
- `app-positioning`: словарь пользовательских текстов и метаданных пакетов, соответствующий позиционированию корпоративного клиента защищённого доступа.

### Modified Capabilities

## Impact

- `assets/translations/*.i18n.json` → `dart run slang`
- `linux/packaging/app.hoperay.com.appdata.xml`
- `pubspec.yaml` (только `description`)
- Зависит от `key-only-onboarding` (текст «нет профиля») и `hide-chain-features` (скрытые экраны chain, их строки остаются в файлах, но не показываются).
