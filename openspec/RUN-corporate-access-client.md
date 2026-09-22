# RUN: feat/corporate-access-client

Рабочий журнал фичи. Перечитывать перед каждым действием, которое зависит от прошлых решений.

## Ветки

- Общая ветка: `feat/corporate-access-client` (от `main` после слияния PR #2). Каждый этап — подветка от неё, MR в неё. Финальный MR `feat/corporate-access-client` → `main`.
- Репозиторий: `MaxRyabov/HopeRay`, PR создавать с `--repo MaxRyabov/HopeRay`.

## План этапов (подтверждён 2026-09-22)

| # | Этап / подветка | OpenSpec change | Статус | MR |
|---|---|---|---|---|
| 1 | `stage/1-external-contacts` | remove-external-contacts | MR открыт, цикл замечаний | #5 |
| 2 | `stage/2-key-only-onboarding` | key-only-onboarding | план | — |
| 3 | `stage/3a-hide-chain` | hide-chain-features (chain: UI, off, WARP-диалог, unblocker.mode, сброс в bootstrap) | план | — |
| 4 | `stage/3b-keyless-profiles` | hide-chain-features (WARP/Psiphon-профили, ошибки, json editor) | план | — |
| 5 | `stage/4-remove-sentry` | disable-telemetry-by-default | план | — |
| 6 | `stage/5-positioning-texts` | neutral-positioning-texts | план | — |
| 7 | `stage/6a-no-deep-links` | ios-surface-hardening (deep-links) | план | — |
| 8 | `stage/6b-ios-surface` | ios-surface-hardening (ios-app-surface) | план | — |

## Текущий этап

Этап 1, `stage/1-external-contacts`, MR #5 (база `feat/corporate-access-client`), коммит 3ec0bdde. Цикл замечаний: круг 2 из 4.

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

## Отклонённые замечания ревью

| MR | № | Суть | Причина отказа |
|---|---|---|---|

## Осталось на пользователе

- Слияние каждого MR.
- Этап 1: ручная проверка экрана «О программе» (tasks 4.4) — на ревьюере.
- Ручные проверки на устройствах (Android, iPhone TestFlight, Windows) — перечислены в tasks.md каждого change.
