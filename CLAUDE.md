# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

**HopeRay** — a cross-platform, multi-protocol proxy client (frontend for the sing-box core).
This repo (`HopeRay`) is a fork of `hiddify/hiddify-next`. The Android applicationId / desktop
app id is `app.hoperay.com`, the Android package is `com.hoperay.hoperay`, and the in-app name is
`HopeRay` (`lib/core/model/constants.dart`). Note: the native core (`hiddify-core`) and the internal
IPC/service namespace `com.hiddify.app` are intentionally **not** renamed — see `REBRAND.md`.

- **Stack:** Flutter (Dart), Riverpod state management, Drift (SQLite), gRPC + FFI to a native
  `hiddify-core` library (the sing-box engine).
- **Platforms:** Android, iOS, Windows, macOS, Linux (web tooling present).
- **Version pin (strict):** `pubspec.yaml` declares `flutter: ^3.38.5` / Dart `^3.10.4`. The
  Flutter line is **parsed by the Makefile and Dockerfile** — do not remove or reformat it.

## Build & codegen commands

This project is **code-generation-heavy** — you cannot run or analyze it meaningfully until codegen
has run. The canonical interface is the `Makefile`, but its targets assume a bash-like shell. On
the Windows/PowerShell dev box, run the underlying `flutter`/`dart` commands directly.

| Task | Make target | Raw command (works in PowerShell) |
|------|-------------|-----------------------------------|
| Install deps | `make get` | `flutter pub get` |
| Run all codegen | `make gen` | `dart run build_runner build --delete-conflicting-outputs` |
| Generate translations | `make translate` | `dart run slang` |
| Full prepare (deps+gen+i18n) | `make common-prepare` | run the three above in order |
| Per-platform prepare (also downloads native libs) | `make windows-prepare` / `android-prepare` / `linux-prepare` / `macos-prepare` / `ios-prepare` | see Makefile |
| Tests | — | `flutter test` |
| Analyze | — | `flutter analyze` (or `dart analyze`) |
| Run app (dev) | — | `flutter run -t lib/main.dart` |

- **Entry points:** `lib/main.dart` (dev / default), `lib/main_prod.dart` (prod channel). The
  Makefile selects the target via `CHANNEL`.
- **Native core libs** are downloaded as prebuilt archives by the `*-prepare` targets from
  `hiddify-next-core` releases (version in `dependencies.properties`, `core.version`). They are
  **not** in git. Without them the desktop/mobile app cannot connect.
- **Release builds** use `fastforge` (e.g. `make windows-release`, `make android-release`). Most
  release targets require `SENTRY_DSN` to be set.
- **protobuf/gRPC regeneration** (rarely needed): `make protos` (needs `protoc` +
  `dart pub global activate protoc_plugin`). Generated output lives in `lib/hiddifycore/generated/`.

### Always re-run codegen after editing any of these
freezed models, `@riverpod`/`@Riverpod` providers, `json_serializable` models, Drift schema
(`lib/core/db/`), or translation files (`assets/translations/*.i18n.json`). Run
`dart run build_runner build --delete-conflicting-outputs` (and `dart run slang` for translations).

## Architecture

**Feature-first**, with shared infrastructure under `lib/core/`.

```
lib/
├── main.dart / main_prod.dart   # entry points
├── bootstrap.dart               # ordered app initialization
├── riverpod_observer.dart       # logs provider state changes
├── core/                        # cross-cutting: db, router, theme, preferences,
│                                #   localization, logger, model, widget, utils…
├── features/                    # feature modules (profile, connection, proxy, settings,
│                                #   route_rules, per_app_proxy, stats, chain, home, log…)
├── hiddifycore/                 # gRPC client + generated protobuf bindings to the core
├── singbox/                     # sing-box domain models
└── gen/                         # GENERATED (translations, assets, FFI bindings) — never edit
```

Each feature typically follows:
```
features/<name>/
├── model/      # freezed entities, sealed failures, enums
├── data/       # *_data_source.dart, *_repository.dart (+Impl), *_data_providers.dart
├── notifier/   # Riverpod notifiers / StreamNotifiers
└── overview|widget/  # *_page.dart, *_widget.dart
```

### Key anchors
- Native core service (talks to sing-box): `lib/hiddifycore/hiddify_core_service.dart`,
  provided via `lib/hiddifycore/hiddify_core_service_provider.dart`. Platform impls in
  `lib/hiddifycore/core_interface/` (desktop = FFI via `lib/gen/hiddify_core_generated_bindings.dart`).
- Connection state: `lib/features/connection/notifier/connection_notifier.dart`.
- Routing (go_router, built dynamically): `lib/core/router/go_router/routing_config_notifier.dart`.
- Database (Drift, with migrations): `lib/core/db/db.dart`, schemas in `lib/core/db/schemas`.
- Preferences (reactive, SharedPreferences-backed): `lib/core/preferences/general_preferences.dart`.
- Profiles (subscriptions): `lib/features/profile/data/profile_repository.dart`.

## Conventions

- **State management:** Riverpod 2.x with code-gen. Notifier classes use
  `@riverpod`/`@Riverpod(keepAlive: ...)` and `extends _$Name`. Providers end in `Provider`.
  Use `ref.watch` for rebuilds, `ref.read(...notifier)` for actions, `ref.listen` for side effects.
- **Error handling:** functional — `fpdart` `TaskEither<Failure, T>`; failures are sealed classes.
- **Models:** `freezed` immutable / sealed unions with named constructors.
- **Logging:** logger mixins (`InfraLogger`, `AppLogger`, `PresLogger`) via `loggy`.
- **i18n:** `slang`. Edit `assets/translations/en.i18n.json` (base locale) then `dart run slang`.
  Access via the generated translations provider — do not hardcode user-facing strings.
- **Lint/format:** `package:lint/strict.yaml` + `custom_lint` (`provider_parameters` rule).
  **Formatter page width is 120.** Generated code (`**.g.dart`, `lib/gen/**`) and `hiddify-core/**`
  are excluded from analysis — never hand-edit generated files.
- **Commit messages:** conventional-ish prefixes seen in history — `feat:`, `fix:`, `refactor:`,
  `ui:`, `update`.

## Gotchas

- Do not edit anything in `lib/gen/`, any `*.g.dart` / `*.freezed.dart`, or the `hiddify-core/`
  submodule — regenerate instead.
- `hiddify-core` is a git submodule (`.gitmodules`, branch `v3`, SSH remote).
- The strict Flutter version line in `pubspec.yaml` is machine-parsed — keep its format intact.
- After pulling changes that touch models/providers/schema/translations, re-run codegen before
  running or analyzing the app.
- On Windows, prefer the raw `flutter`/`dart` commands over `make` (the Makefile is bash-based).
