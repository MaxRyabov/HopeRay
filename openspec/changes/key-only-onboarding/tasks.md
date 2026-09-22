## 1. Бесплатные профили

- [ ] 1.1 Удалить `lib/features/profile/add/widgets/free_btns.dart`, `lib/features/profile/add/widgets/free_btn.dart` и `lib/features/profile/add/model/free_profiles_model.dart`
- [ ] 1.2 Удалить `FreeSwitchNotifier`, `FreeProfilesNotifier`, `freeProfilesFilteredByRegion` из `profile_notifier.dart`
- [ ] 1.3 Удалить `lib/core/router/dialog/widgets/free_profile_consent_dialog.dart` и `DialogNotifier.showFreeProfileConsent`
- [ ] 1.4 Перегенерировать код: `dart run build_runner build --delete-conflicting-outputs`

## 2. Окно добавления профиля

- [ ] 2.1 Удалить `lib/features/profile/add/widgets/nav_bar.dart` и его экспорт из `lib/features/profile/add/widgets/widgets.dart`
- [ ] 2.2 В `AddProfileOptions` убрать `freeSwitch`, `FreeBtns`, `NavBar`; пересчитать высоту листа без `navBarHeight`
- [ ] 2.3 Удалить `navBarGap`, `navBarBottomGap`, `navBarcontentHeight`, `navBarHeight` из `AddProfileModalConst`
- [ ] 2.4 Удалить `ref.listen(freeSwitchNotifierProvider, ...)` в `AddProfileModal`

## 3. Диалог «нет профиля»

- [ ] 3.1 В `NoActiveProfileDialog` убрать кнопку `helpBtn`, оставить «OK»
- [ ] 3.2 Изменить `dialogs.noActiveProfile.title` и `.msg` в en и ru (текст из design.md), для остальных локалей — перевод того же смысла; удалить `dialogs.noActiveProfile.helpBtn` во всех локалях
- [ ] 3.3 В `connection_button.dart` после `showNoActiveProfile()` и `showAddProfile()` добавить `return`: без профиля подключение не запускается
- [ ] 3.4 Удалить `lib/features/home/widget/empty_profiles_home_body.dart` и закомментированный вызов в `home_page.dart`

## 4. Строки перевода

- [ ] 4.1 Удалить `common.free`, `pages.profiles.freeSubNotFound`, `pages.profiles.freeSubNotFoundForRegion`; удалить `common.help`, если после правок у него нет использований
- [ ] 4.2 `dart run slang`

## 5. Тесты

- [ ] 5.1 Widget-тест (через `test/helpers/pump_app.dart`) `AddProfileOptions`: нет `Switch` и текста `t.common.free`, нет чипа «Help»; есть кнопки буфера обмена и ручного ввода
- [ ] 5.2 Widget-тест `NoActiveProfileDialog`: одна кнопка «OK», в тексте нет `hiddify.com` и `free`
- [ ] 5.3 Widget-тест на ширине 360 px: кнопки `FixBtns` видны целиком (без overflow)
- [ ] 5.4 Вручную: без профилей нажать кнопку подключения → диалог «Добавьте ключ доступа» → «OK» → открыто окно добавления, других диалогов нет, статус подключения не меняется

## 6. Проверка

- [ ] 6.1 CI зелёный: шаг `flutter analyze` (без ошибок) и `flutter test`
- [ ] 6.2 Grep по `lib/` и `assets/translations/`: нет `free_configs`, `hiddify.com/manager`, `freeSwitch`, `FreeProfile`
