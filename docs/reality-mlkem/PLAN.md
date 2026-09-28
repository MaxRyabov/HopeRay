# REALITY + Xray-core 26.9.8+: технический план доработки HopeRay

Статус: **план, код приложения не менялся.** Патч ядра написан и проверен
(28.09.2026). Документ рассчитан на агента в чистой сессии: здесь есть весь
нужный контекст, внешние заметки не требуются.

Файлы рядом:

| файл | что это |
|---|---|
| [sing-box-reality-mlkem.patch](sing-box-reality-mlkem.patch) | патч для `hiddify-sing-box`: исправление + Go-тест |
| [lab/reality-lab.sh](lab/reality-lab.sh) | локальный стенд: sing-box-клиент × серверы Xray, всё на `127.0.0.1` |
| [hoperay-release.yml](hoperay-release.yml) | шаблон CI-релиза ядра для форка `hiddify-core` |

Метка **[владелец]** — шаг, который агент сам сделать не может (права на
GitHub, телефоны, магазины). На нём агент останавливается и просит владельца.

---

## 1. Проблема

С Xray-core **26.9.8** REALITY-сервер отвергает ClientHello, в котором нет
key share **X25519MLKEM768**, стоящего **раньше** обычного X25519. Такой клиент
сервер не считает REALITY-клиентом и проксирует его на настоящий сайт-маскировку.
Клиент получает чужой сертификат; в логе ядра — `reality verification failed`,
в интерфейсе — таймаут. Требование конфигом сервера не отключается.

- Изменение: [XTLS/REALITY@8cdf7bf](https://github.com/XTLS/REALITY/commit/8cdf7bf9c7f09cb9814bf08c3eb877f68b85fba8)
  («Reject outdated/strange Client Hello that doesn't have X25519MLKEM768 before optional X25519»).
- В upstream sing-box не исправлено: [SagerNet/sing-box#4520](https://github.com/SagerNet/sing-box/issues/4520)
  (на 28.09.2026 открыт, в ветке `testing` код тот же). Не работает ни одна
  версия sing-box, включая 1.14.x.

HopeRay использует ядро `hiddify-core` 4.1.0 = форк sing-box 1.13.0, поэтому
к таким серверам не подключается. Xray-клиенты (v2rayN, OneXray и т.п.)
работают.

## 2. Причина в коде

Цепочка: HopeRay (Flutter) → готовые архивы `hiddify-lib-*` из релиза
`hiddify/hiddify-core` v4.1.0 (`dependencies.properties` → `Makefile`,
`CORE_URL`) → сабмодуль `hiddify-sing-box` → **`common/tls/reality_client.go`**.
Файл совпадает с upstream sing-box 1.13.0 байт в байт.

1. **Фильтр MLKEM.** `ClientHandshake` после `BuildHandshakeState()` удаляет
   `utls.X25519MLKEM768` из `SupportedCurvesExtension` и `KeyShareExtension`
   и пересобирает ClientHello. Ровно то, что новый сервер отвергает.
2. **Старые отпечатки uTLS.** sing-box использует `github.com/metacubex/utls`
   v1.8.4 (в v1.8.7 и HEAD то же самое): `firefox` = `HelloFirefox_120`,
   `safari` = `HelloSafari_16_0`, `ios` = `HelloIOS_14`, `edge` = `HelloEdge_85` —
   **MLKEM в них нет**. MLKEM перед X25519 есть только в `chrome` =
   `HelloChrome_133`. У Xray `refraction-networking/utls`, где `firefox` =
   Firefox 148, `safari` = Safari 26.3. Поэтому одного удаления фильтра мало:
   в реальных ссылках часто `fp=firefox`. ray2sing передаёт `fp` из ссылки как
   есть; без `fp` для REALITY подставляет `chrome` (`ray2sing/ray2sing/common.go`).
3. **Версия в handshake.** sing-box пишет в SessionId версию `1.8.1`. В Xray
   26.9.9 минимальная версия клиента по умолчанию закомментирована
   (`infra/conf/transport_security.go`, раньше было `26.3.27`), так что сейчас
   это не мешает. Но сервер с `minClientVer` ≥ 1.8.2 или возврат этого умолчания
   снова отрежет sing-box.

Что **не** годится как обходной путь: встроенный xray-core в hiddify-core —
заглушка (`hiddify-sing-box/protocol/hiddify/xray/outbound.go` возвращает
`"Xray is not implemented yet"`, вызов в `ray2sing/ray2sing/convert.go`
закрыт `if false`).

## 3. Исправление

[sing-box-reality-mlkem.patch](sing-box-reality-mlkem.patch) меняет только
`common/tls/reality_client.go` и добавляет `common/tls/reality_client_test.go`:

- **фильтр MLKEM удалён**;
- новая `realityUClient(conn, config, id)`: строит ClientHello по выбранному
  отпечатку; если в `key_share` нет X25519MLKEM768 перед X25519
  (`realityHasMLKEMKeyShare`), пересобирает на `utls.HelloChrome_Auto`;
- ключ аутентификации REALITY — `KeyShareKeys.Ecdhe`, при его отсутствии
  `KeyShareKeys.MlkemEcdhe` (так же делает клиент Xray,
  `transport/internet/reality/reality.go`). Сервер берёт отдельный X25519, если он
  есть, иначе X25519-часть гибридного ключа — поэтому это совпадает;
- версия в handshake — **26.9.9** вместо `1.8.1`;
- тест `TestRealityClientHelloHasMLKEM`: для всех 11 значений `fingerprint`
  (`""`, chrome, firefox, edge, safari, 360, qq, ios, android, random,
  randomized) ClientHello содержит MLKEM перед X25519 и есть ключ X25519.

Осознанные компромиссы:

| что | почему приемлемо |
|---|---|
| `fp=firefox/safari/…` фактически уходит как Chrome 133 | Chrome — самый массовый отпечаток, для DPI не хуже. Честный Firefox 148 — перенос парротов в форк utls, отдельная задача, не делать сейчас |
| ClientHello на ~1,2 КБ больше | так же у Chrome и всех Xray-клиентов |
| sing-box представляется Xray 26.9.9 | так представляются все Xray-клиенты; старые серверы с `minClientVer 1.8.0` пускают (проверено) |

## 4. Что уже проверено (28.09.2026, Windows 10)

| проверка | результат |
|---|---|
| `git apply --check` на `hiddify-sing-box` `0a02b77` (ядро v4.1.0) и `3a1c923` (HEAD) | ложится (файл в обоих коммитах одинаковый) |
| `go test -tags with_utls ./common/tls/ -run TestRealityClientHelloHasMLKEM` в `hiddify-sing-box`, Go 1.25.6 | PASS, 11/11 |
| `go build -tags with_utls ./cmd/sing-box` в `hiddify-sing-box`, Go 1.25.6 | собирается |
| `lab/reality-lab.sh` с этим бинарём | 9/9 PASS (таблица ниже) |
| тот же клиент против боевого REALITY-сервера на Xray 26.9.9 | fp firefox 4/4, chrome 4/4; официальный 1.13.0 — 0/4 |

Ожидаемый вывод стенда:

| сервер | официальный sing-box 1.13.0 | с патчем (firefox/chrome/safari) |
|---|---|---|
| Xray 26.9.9 | ✗ `reality verification failed` | ✓ ✓ ✓ |
| Xray 26.9.9 + `minClientVer 26.3.27` | ✗ | ✓ ✓ ✓ |
| Xray 26.7.28 + `minClientVer 1.8.0` | ✓ | ✓ ✓ ✓ |

## 5. Инварианты — чего не делать

- **Не поднимать версию ядра.** Основа — ровно `hiddify-core` **v4.1.0**
  (`c9d6f0f00b2eda34e4fb71863e4e0a62b3e931a0`) и её `hiddify-sing-box`
  **`0a02b7729f6a211436bb8bdcd8696c283eb27767`**. Сабмодуль `hiddify-core` в HopeRay
  сейчас указывает на `f2034de` (v4.1.0+18), но приложение собирается с
  архивами **v4.1.0**. Другая версия ядра меняет API Libbox и ломает нативный
  код Android/iOS (см. комментарий у `CORE_URL` в `Makefile`).
- Не переименовывать `com.hiddify.core.*`, `HiddifyCore.xcframework`,
  `hiddify-core.aar/.dll/.so/.dylib`, `com.hiddify.app` — см. `REBRAND.md`.
- Не править `lib/gen/`, `*.g.dart`, `*.freezed.dart`.
- Репозиторий публичный: **никаких адресов серверов, ключей, UUID, shortId,
  ссылок пользователей** — ни в коде, ни в тестах, ни в коммитах. Стенд
  генерирует одноразовые ключи сам.
- Не сливать в `main` HopeRay, пока нет релиза ядра (этап 3): иначе CI HopeRay
  упадёт на скачивании архивов.

## 6. Окружение и ловушки

- **Go строго 1.25.x** (в `hiddify-core/go.mod` — `go 1.25.6`). Бинарь, собранный
  на Go 1.26, **падает при старте**: `panic: tls: ConnectionState is not equal to
  tls.ConnectionState` из `replace/psiphon-tls/unsafe.go`. Если Go в системе нет,
  взять переносной архив `https://go.dev/dl/go1.25.6.windows-amd64.zip` в
  scratchpad и выставить `GOROOT`/`PATH` на него, плюс `GOTOOLCHAIN=local`.
- **Windows, длинные пути:** с длинным `GOMODCACHE` сборка падает с
  `fork/exec ...asm.exe: The directory name is invalid`. Лечится коротким путём:
  `GOMODCACHE=C:/Users/<user>/AppData/Local/Temp/gm`, `GOCACHE=.../gc`.
- **Сабмодули по SSH.** `.gitmodules` в HopeRay, hiddify-core (`ray2sing`) и
  hiddify-sing-box (`replace/*`) указывают на `ssh://`/`git@`. Без SSH-ключа:
  ```bash
  git -c url."https://github.com/".insteadOf="git@github.com:" \
      -c url."https://github.com/".insteadOf="ssh://git@github.com/" \
      submodule update --init --recursive
  ```
  `hiddify-sing-box` **обязательно рекурсивно**: без `replace/psiphon-tls` и др.
  не собирается даже тест.
- Git Bash на этой машине иногда падает при старте (`add_item ... errno 1`).
  Это сбой среды, а не команды: просто повторить.
- `gh` может не быть. Тогда PR открывать ссылкой
  `https://github.com/<owner>/<repo>/compare/<base>...<branch>?expand=1`,
  а статус CI смотреть через `https://api.github.com/repos/<owner>/<repo>/actions/runs`.
- Makefile HopeRay требует bash; в PowerShell использовать сырые команды
  `flutter`/`dart` (см. `CLAUDE.md`).

## 7. Этапы

### Этап 0 [владелец]. Форки и Actions

1. Форкнуть в `MaxRyabov`:
   - `https://github.com/hiddify/hiddify-sing-box` → `MaxRyabov/hiddify-sing-box`
   - `https://github.com/hiddify/hiddify-core` → `MaxRyabov/hiddify-core`
   При форке снять «Copy the main branch only» — нужны все ветки: коммит
   `0a02b77` достижим только из `extended` и `testing-merge-base`.
2. В `MaxRyabov/hiddify-core` → Actions → включить workflows (в форках они
   выключены по умолчанию). Settings → Actions → General → Workflow
   permissions: **Read and write**.
3. Дать агенту право пушить в оба форка (те же учётные данные git, что и для HopeRay).

Проверка агентом: `git ls-remote https://github.com/MaxRyabov/hiddify-core` и
`.../hiddify-sing-box` отвечают.

### Этап 1. Форк sing-box: патч

```bash
git clone -c core.autocrlf=false https://github.com/MaxRyabov/hiddify-sing-box && cd hiddify-sing-box
git checkout -b hoperay/reality-mlkem 0a02b7729f6a211436bb8bdcd8696c283eb27767
git -c url."https://github.com/".insteadOf="git@github.com:" submodule update --init --recursive
git apply <HopeRay>/docs/reality-mlkem/sing-box-reality-mlkem.patch
gofmt -l common/tls/reality_client.go common/tls/reality_client_test.go   # пусто; при CRLF-чекауте gofmt ругается на всё — отсюда autocrlf=false
go test -tags with_utls ./common/tls/ -run TestRealityClientHelloHasMLKEM -v
go build -tags with_utls -o sing-box-patched ./cmd/sing-box
```

Коммит — одно изменение, сообщение по смыслу (`fix(reality): send X25519MLKEM768
for Xray-core 26.9.8+ servers`). Пуш ветки. Тег `v1.13.0-hr1` на этом коммите.

**Готово, когда:** тест PASS; `bash <HopeRay>/docs/reality-mlkem/lab/reality-lab.sh
./sing-box-patched` → `RESULT: PASS`; ветка и тег в форке.

### Этап 2. Форк hiddify-core: сабмодули

```bash
git clone -c core.autocrlf=false https://github.com/MaxRyabov/hiddify-core && cd hiddify-core
git checkout -b hoperay/reality-mlkem c9d6f0f00b2eda34e4fb71863e4e0a62b3e931a0   # тег v4.1.0
```

1. `.gitmodules`:
   - `hiddify-sing-box` → `url = https://github.com/MaxRyabov/hiddify-sing-box`
   - `ray2sing` → `url = https://github.com/hiddify/ray2sing` (HTTPS вместо `git@`; CI-чекаут
     `submodules: recursive` без ключа иначе не пройдёт).
2. `git submodule sync --recursive && git submodule update --init --recursive`
   (с `insteadOf` из раздела 6), затем
   `git -C hiddify-sing-box checkout <коммит этапа 1>` и `git add .gitmodules hiddify-sing-box`.
   `ray2sing` оставить на `f58be84e30d946915a1de437fbcc3d3ffca18a23` (как в v4.1.0).
3. В `hiddify-sing-box/.gitmodules` (то есть уже в форке sing-box) SSH-адреса
   `replace/*` тоже заменить на HTTPS, если CI-чекаут на них упадёт. Это
   отдельный коммит в ветке этапа 1 и ещё одно обновление указателя сабмодуля.
4. Локальная проверка, что `go.mod` берёт sing-box из сабмодуля:
   `go list -m -f '{{.Replace.Path}}' github.com/sagernet/sing-box` → `./hiddify-sing-box`.

### Этап 3. Форк hiddify-core: CI-релиз

1. Скопировать [hoperay-release.yml](hoperay-release.yml) в
   `.github/workflows/hoperay-release.yml`.
2. В `.github/workflows/release.yml` оставить только `on: workflow_dispatch:`:
   upstream-триггер по тегам `v*` запускал бы prod-задания (docker в
   `ghcr.io/hiddify`, коммит в `main`, GPG-подпись).
3. Коммит, пуш ветки, тег **`v4.1.0-hr1`**, пуш тега. Workflow `HopeRay core release`
   собирает `hiddify-lib-{android,ios,macos,windows-amd64,linux-amd64,linux-arm64}.tar.gz`
   и публикует релиз на теге.

Шаблон CI **не проверялся** (форков ещё нет). Вероятные места отказа:
- чекаут сабмодулей по SSH → пункт 2.1/2.3;
- сборка cronet для linux-задач (`make cronet-*`) долгая и хрупкая. Linux-архивы
  нужны: CI HopeRay гоняет тесты с `make linux-amd64-prepare`. Если cronet
  сломан — смотреть, как upstream собирал v4.1.0 (Actions в `hiddify/hiddify-core`),
  а не выкидывать задание;
- `calculate_version` запускает `go run ./cmd/internal/read_tag` в `hiddify-sing-box` —
  нужен тег в форке sing-box (этап 1).

**Готово, когда:** релиз `v4.1.0-hr1` в `MaxRyabov/hiddify-core` содержит все шесть
архивов, и патч внутри бинарей. Имена функций Go остаются в pclntab даже при `-s -w`:
```bash
curl -sL https://github.com/MaxRyabov/hiddify-core/releases/download/v4.1.0-hr1/hiddify-lib-windows-amd64.tar.gz | tar xz
grep -a -c 'tls.realityUClient' hiddify-core.dll                  # > 0
curl -sL .../hiddify-lib-android.tar.gz | tar xz
unzip -p hiddify-core.aar 'jni/arm64-v8a/*' | grep -a -c 'tls.realityUClient'   # > 0
```
У официального v4.1.0 оба счётчика — 0.

### Этап 4. HopeRay: переключение на пропатченное ядро

Ветка от `main`, например `fix/reality-mlkem-core`. Изменения:

| файл | было | стало |
|---|---|---|
| `dependencies.properties` | `core.version=4.1.0` | `core.version=4.1.0-hr1` |
| `Makefile`, `CORE_URL` | `https://github.com/hiddify/hiddify-next-core/releases/download/v$(core.version)` | `https://github.com/MaxRyabov/hiddify-core/releases/download/v$(core.version)` |
| `.gitmodules`, `hiddify-core` | `ssh://git@github.com/hiddify/hiddify-core`, `branch = v3` | `https://github.com/MaxRyabov/hiddify-core`, `branch = hoperay/reality-mlkem` |
| сабмодуль `hiddify-core` | `f2034de` | коммит тега `v4.1.0-hr1` |
| `.github/change_version.sh`, строка 5 | проверка `hiddify/hiddify-core/.../hiddify-core-linux-amd64.tar.gz` | `MaxRyabov/hiddify-core/.../hiddify-lib-linux-amd64.tar.gz` (CLI-архивов в нашем релизе нет) |
| `pubspec.yaml` | `version: 4.1.2+40105` | build number +1 (`+40106`); номер версии — решение владельца |
| `CLAUDE.md`, `REBRAND.md` | «ядро — внешний upstream, не трогаем» | ядро — форк `MaxRyabov/hiddify-core` с патчем REALITY, ссылка на этот план |

Больше ничего менять не нужно: имена архивов (`hiddify-lib-*`), `.aar`,
`HiddifyCore.xcframework`, `.dll/.so/.dylib`, FFI и gRPC-протоколы остаются прежними.

Проверки:
- `make windows-libs` (bash) скачивает архив из форка; `hiddify-core/bin/hiddify-core.dll`
  содержит `tls.realityUClient`;
- `flutter pub get && dart run build_runner build --delete-conflicting-outputs && dart run slang && flutter analyze && flutter test`;
- PR в `main` → CI HopeRay (`ci.yml` → `build.yml`) зелёный по всем платформам.

### Этап 5 [владелец]. Проверка на устройствах

Собранные в CI артефакты (APK, установщик Windows, IPA через TestFlight):

1. Импорт **существующей** ссылки/подписки без изменений (`fp=firefox`).
2. Подключение на мобильной сети и на Wi-Fi; открываются Google, YouTube и
   локальные сайты.
3. Переподключение, смена сети, выход из сна.
4. Профили без REALITY (VLESS+TLS, Hysteria2, WireGuard, если есть) работают как раньше.
5. В логах приложения нет `reality verification failed`.

### Этап 6 [владелец]. Раздача

- Android, Windows, macOS, Linux — прямые файлы.
- iOS — нужен Apple Developer ($99/год) и TestFlight (`.github/workflows/ios-testflight.yml`)
  или App Store с ревью VPN-приложения. Пока iOS-сборки нет, у пользователей
  iPhone остаётся Xray-клиент.

## 8. Сопровождение

- При любом обновлении ядра (новый тег hiddify-core): перенести коммит этапа 1
  на новый `hiddify-sing-box`, прогнать тест и стенд, выпустить `vX.Y.Z-hrN`,
  поменять `core.version`. Если upstream закроет sing-box#4520 — сравнить с
  нашим патчем и, если эквивалентно, отказаться от форка.
- Перед обновлением Xray на серверах — прогнать `lab/reality-lab.sh` против
  новой версии: добавить её в список серверов в конце скрипта. RPRX ужесточает
  REALITY без оглядки на sing-box, следующее ужесточение снова может сломать
  клиент.
- По желанию — предложить патч upstream (SagerNet/sing-box, ветка `testing`).

## 9. Стенд

```bash
bash docs/reality-mlkem/lab/reality-lab.sh <sing-box-binary>          # ждёт PASS, exit 1 при сбое
bash docs/reality-mlkem/lab/reality-lab.sh <sing-box-binary> legacy   # просто печатает матрицу
```

Скачивает Xray 26.9.9 и 26.7.28 в `./.reality-lab` (в `.gitignore`),
генерирует ключи (`xray x25519`), по очереди поднимает три сервера на
`127.0.0.1:18443` и гоняет клиента с `fp` firefox/chrome/safari через SOCKS
`127.0.0.1:10829`. Нужен интернет: трафик выходит через freedom-outbound
сервера. Переменные: `LAB_DIR`, `LAB_SNI` (по умолчанию `www.google.com`;
с `www.microsoft.com` сервер 26.7.28 не работает — это особенность цели, не
патча). Критерий — ноль `reality verification failed` и хотя бы один успешный
запрос в каждой строке: отдельные таймауты медленных сайтов бывают.

Клиент должен быть собран с `-tags with_utls`. Официальный sing-box 1.13.0
для контроля: `https://github.com/SagerNet/sing-box/releases/tag/v1.13.0`.
