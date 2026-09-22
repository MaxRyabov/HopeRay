## ADDED Requirements

### Requirement: Нет регистрации URL-схем
Приложение и его пакеты MUST NOT регистрироваться в ОС как обработчик URL-схем, ни на одной платформе.

#### Scenario: Проверка манифестов и конфигураций пакетов
- **WHEN** проверяются `ios/Runner/Info.plist`, `macos/Runner/Info.plist`, `android/app/src/main/AndroidManifest.xml`, `linux/packaging/app.hoperay.com.appdata.xml`, `linux/packaging/appimage/make_config.yaml`, `linux/packaging/deb/make_config.yaml`, `windows/packaging/msix/make_config.yaml`
- **THEN** в них нет `CFBundleURLSchemes`, `android:scheme`, `x-scheme-handler/*` и `protocol_activation`

#### Scenario: Windows не регистрирует схемы при запуске
- **WHEN** приложение запускается на Windows
- **THEN** оно не создаёт ключей `HKCU\Software\Classes\<scheme>` ни для одной схемы

### Requirement: Снятие только своих старых регистраций на Windows
На Windows при запуске приложение MUST удалять регистрацию схем из `LinkParser.protocols`, только если команда `shell\open\command` этой регистрации указывает на исполняемый файл HopeRay. Регистрации, принадлежащие другим программам, MUST NOT изменяться.

#### Scenario: Старая регистрация HopeRay
- **WHEN** в `HKCU\Software\Classes\hiddify\shell\open\command` записан путь к исполняемому файлу HopeRay, и запускается новая версия
- **THEN** ключ `HKCU\Software\Classes\hiddify` удаляется

#### Scenario: Регистрация другого клиента
- **WHEN** в `HKCU\Software\Classes\v2ray\shell\open\command` записан путь к исполняемому файлу другой программы, и запускается HopeRay
- **THEN** ключ `HKCU\Software\Classes\v2ray` остаётся без изменений

### Requirement: Ссылка не запускает импорт
Приложение MUST NOT начинать добавление профиля по входящей ссылке или маршруту с параметром `url`.

#### Scenario: Открытие ссылки со схемой
- **WHEN** пользователь открывает ссылку `hoperay://import/https://example.com/sub` в браузере или мессенджере
- **THEN** ОС не открывает HopeRay, и окно добавления профиля не появляется

#### Scenario: Маршрут с параметром url
- **WHEN** роутер получает местоположение с параметром `?url=https://example.com/sub`
- **THEN** окно добавления профиля не открывается автоматически

### Requirement: Буфер обмена и QR по-прежнему понимают ссылки со схемами
Разбор текста при добавлении ключа из буфера обмена или QR-кода MUST по-прежнему распознавать ссылки подписок в форме `hoperay://…` и `hiddify://…`, если пользователь сам их скопировал или отсканировал.

#### Scenario: Вставка ссылки hiddify
- **WHEN** пользователь копирует `hiddify://import/https://example.com/sub#Work` и выбирает «Буфер обмена»
- **THEN** профиль добавляется с URL `https://example.com/sub` и именем `Work`

### Requirement: Один экземпляр приложения на Windows
Повторный запуск приложения на Windows MUST активировать уже открытое окно, а не открывать второе.

#### Scenario: Второй запуск
- **WHEN** HopeRay уже запущен, и пользователь запускает его ещё раз
- **THEN** второе окно не появляется, открытое окно выходит на передний план
