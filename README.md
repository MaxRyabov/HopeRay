<div align="center">

# HopeRay

**A cross-platform, multi-protocol proxy client.**

</div>

HopeRay is a multi-platform proxy client for **Android, iOS, Windows, macOS and Linux**,
built on the [sing-box](https://github.com/SagerNet/sing-box) universal proxy core. It is a
fork of [Hiddify](https://github.com/hiddify/hiddify-app) and remains free and open source
under the GPL-3.0 license.

> **Note:** This is a rebranded fork. Project links below are placeholders — replace them
> with your own once published. <!-- TODO(hoperay): set repo / site / support URLs -->

## ✨ Features

- ✈️ Multi-platform: Android, iOS, Windows, macOS and Linux
- ⭐ Clean, intuitive UI with dark and light modes
- 🔍 Delay-based node selection
- 🟡 Wide protocol support: VLESS, VMess, Reality, TUIC, Hysteria, WireGuard, SSH, etc.
- 🟡 Subscription/config formats: sing-box, V2Ray, Clash, Clash Meta
- 🔄 Automatic subscription updates
- 🔎 Profile info incl. remaining days and traffic usage
- 🛡 Open source and secure

## 🛠️ Build from source

This project is Flutter-based and **code-generation-heavy**. See [CLAUDE.md](./CLAUDE.md) for
the full build/codegen reference. Quick start:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # codegen
dart run slang                                              # translations
flutter run -t lib/main.dart                                # run (dev)
```

Native core libraries (the sing-box engine) are downloaded by the `*-prepare` Make targets
and are not committed to git.

## 🌎 Translations

Translations live in [`assets/translations`](./assets/translations). Edit
`en.i18n.json` (the base locale) and run `dart run slang` to regenerate.

## ✏️ Acknowledgements

HopeRay builds on the work of these projects:

- [Hiddify](https://github.com/hiddify/hiddify-app) — the upstream project this fork is based on
- [sing-box](https://github.com/SagerNet/sing-box) and its [Android](https://github.com/SagerNet/sing-box-for-android) / [Apple](https://github.com/SagerNet/sing-box-for-apple) clients
- [Clash](https://github.com/Dreamacro/clash) / [Clash Meta](https://github.com/MetaCubeX/Clash.Meta)
- [Vazirmatn Font](https://github.com/rastikerdar/vazirmatn)
- [Other dependencies](./pubspec.yaml)

## 📄 License

Distributed under the GPL-3.0 license. See [LICENSE.md](./LICENSE.md). As a fork of Hiddify,
attribution to the original project is required by the license terms.
