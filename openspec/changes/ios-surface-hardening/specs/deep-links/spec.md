## ADDED Requirements

### Requirement: Нет регистрации URL-схем
Приложение MUST NOT регистрироваться в ОС как обработчик URL-схем, ни на одной платформе.

#### Scenario: Проверка манифестов
- **WHEN** проверяются `ios/Runner/Info.plist`, `macos/Runner/Info.plist`, `android/app/src/main/AndroidManifest.xml`, `linux/packaging/app.hoperay.com.appdata.xml`, `linux/packaging/appimage/make_config.yaml`
- **THEN** в них нет `CFBundleURLSchemes`, `intent-filter` с `android:scheme` для `hoperay`, `hiddify`, `v2ray`, `v2rayn`, `v2rayng`, `clash`, `clashmeta`, `sing-box` и нет `x-scheme-handler/*`

#### Scenario: Windows после обновления
- **WHEN** на Windows запускается новая версия, а в реестре остались обработчики схем от предыдущей версии
- **THEN** приложение снимает регистрацию этих схем и не регистрирует их заново

### Requirement: Ссылка не запускает импорт
Приложение MUST NOT начинать добавление профиля по входящей ссылке или маршруту с параметром `url`.

#### Scenario: Открытие ссылки со схемой
- **WHEN** пользователь открывает ссылку `hoperay://import/https://example.com/sub` в браузере или мессенджере
- **THEN** ОС не открывает HopeRay, и окно добавления профиля не появляется

#### Scenario: Маршрут с параметром url
- **WHEN** роутер получает местоположение с параметром `?url=https://example.com/sub`
- **THEN** окно добавления профиля не открывается автоматически

### Requirement: Импорт из буфера обмена поддерживает ссылки со схемами
Разбор текста при добавлении ключа из буфера обмена или вручную MUST по-прежнему распознавать ссылки подписок, в том числе в форме `hoperay://…` и `hiddify://…`, если пользователь вставил их сам.

#### Scenario: Вставка ссылки hiddify
- **WHEN** пользователь копирует `hiddify://import/https://example.com/sub#Work` и выбирает «Буфер обмена»
- **THEN** профиль добавляется с URL `https://example.com/sub` и именем `Work`
