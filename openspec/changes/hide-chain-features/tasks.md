## 1. Флаг и принудительное выключение

- [ ] 1.1 Добавить `kChainFeaturesEnabled = false` в `lib/core/model/constants.dart`
- [ ] 1.2 В `ConfigOptionRepository.fullOptions()` и `fullOptionsOverrided()` при выключенном флаге возвращать опции с `chainStatus: ChainStatus.off`
- [ ] 1.3 В `ProfileParser.profileOverride` при выключенном флаге игнорировать `enable-warp` и `UserOverride.enableWarp` и удалять `chain-status` и `extra-security` из результата
- [ ] 1.4 В `ConfigOptions.singboxConfigOptions` исправить `SingboxUnblockerOption.mode` на `ref.watch(unblockerMode)`
- [ ] 1.5 Вручную на Android подтвердить, что туннель, поднятый плиткой быстрых настроек без открытия приложения, использует последние опции, переданные через `changeOptions`. От результата зависит 1.6
- [ ] 1.6 В `bootstrap.dart` после инициализации ядра: при выключенном флаге и сохранённом `chain-status` не `off` сбросить настройку в `off` и отправить ядру актуальные опции

## 1a. WARP-профили

- [ ] 1a.1 Добавить `ProfileParser.containsWarp(String content)`: base64 → текст; строки со схемой `warp://`; JSON с outbound/endpoint `"type": "warp"`
- [ ] 1a.2 В `ProfileRepositoryImpl.validateConfig` до валидации ядром при выключенном флаге читать `tempPath` и возвращать `ProfileFailure.invalidConfig` при WARP. Проверить, что при ошибке ранее сохранённый файл профиля не перезаписывается
- [ ] 1a.3 В `ConnectionRepository` перед стартом проверять файл активного профиля той же функцией и возвращать ошибку
- [ ] 1a.4 Строка ошибки в en и ru (и остальных локалях) о неподдерживаемой конфигурации, `dart run slang`

## 2. Диалог WARP

- [ ] 2.1 Вынести условие в чистую функцию `requiresWarpConsent(SingboxConfigOption)`, учитывающую `chainStatus`
- [ ] 2.2 Использовать её в `ConnectionRepository.applyConfigOption`

## 3. UI

- [ ] 3.1 В `settings_page.dart` показывать раздел chain только при `kChainFeaturesEnabled`
- [ ] 3.2 В `quick_settings_modal.dart` показывать `ChainQuickSettings` (и разделитель перед ним) только при `kChainFeaturesEnabled`
- [ ] 3.3 В `routing_config_notifier.dart` регистрировать маршрут `chainOptions` и его redirect только при `kChainFeaturesEnabled`

## 4. Тесты

- [ ] 4.1 Фикстура `SingboxConfigOption` для тестов (JSON в `test/fixtures/` + `fromJson`)
- [ ] 4.2 Unit: `ConfigOptionRepository.fullOptionsOverrided(null)` и `fullOptionsOverrided('{}')` при `chainStatus = extraSecurity` в исходных опциях → `off`
- [ ] 4.3 Unit: `fullOptionsOverrided(profileOverride)` с переопределением `{"chain-status":"extra_security"}` → `off`
- [ ] 4.4 Unit: `ProfileParser.profileOverride` с `enable-warp: true` в заголовках → нет `chain-status` и `extra-security`; с `UserOverride(enableWarp: true)` → то же
- [ ] 4.5 Unit: `requiresWarpConsent` → `false` при `chainStatus = off` и `extraSecurity.mode = warp`; `true` при `chainStatus = extraSecurity` и `mode = warp`; `false` при `chainStatus = unblocker` и `unblocker.mode = psiphon`
- [ ] 4.6 Unit или provider-тест: при `extraSecurityMode = warp` и `unblockerMode = psiphon` в собранных опциях `unblocker.mode == psiphon`
- [ ] 4.7 Widget-тест `SettingsPage` (через `test/helpers/pump_app.dart`): нет текста `t.pages.settings.chain.title`
- [ ] 4.8 Unit `containsWarp`: `warp://auto#WARP` → true; base64 от строки с `warp://` → true; JSON с endpoint `type: warp` → true; `vless://…` → false; JSON, где `warp` только в поле `tag` → false
- [ ] 4.9 Unit: bootstrap-логика сброса (вынесенная в функцию) при сохранённом `extraSecurity` записывает `off`, при `off` ничего не пишет

## 5. Проверка

- [ ] 5.1 `dart run build_runner build --delete-conflicting-outputs`
- [ ] 5.2 CI зелёный: шаг `flutter analyze` (без ошибок) и `flutter test`
- [ ] 5.3 Вручную: чистая установка → добавить ключ → подключиться. Диалог WARP не появляется, в настройках и быстрых настройках нет chain
- [ ] 5.4 Вручную: быстрые настройки без Extra security / Unblocker / WARP / Psiphon
- [ ] 5.5 Вручную: переход на `/settings/chain-options` (через `context.go` в debug-сборке) не открывает экран chain
- [ ] 5.6 Вручную на Android: установка с включённым chain → обновление поверх → включить туннель плиткой быстрых настроек без открытия приложения. Трафик идёт через сервер ключа, а не через WARP
- [ ] 5.7 Вручную: вставка `warp://auto` из буфера → ошибка, профиль не добавлен
