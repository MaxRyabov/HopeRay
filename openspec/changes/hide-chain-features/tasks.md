## 1. Флаг и принудительное выключение

- [ ] 1.1 Добавить `kChainFeaturesEnabled = false` в `lib/core/model/constants.dart`
- [ ] 1.2 В `ConfigOptionRepository.fullOptions()` и `fullOptionsOverrided()` при выключенном флаге возвращать опции с `chainStatus: ChainStatus.off`
- [ ] 1.3 В `ProfileParser.profileOverride` при выключенном флаге игнорировать `enable-warp` и `UserOverride.enableWarp` и удалять `chain-status` и `extra-security` из результата
- [ ] 1.4 В `ConfigOptions.singboxConfigOptions` исправить `SingboxUnblockerOption.mode` на `ref.watch(unblockerMode)`

## 2. Диалог WARP

- [ ] 2.1 Вынести условие в чистую функцию `requiresWarpConsent(SingboxConfigOption)`, учитывающую `chainStatus`
- [ ] 2.2 Использовать её в `ConnectionRepository.applyConfigOption`

## 3. UI

- [ ] 3.1 В `settings_page.dart` показывать раздел chain только при `kChainFeaturesEnabled`
- [ ] 3.2 В `quick_settings_modal.dart` показывать `ChainQuickSettings` (и разделитель перед ним) только при `kChainFeaturesEnabled`
- [ ] 3.3 В `routing_config_notifier.dart` регистрировать маршрут `chainOptions` и его redirect только при `kChainFeaturesEnabled`

## 4. Тесты

- [ ] 4.1 Фикстура `SingboxConfigOption` для тестов (JSON в `test/fixtures/` + `fromJson`)
- [ ] 4.2 Unit: `ConfigOptionRepository.fullOptions()` при `chainStatus = extraSecurity` в исходных опциях → `off`
- [ ] 4.3 Unit: `fullOptionsOverrided(profileOverride)` с переопределением `{"chain-status":"extra_security"}` → `off`
- [ ] 4.4 Unit: `ProfileParser.profileOverride` с `enable-warp: true` в заголовках → нет `chain-status` и `extra-security`; с `UserOverride(enableWarp: true)` → то же
- [ ] 4.5 Unit: `requiresWarpConsent` → `false` при `chainStatus = off` и `extraSecurity.mode = warp`; `true` при `chainStatus = extraSecurity` и `mode = warp`; `false` при `chainStatus = unblocker` и `unblocker.mode = psiphon`
- [ ] 4.6 Unit или provider-тест: при `extraSecurityMode = warp` и `unblockerMode = psiphon` в собранных опциях `unblocker.mode == psiphon`
- [ ] 4.7 Widget-тест `SettingsPage`: нет текста `t.pages.settings.chain.title`

## 5. Проверка

- [ ] 5.1 `dart run build_runner build --delete-conflicting-outputs`
- [ ] 5.2 `flutter analyze` без новых замечаний, `flutter test` зелёный (в CI)
- [ ] 5.3 Вручную: чистая установка → добавить ключ → подключиться. Диалог WARP не появляется, в настройках и быстрых настройках нет chain
