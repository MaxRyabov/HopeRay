## 1. Флаг и принудительное выключение

- [x] 1.1 Добавить `kChainFeaturesEnabled = false` в `lib/core/model/constants.dart`
- [x] 1.2 В `ConfigOptionRepository.fullOptions()` и `fullOptionsOverrided()` при выключенном флаге возвращать опции с `chainStatus: ChainStatus.off`
- [x] 1.3 В `ProfileParser.profileOverride` при выключенном флаге игнорировать `enable-warp` и `UserOverride.enableWarp` и удалять `chain-status` и `extra-security` из результата
- [x] 1.4 В `ConfigOptions.singboxConfigOptions` исправить `SingboxUnblockerOption.mode` на `ref.watch(unblockerMode)`
- [ ] 1.5 Вручную на Android подтвердить, что туннель, поднятый плиткой быстрых настроек без открытия приложения, использует последние опции и профиль, переданные ядру из приложения. От результата зависит 1.6
- [ ] 1.6 В `bootstrap.dart` после инициализации ядра: при выключенном флаге и сохранённом `chain-status` не `off` сбросить настройку в `off`; если файл активного профиля не проходит `containsKeylessEgress`, снять с профиля активность; в обоих случаях отправить ядру актуальное состояние
  - [x] 1.6a Сброс `chain-status` и отправка опций ядру — этап 3a (`resetDisabledChainStatus`, `lib/features/settings/data/chain_guard.dart`)
  - [ ] 1.6b Снятие активности с WARP/Psiphon-профиля — этап 3b, нужен `containsKeylessEgress`

## 1a. Профили без ключа (WARP, Psiphon)

- [ ] 1a.1 Добавить `ProfileParser.containsKeylessEgress(String content)`: base64 → текст; строки со схемами `warp://`, `psiphon://`; JSON с outbound/endpoint `"type"` = `warp` или `psiphon`
- [ ] 1a.2 Добавить `ProfileFailure.unsupportedConfig()` с текстом в `present(t)`. В `ProfileRepositoryImpl.validateConfig` до валидации ядром при выключенном флаге читать `tempPath` и возвращать эту ошибку, если `containsKeylessEgress` = true. Проверить, что при ошибке ранее сохранённый файл профиля не перезаписывается
- [ ] 1a.3 Добавить `ConnectionFailure.unsupportedProfile(profileName)`; проверять файл профиля той же функцией в `ConnectionRepository.applyConfigOption` (общий путь `connect` и `reconnect`)
- [ ] 1a.4 Строки ошибок en: «Unsupported configuration: Cloudflare WARP profiles are not available» и «Profile "${name}" uses Cloudflare WARP, which is not supported. Delete it and add the access key issued to you.»; ru: «Конфигурация не поддерживается: профили Cloudflare WARP недоступны» и «Профиль "${name}" использует Cloudflare WARP, это не поддерживается. Удалите его и добавьте выданный вам ключ доступа.»; остальные локали — перевод; `dart run slang`
- [ ] 1a.5 `json_editor.dart`: убрать `warp` из `protocolSchemaValues` и из `config.endpoints.type` безусловно
- [ ] 1a.6 `profiles_update_notifier.dart`: в тосте ошибки фонового обновления показывать причину (`t.presentError(l)`) вместе с именем профиля

## 2. Диалог WARP

- [x] 2.1 Вынести условие в чистую функцию `requiresWarpConsent(SingboxConfigOption)`, учитывающую `chainStatus`
- [x] 2.2 Использовать её в `ConnectionRepository.applyConfigOption`

## 3. UI

- [x] 3.1 В `settings_page.dart` показывать раздел chain только при `kChainFeaturesEnabled`
- [x] 3.2 В `quick_settings_modal.dart` показывать `ChainQuickSettings` (и разделитель перед ним) только при `kChainFeaturesEnabled`
- [x] 3.3 В `routing_config_notifier.dart` регистрировать маршрут `chainOptions` и его redirect только при `kChainFeaturesEnabled`

## 4. Тесты

- [x] 4.1 Фикстура `SingboxConfigOption` для тестов (JSON в `test/fixtures/` + `fromJson`) — сделано фабрикой `test/helpers/config_options.dart`: опции собирает сам провайдер на моках, JSON-фикстура не нужна и не устареет (вариант из design.md, Risks)
- [x] 4.2 Unit: `ConfigOptionRepository.fullOptionsOverrided(null)` и `fullOptionsOverrided('{}')` при `chainStatus = extraSecurity` в исходных опциях → `off`
- [x] 4.3 Unit: `fullOptionsOverrided(profileOverride)` с переопределением `{"chain-status":"extra_security"}` → `off`
- [x] 4.4 Unit: `ProfileParser.profileOverride` с `enable-warp: true` в заголовках → нет `chain-status` и `extra-security`; с `UserOverride(enableWarp: true)` → то же
- [x] 4.5 Unit: `requiresWarpConsent` → `false` при `chainStatus = off` и `extraSecurity.mode = warp`; `true` при `chainStatus = extraSecurity` и `mode = warp`; `false` при `chainStatus = unblocker` и `unblocker.mode = psiphon`
- [x] 4.6 Unit или provider-тест: при `extraSecurityMode = warp` и `unblockerMode = psiphon` в собранных опциях `unblocker.mode == psiphon`
- [x] 4.7 Widget-тест `SettingsPage` (через `test/helpers/pump_app.dart`) с оверрайдом `hasAnyProfileProvider` → `true` (иначе пункт скрыт и без изменений): нет текста `t.pages.settings.chain.title`
- [ ] 4.8 Unit `containsKeylessEgress` (фикстуры в `test.configs/warp`, `test.configs/warp2`): `warp://auto#WARP` → true; `psiphon://auto/` → true; base64 от строки с `warp://` → true; JSON с endpoint `type: warp` → true; JSON с outbound `type: psiphon` → true; `vless://…` → false; JSON, где `warp` только в поле `tag` → false
- [ ] 4.9 Unit: bootstrap-логика сброса (вынесенная в функцию) при сохранённом `extraSecurity` записывает `off`, при `off` ничего не пишет; при активном профиле с `warp://` снимает активность, при `vless://` не трогает
  - [x] 4.9a Сброс chain: `extraSecurity`/`unblocker` → `off`, при `off` и без сохранённого значения ничего не пишет — этап 3a
  - [ ] 4.9b Снятие активности с профиля `warp://` / сохранение `vless://` — этап 3b

## 5. Проверка

- [x] 5.1 `dart run build_runner build --delete-conflicting-outputs` — этап 3a не меняет входов кодогенерации (freezed, `@riverpod`, drift, переводы); на 3b понадобится из-за новых вариантов ошибок
- [ ] 5.2 CI зелёный: шаг `flutter analyze` (без ошибок) и `flutter test`
- [ ] 5.3 Вручную: чистая установка → добавить ключ → подключиться. Диалог WARP не появляется, в настройках и быстрых настройках нет chain
- [ ] 5.4 Вручную: быстрые настройки без Extra security / Unblocker / WARP / Psiphon
- [ ] 5.5 Вручную: переход на `/settings/chain-options` (через `context.go` в debug-сборке) не открывает экран chain
- [ ] 5.6 Вручную на Android: установка с включённым chain → обновление поверх → включить туннель плиткой быстрых настроек без открытия приложения. Трафик идёт через сервер ключа, а не через WARP
- [ ] 5.7 Вручную: вставка `warp://auto` и `psiphon://auto/` из буфера → локализованная ошибка, профиль не добавлен
- [ ] 5.8 Вручную на Android: установка с активным WARP-профилем → обновление поверх → открыть приложение → профиль не активен, «Подключиться» ведёт к добавлению ключа; при включённом туннеле сделать активным WARP-профиль → ошибка, переподключения нет
