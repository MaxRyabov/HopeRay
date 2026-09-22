## Why

По позиционированию приложение работает только с заранее выданным ключом доступа. Внутри него нельзя получить ключ или сервер. Сейчас есть два способа сделать это из приложения:
- переключатель «Free» в окне добавления профиля — загружает список бесплатных конфигов из репозитория Hiddify на GitHub;
- кнопка «Show me how» в диалоге «Choose a profile» — ведёт на `hiddify.com/manager/` с инструкцией, как поднять свой сервер.

## What Changes

- Удаляется переключатель «Free» и список бесплатных профилей: `FreeBtns`, `FreeSwitchNotifier`, `FreeProfilesNotifier`, `freeProfilesFilteredByRegion`, модель `FreeProfile` и загрузка `free_configs` с GitHub.
- Удаляется чип «Help» в окне добавления профиля.
- Диалог при подключении без профиля (`NoActiveProfileDialog`) больше не ссылается на внешний сайт. Текст объясняет, что нужно добавить выданный ключ доступа, а кнопка «Добавить ключ» открывает окно добавления профиля.
- Способы добавления остаются прежними: QR-код (мобильные), буфер обмена, ручной ввод.
- Удаляются ставшие ненужными строки перевода (`common.free`, `pages.profiles.freeSubNotFound*`, `dialogs.noActiveProfile.helpBtn`, `common.help`, если он больше нигде не используется) и неиспользуемый `EmptyProfilesHomeBody`.

## Capabilities

### New Capabilities
- `profile-onboarding`: как пользователь без профиля получает доступ к работе. Только импорт выданного ключа, без встроенных источников ключей и внешних инструкций.

### Modified Capabilities

## Impact

- `lib/features/profile/add/add_profile_modal.dart`, `lib/features/profile/add/widgets/nav_bar.dart`, `lib/features/profile/add/widgets/free_btns.dart`
- `lib/features/profile/notifier/profile_notifier.dart` и модель `FreeProfile` → перегенерация riverpod (`build_runner`)
- `lib/core/router/dialog/widgets/no_active_profile_dialog.dart`, `lib/core/model/constants.dart` (`AddProfileModalConst`)
- `lib/features/home/widget/empty_profiles_home_body.dart` (не используется)
- `assets/translations/*.i18n.json` → `dart run slang`
- Сетевой запрос к `raw.githubusercontent.com/hiddify/hiddify-app/.../free_configs` исчезает.
