## 1. Баннер интро

- [ ] 1.1 `intro.banner` в `en.i18n.json`: «Secure access to your organization's resources»
- [ ] 1.2 `intro.banner` в `ru.i18n.json`: «Защищённый доступ к ресурсам вашей организации»
- [ ] 1.3 `intro.banner` в ar, es, fa, fr, id, pt-BR, tr, zh-CN, zh-TW: перевод того же смысла
- [ ] 1.4 `dart run slang`

## 2. Метаданные

- [ ] 2.1 `linux/packaging/app.hoperay.com.appdata.xml`: summary «Secure access client», description про защищённый доступ к ресурсам организации по выданному ключу, удалить keywords `Psiphon` и `OpenVPN`
- [ ] 2.1a `linux/packaging/deb/make_config.yaml` и `linux/packaging/appimage/make_config.yaml`: удалить keywords `Psiphon` и `OpenVPN`
- [ ] 2.2 `pubspec.yaml`: `description: HopeRay secure access client.`, строку `flutter:` не менять

## 3. Тест словаря

- [ ] 3.1 Добавить `test/core/localization/positioning_vocabulary_test.dart`: обход всех строк en и ru, кроме ключей с префиксами `pages.settings.chain.`, `dialogs.warpLicense.`, `errors.warp.`; проверка отсутствия подстрок из спеки
- [ ] 3.2 Если тест находит легитимные совпадения, либо поправить текст, либо добавить ключ в исключения с комментарием, почему он допустим

## 4. Проверка

- [ ] 4.1 CI зелёный: шаг `flutter analyze` (без ошибок) и `flutter test`
- [ ] 4.2 Вручную: интро на ru и en показывает новый баннер
- [ ] 4.3 Баннер в 9 остальных локалях проверить обратным переводом (или носителем): смысл «защищённый доступ к ресурсам организации», без «свободного интернета»
