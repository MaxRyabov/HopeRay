## Why

Тексты, которые видит пользователь, описывают HopeRay как средство «для интернета без ограничений». Так же его описывают метаданные пакета Linux. Это противоречит позиционированию корпоративного клиента защищённого доступа: такие тексты оценивают App Review и магазины.

## What Changes

- Баннер интро (`intro.banner`) во всех 11 локалях: «All you need for an unrestricted internet» заменяется на «Secure access to your organization's resources» (ru: «Защищённый доступ к ресурсам вашей организации»).
- Метаданные пакетов Linux переписываются нейтрально, без Psiphon и OpenVPN в ключевых словах: AppStream (`linux/packaging/app.hoperay.com.appdata.xml`: summary, description, keywords) и `.desktop`-метаданные deb и AppImage (`linux/packaging/deb/make_config.yaml`, `linux/packaging/appimage/make_config.yaml`: keywords).
- `pubspec.yaml` `description` меняется на нейтральное описание. Строка `flutter:` не трогается.
- Проверка словаря: в текстах, которые видит пользователь, нет слов про обход, разблокировку, свободный интернет и бесплатные серверы.

## Capabilities

### New Capabilities
- `app-positioning`: словарь пользовательских текстов и метаданных пакетов, соответствующий позиционированию корпоративного клиента защищённого доступа.

### Modified Capabilities

## Impact

- Порядок слияния: **5-й**, после `disable-telemetry-by-default`. Тест словаря в en и ru проходит только после `key-only-onboarding`: до него в файлах есть `common.free`, `freeSubNotFound*` и «for free».
- `linux/packaging/deb/make_config.yaml`, `linux/packaging/appimage/make_config.yaml` (keywords). Схемы `x-scheme-handler` в этих же файлах убирает `ios-surface-hardening`.

- `assets/translations/*.i18n.json` → `dart run slang`
- `linux/packaging/app.hoperay.com.appdata.xml`
- `pubspec.yaml` (только `description`)
- Зависит от `key-only-onboarding` (текст «нет профиля») и `hide-chain-features` (скрытые экраны chain, их строки остаются в файлах, но не показываются).
