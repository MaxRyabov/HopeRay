## Context

Окно добавления профиля (`AddProfileOptions`) состоит из трёх частей:
- `FixBtns`: QR, буфер обмена, вручную;
- список `FreeBtns` (при включённом `freeSwitch`);
- `NavBar` с переключателем «Free» и чипом «Help».

`FreeBtns` загружает `free_configs` из репозитория Hiddify, показывает `FreeProfileConsentDialog` и добавляет профиль с флагами `enableWarp` / `enableFragment` из `neededFeatures`.

Кнопка подключения без активного профиля вызывает `showNoActiveProfile()`, затем `showAddProfile()` (`connection_button.dart`). Сейчас диалог содержит кнопку «Show me how» → `hiddify.com/manager/`. `EmptyProfilesHomeBody` нигде не используется: его вызов в `home_page.dart` закомментирован.

## Goals / Non-Goals

**Goals:**
- Единственный путь к работе — импорт выданного ключа.
- Никаких сетевых запросов за чужими конфигами.

**Non-Goals:**
- Изменение способов импорта (QR, буфер обмена, вручную) и логики `addClipboard` / `addManual`.
- Deep link импорт: отдельный change `ios-surface-hardening`.
- Формулировки остальных экранов: отдельный change `neutral-positioning-texts`. Здесь меняется только текст диалога «нет профиля».

## Decisions

- **Удалить код бесплатных профилей, а не прятать.** Функциональность противоречит продукту, возвращать её не планируется. Удаляются `FreeBtns`, `FreeSwitchNotifier`, `FreeProfilesNotifier`, `freeProfilesFilteredByRegion`, `free_profiles_model.dart`, `FreeProfileConsentDialog` и метод диалога, который его показывает. Затем перегенерируются `*.g.dart` и `*.freezed.dart`.
- **Удалить `NavBar` целиком.** После удаления «Free» и «Help» в нём ничего не остаётся. Высота листа в `AddProfileOptions` считается без `navBarHeight`; константы `navBar*` из `AddProfileModalConst` удаляются. Лист всегда имеет высоту блока `FixBtns` плюс отступы, ветки `freeSwitch` уходят.
- **Диалог «нет профиля» с одной кнопкой «OK».** Порядок в `lib/features/home/widget/connection_button.dart` уже открывает окно добавления после закрытия диалога. Отдельная кнопка «Добавить ключ» дублировала бы этот переход и открывала бы лист дважды. Текст без перечня способов, чтобы он подходил и десктопу, где нет QR: ru — заголовок «Добавьте ключ доступа», текст «Чтобы подключиться, добавьте ключ доступа, выданный вашей организацией»; en — заголовок «Add an access key», текст «To connect, add the access key issued by your organization».
- **Возврат после показа окна добавления.** В `connection_button.dart` после `showNoActiveProfile()` и `showAddProfile()` сейчас нет `return`, и выполнение продолжается в `showExperimentalFeatureNotice()` и `toggleConnection()`. Добавляется `return`, чтобы без профиля не было попытки подключения и лишних диалогов поверх окна добавления.
- **Удалить `EmptyProfilesHomeBody`.** Это мёртвый код со ссылкой на тот же текст.

## Risks / Trade-offs

- [Пользователи, привыкшие к «Free», теряют функцию] → это требование продукта.
- [Изменение высоты листа может обрезать кнопки на малых экранах] → проверить widget-тестом на ширине 360 px и вручную на телефоне.
