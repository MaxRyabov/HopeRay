# HopeRay — графика и айдентика

Документ описывает визуальную айдентику HopeRay и то, как генерируются/выводятся все
графические ассеты. Сопутствует `REBRAND.md` (раздел «Image & icon replacement plan»).

## Айдентика

**Знак:** минималистичный **маяк** с широким веером лучей света, расходящихся в стороны от
фонаря (средний луч горизонтальный) — «маяк / луч надежды». Сгенерирован как FLUX-концепт и
переведён в чистый монохромный векторный силуэт.

**Палитра:**

| Токен | HEX | Назначение |
|---|---|---|
| Mark gold | `#FFC24B` | заливка знака / тинт иконки |
| Base indigo | `#0E1430` | плитка иконки, сплэш, Android-фон, web-тема |

Градиенты в системной иконке не используются: Icon Composer (iOS/macOS) и Android заливают
силуэт сплошным цветом, поэтому знак — плоский одноцветный силуэт.

## Источник истины

`assets/images/logo.svg` (viewBox 64×64, один `<g fill="#FFC24B">`). Все иконки выводятся из него.
FLUX-кандидаты и растровые мастера — в `brand/`.

## Производство ассетов

- **Генерация концепта** — скил `.claude/skills/neuraldeep-image` (NeuralDeep FLUX API,
  токен в env `NEURALDEEP_TOKEN`). Только растр; знак затем векторизуется вручную.
- **Рендер SVG → PNG** на dev-машине (нет SVG-тулинга) — Chrome headless.
- **`.ico` / `.webp`** — ImageMagick 7 (`magick`); `.ico` для трея/Windows собираются
  `assets/images/convert_icon.sh`.
- **iOS/macOS** — классический `AppIcon.appiconset` (PNG-набор) в `*/Runner/Assets.xcassets/`,
  сгенерирован из мастера маяка. iOS — full-bleed 1024; macOS — скруглённая «плитка» 16→1024.
  (Icon Composer `.icon` не использовался: он ненадёжно компилировался в CI.)
- **Android adaptive** — `ic_launcher_foreground.xml` (вектор) + цвет фона; legacy
  `mipmap-*/ic_launcher*.webp` (5 плотностей + round).
- **Сплэш** — `flutter_native_splash` (исходники в `assets/images/source/`, цвет в `pubspec.yaml`).

## Проверка

- `.github/workflows/verify-macos-icon.yml` — ручной запуск: неподписанная macOS-сборка
  компилирует иконку и выкладывает превью-артефакт (без Apple-аккаунта/секретов).
- `dart run flutter_native_splash:create` — пересборка сплэша.
- `flutter build apk` — adaptive/round-иконка и `ic_stat_logo` в статус-баре.

## Вне области (делается отдельно)

Скриншоты/превью App Store и Play, тексты листинга — реальными скриншотами устройств.
Подписанная iOS/macOS-сборка требует Apple Developer аккаунта, своих bundle ID
(`app.hoperay.com` + расширение) и Team ID, и секретов в GitHub (см. `build.yml`/`release.yml`).
