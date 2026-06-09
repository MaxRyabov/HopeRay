# HopeRay rebrand — status & plan

Tracks the rebrand of this fork (Hiddify → **HopeRay**). Delete this file once the rebrand is finished.

The native core (`hiddify-core` / `hiddify-next-core`, the sing-box engine) is an **external upstream
dependency** and is intentionally **not** renamed: package `com.hiddify.core.*`, the FFI bindings
(`HiddifyCoreNativeLibrary` in `pubspec.yaml` `ffigen:`), `hiddify-core.dll/.so`, generated protos, and
the `hiddify-core` submodule all stay as-is.

---

## ✅ Done

- **Display name → "HopeRay"**
  - `lib/core/model/constants.dart` → `appName`
  - All 12 translation files (`assets/translations/*.i18n.json`): `appTitle` + the "Made with ❤️ by …" string
  - Android: `android/app/src/main/AndroidManifest.xml` → `android:label`
  - iOS: `ios/Runner/Info.plist` → `CFBundleDisplayName`
  - macOS: `macos/Runner/Configs/AppInfo.xcconfig` → `PRODUCT_NAME`, `PRODUCT_COPYRIGHT`
  - Windows: `windows/runner/main.cpp` (window title + `HopeRayMutex`), `windows/runner/Runner.rc` (version metadata)
  - Web: `web/manifest.json` (`name` / `short_name` / `description`)
- **Docs cleanup**
  - Rewrote `README.md` (single, minimal, attributes upstream Hiddify per license)
  - Deleted localized READMEs (`README_{br,cn,fa,ja,ru}.md`), `CONTRIBUTING.md`,
    `.github/release_message.md`, `.github/ISSUE_TEMPLATE/*`, `.github/help/`

> ⚠️ **Run codegen** — Flutter SDK was not available on this machine, so these were **not** run.
> After pulling, run: `dart run slang` (regenerates the translation `.g.dart` with the new appTitle)
> and `flutter analyze`.

---

## ✅ Done — identifier rebrand (mirrored pattern)

All applied. **Cannot be build-verified here** (no native libs / Flutter SDK) — build each platform to confirm.

| Identifier | Change | Notes |
|---|---|---|
| Android package | `com.hiddify.hiddify` → `com.hoperay.hoperay` | 37 `.kt` + 2 `.aidl` moved to `kotlin/com/hoperay/hoperay/` & `aidl/com/hoperay/hoperay/`, all `package`/`import` updated, `build.gradle` namespace/testNamespace, `shortcuts.xml` |
| Android applicationId | `app.hiddify.com` → `app.hoperay.com` | `build.gradle`, `shortcuts.xml` targetPackage |
| iOS bundle id | `apple.hiddify.com` → `apple.hoperay.com` | `Base.xcconfig`, `exportOptions.plist`, pbxproj scheme, `ExtensionProvider.swift` logger |
| iOS URL name / tests | `com.hiddify.ios` → `com.hoperay.ios` | `Info.plist`, pbxproj RunnerTests |
| macOS bundle id | `app.hiddify.com` → `app.hoperay.com`; product `Hiddify.app` → `HopeRay.app`; `RunnerTests` id | `AppInfo.xcconfig`, pbxproj, scheme, dmg config |
| URL scheme | added `hoperay://` (kept `hiddify://`) | Android manifest, iOS/macOS plists, Linux mime, Dart `link_parsers.dart` |
| Binary name | `Hiddify`/`hiddify` → `HopeRay`/`hoperay` | Windows `CMakeLists` + `Runner.rc` + inno_setup, Linux `CMakeLists`, all `make_config.yaml`, AppRun, Makefile appimage step |
| Linux appdata | renamed `app.hiddify.com.appdata.xml` → `app.hoperay.com.appdata.xml` + rewritten | id/name/launchable/icon/binary/mime/urls |
| URLs in `constants.dart` | upstream → `hoperay` **placeholders** (with `TODO`) | non-existent repo ⇒ update checker fails gracefully = Hiddify auto-update disabled |

### Intentionally **kept** (do NOT rename without a build to test)
- Native core: `hiddify-core` submodule, `com.hiddify.core.*` protos, `HiddifyCoreNativeLibrary` ffigen, `*.dylib/.dll/.so`.
- **`com.hiddify.app`** — internal IPC/service namespace shared verbatim across Dart (`channelPrefix`,
  `directories_provider.dart`), Kotlin (`Action.kt`), and iOS (`SERVICE_IDENTIFIER`). Renaming inconsistently
  silently breaks IPC. It is **not** user-visible, so it does not affect branding.
- Internal Xcode target/module names: `HiddifyPacketTunnel` (iOS VPN extension target), `HiddifyNext`
  (macOS Swift module in `MainMenu.xib`/pbxproj), `HiddifyCore` framework. Renaming requires Xcode target
  surgery; not user-visible.
- Windows tunnel service name `HiddifyTunnelService` (registered by the native core).

## ⏳ Remaining — your values / optional

- **Real URLs** for `lib/core/model/constants.dart` (replace the `hoperay` placeholders): repo, releases/API,
  `appCastUrl` (desktop update feed), telegram, privacy, terms.
- **CI / store**, only if you publish from this repo: `.github/workflows/*` (`Hiddify-*` artifact names,
  `packageName`/`bundle-id` = `app.hiddify.com`), `appcast.xml`, `.vscode/launch.json`, `test.configs/README.md`,
  remaining `Hiddify-*` artifact names in `Makefile`, and store badges/links in `README.md`.
- `HISTORY.md` / `CHANGELOG.md` kept as historical record.

> ⚖️ **License note:** `LICENSE.md` (GPL-3.0 + Hiddify additions) §5 restricts publishing under a name/UI
> resembling Hiddify and requires attribution. "HopeRay" looks fine, but review §1/§3/§5 before any
> store release and keep the upstream attribution.

---

## 🎨 Image & icon replacement plan

No new artwork yet. There is **no `flutter_launcher_icons` dependency** — launcher icons are currently
committed per-platform, so each platform is regenerated/replaced independently. `flutter_native_splash`
**is** configured but its source images are **missing** (see below).

### Source artwork to produce (master assets)

| Master file | Drives | Notes |
|---|---|---|
| `assets/images/logo.svg` | iOS & macOS app icons (Xcode `*.icon` composer), in-app logo, flutter_gen | Primary vector logo — replace first |
| `assets/images/source/ic_launcher_border.png` | Android launcher source | high-res square PNG (≥512px) |
| `assets/images/source/ic_launcher_splash.png` | native splash (**MISSING — must create**) | referenced by `pubspec.yaml` `flutter_native_splash.image` |
| `assets/images/source/ic_launcher_foreground.png` | Android 12 splash (**MISSING — must create**) | referenced by `flutter_native_splash.android_12.image` |
| `assets/images/source/ic_notify.png` | Android notification icon | monochrome/transparent |
| `assets/images/source/tray_icon{,_connected,_disconnected}.png` | desktop tray icons | + dark variants |

### Regeneration steps per platform

1. **Splash (all):** add the two missing source PNGs, then `dart run flutter_native_splash:create`.
   Regenerates `android12splash.xml`, `drawable*/splash.png`, iOS `LaunchImage*`.
2. **Android launcher:** replace adaptive vector `android/app/src/main/res/drawable/ic_launcher_foreground.xml`
   + `values/ic_launcher_background.xml`, the 5-density `mipmap-*/ic_launcher*.webp` + `ic_launcher_round`,
   the `ic_banner` set, and `ic_launcher-playstore.png`. (Consider adding `flutter_launcher_icons` to
   automate this instead of hand-editing each density.)
3. **Android notification:** replace `drawable-{m,h}dpi/ic_stat_logo.png`.
4. **iOS / macOS:** update the `*.icon` bundles (`ios/Runner/AppIcon.icon/`, `macos/Runner/AppIcon.icon/`)
   — both reference `logo.svg`, so updating the SVG + opening once in Xcode regenerates them.
5. **Windows:** replace `windows/runner/resources/app_icon.ico` (referenced by `Runner.rc`).
6. **Desktop tray:** replace the `source/tray_icon*.png`, then regenerate `.ico` via
   `assets/images/convert_icon.sh` (ImageMagick).
7. **Web:** replace `web/icons/*` + `web/favicon.png`.
8. Optionally delete the unused `assets/images/source/hiddify.ico` and Norouz decoration PNGs.
