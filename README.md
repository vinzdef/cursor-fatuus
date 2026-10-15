<p align="center">
  <img src="Design/AppIcon1024.png" width="160" alt="Cursor Fatuus icon">
</p>

<h1 align="center">Cursor Fatuus</h1>

<p align="center">
  A foolish fire for your cursor.<br>
  A soft glow that follows your mouse pointer on macOS, so you never lose it on a busy screen.
</p>

<p align="center">
  <a href="https://cursor-fatuus.vincent.codes">Website</a> ·
  <a href="https://github.com/vinzdef/cursor-fatuus/releases/latest/download/CursorFatuus.dmg">Download</a> ·
  <a href="https://vincent.codes/donate">Donate</a>
</p>

## Features

- Follows the pointer across every display and Space, including full-screen apps. Clicks pass straight through.
- **Color** and **opacity**: any tint, or none.
- **Blur** and **invert** what's under the pointer.
- **Radius** and **softness**: from a crisp disc to a single gentle haze.
- No permissions: it never records or reads your screen.
- Lives in the menu bar. No Dock icon, no windows.

## Install

1. Download the DMG from the [latest release](https://github.com/vinzdef/cursor-fatuus/releases/latest).
2. Drag **Cursor Fatuus** to Applications and open it.
3. The app isn't notarized, so macOS blocks the first launch. Open **System Settings → Privacy & Security** and choose **Open Anyway**.

Requires macOS 14 Sonoma or later.

## Release

Push a version tag and GitHub Actions builds a universal DMG and publishes the release:

```sh
git tag v0.1.0
git push origin v0.1.0
```

`make dmg` builds the same DMG locally.

## Build from source

```sh
make run
```

Needs Xcode or the Xcode Command Line Tools. The app is built to `build/Cursor Fatuus.app`.

Blur and invert use undocumented macOS APIs (`CABackdropLayer`), so a future macOS update may break them.

## Support

If Cursor Fatuus helps you, consider [donating](https://vincent.codes/donate).
