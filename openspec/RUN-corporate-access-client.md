# RUN: feat/corporate-access-client

Рабочий журнал фичи. Перечитывать перед каждым действием, которое зависит от прошлых решений.

## Ветки

- Общая ветка: `feat/corporate-access-client` (от `main` после слияния PR #2). Каждый этап — подветка от неё, MR в неё. Финальный MR `feat/corporate-access-client` → `main`.
- Репозиторий: `MaxRyabov/HopeRay`, PR создавать с `--repo MaxRyabov/HopeRay`.

## План этапов (подтверждён 2026-09-22)

| # | Этап / подветка | OpenSpec change | Статус | MR |
|---|---|---|---|---|
| 1 | `stage/1-external-contacts` | remove-external-contacts | **слит 2026-09-23**, change заархивирован | #5 |
| 2 | `stage/2-key-only-onboarding` | key-only-onboarding | план | — |
| 3 | `stage/3a-hide-chain` | hide-chain-features (chain: UI, off, WARP-диалог, unblocker.mode, сброс в bootstrap) | план | — |
| 4 | `stage/3b-keyless-profiles` | hide-chain-features (WARP/Psiphon-профили, ошибки, json editor) | план | — |
| 5 | `stage/4-remove-sentry` | disable-telemetry-by-default | план | — |
| 6 | `stage/5-positioning-texts` | neutral-positioning-texts | план | — |
| 7 | `stage/6a-no-deep-links` | ios-surface-hardening (deep-links) | план | — |
| 8 | `stage/6b-ios-surface` | ios-surface-hardening (ios-app-surface) | план | — |

## Текущий этап

Этап 2, `stage/2-key-only-onboarding` (не начат). Этап 1 слит: merge-коммит 21d4738d. Этап 1 закрыт. Следующий — этап 2, `stage/2-key-only-onboarding` (ветвить от `feat/corporate-access-client`).

## Как тестируем

- Каждый этап: unit/widget-тесты и `flutter analyze` локально, CI собирает все 6 платформ на PR.
- UI-проверки: Windows-сборка локально (`flutter run -d windows`).
- Android-специфичное (плитка, per-app, deep link, WARP после обновления) — этапы 3b, 5, 6a: решить к этапу 3b (Android SDK локально или выгрузка APK из CI).
- TestFlight только дважды: этап 8 до MR и приёмка перед финальным MR в `main`; каждый раз поднимать build number.
- Цикл замечаний: раз в 20 минут, не больше 4 кругов.

## Решения

- PR #4 (подписанные сборки) слит в `main` до этапа 1; ветка фичи подтягивает `main`.

- Локальные тесты: `export NO_PROXY=127.0.0.1,localhost no_proxy=127.0.0.1,localhost` — системный HTTP(S)_PROXY=127.0.0.1:12334 ломает websocket тест-раннера.
- `flutter pub get` перегенерирует `windows|linux|macos` регистранты плагинов с другими окончаниями строк (diff пустой после нормализации) — не коммитить.
- Шаг `flutter analyze` в CI: `--no-fatal-infos --no-fatal-warnings`; на 2026-09-22 в проекте 0 ошибок, ~359 info/warning.
- Журнал лежит в `openspec/RUN-corporate-access-client.md`: путь из шаблона скилла был собран из текста аргументов и нерабочий.
- Flutter 3.38.5 установлен в `C:\flutter` (revision f6ff1529fd, как в CI), системный PATH не меняется: вызывать `/c/flutter/bin/flutter`, `/c/flutter/bin/dart`.
- hide-chain-features и ios-surface-hardening разбиты на два MR каждый, по capability, чтобы MR были ревьюабельны. `openspec archive` — после второго MR change.

## Круги замечаний

- MR #5, круг 1: CI `test` зелёный, сборки ещё идут; бот ревью «Мишка» (codebear) в процессе, замечаний нет. Ничего не исправлено и не отклонено. Журнал не пушится отдельно, пока идёт CI: новый push отменяет прогон (concurrency cancel-in-progress).
- MR #5, круг 2: CI полностью зелёный (test + 6 сборок). Ревью «Мишки» всё ещё не опубликовано (комментарий не обновлялся с 12:26). Исправлений и отклонений нет. Журнал коммитится локально, пушится вместе с правками или при закрытии цикла.
- MR #5, круг 3: опубликовано ревью «Мишки» (🟡, 7 замечаний). Исправлено: имя теста парсера (#4071900406), шаблоны grep в tasks 4.3 + расширенный grep пуст (#4071900235), долг анализатора внесён в «Осталось» (#4071900005), комментарий в тесте ProfileTile уточнён. Отклонено: 3 замечания (см. таблицу).
- MR #5, круг 4 (последний): новых замечаний нет; CI на коммите с правками круга 3: test, ios, macos, linux зелёные, android ×2 и windows ещё шли (правки круга 3 — только тесты и документы; предыдущий прогон на коде этапа был полностью зелёным). Цикл остановлен, cron удалён.
- Push коммитов только с `.md` не перезапускает CI: `ci.yml` имеет `paths-ignore: '**.md'`.

## Отклонённые замечания ревью

| MR | № | Суть | Причина отказа |
|---|---|---|---|
| #5 | 4071899715 | unknownDomainsWarning удалён только из перевода, диалог остался | Ложное срабатывание: диалог, метод `showUnknownDomainsWarning` и ключи удалены во всех 11 локалях; grep по `lib/` пуст |
| #5 | 4071899859 | `telegramChannelUrl` и ключ `telegramChannel` остались мёртвым кодом | Ложное срабатывание: оба удалены в этом же MR |
| #5 | 4071900580 | таймер в ProfileTile не отменяется в dispose | Таймер не в виджете: это `ref.disposeDelay(1 мин)` в `UpdateProfileNotifier`, намеренное кэширование провайдера; тест корректно выжидает его |
| #5 | CoC:62 (мелочь в сводке) | issue tracker — публичный канал для жалоб | Приватного канала без раскрытия связи с оператором нет; вынесено руководству в «Осталось на пользователе» |

## Осталось на пользователе

- Слияние каждого MR.
- Долг анализатора: ~359 info/warning; правило — новые и изменённые файлы без новых замечаний; после фичи — отдельная задача свести к нулю и сделать analyze строгим.
- CODE_OF_CONDUCT: приватный канал для жалоб (email модераторов) — решение руководства.
- Ручные проверки на устройствах (Android, iPhone TestFlight, Windows) — перечислены в tasks.md каждого change.
