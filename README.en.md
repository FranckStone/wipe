<div align="center">
  <img src="Resources/AppIcon.png" width="128" height="128" alt="Wipe app icon">
  <h1>Wipe</h1>
  <p><a href="README.md">简体中文</a> · <strong>English</strong></p>
  <p><strong>Block input. Clean your keyboard and screen.</strong></p>
  <p>A native macOS menu bar utility for everyday cleaning.</p>
  <p>
    <a href="https://github.com/FranckStone/wipe/releases/latest"><img src="https://img.shields.io/github/v/release/FranckStone/wipe?label=release&amp;color=2563eb" alt="Latest release"></a>
    <img src="https://img.shields.io/badge/macOS-13.0%2B-111827" alt="macOS 13.0 or later">
    <img src="https://img.shields.io/badge/Apple_Silicon-arm64-111827" alt="Apple Silicon arm64">
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-16a34a" alt="MIT license"></a>
  </p>
  <p>
    <a href="https://github.com/FranckStone/wipe/releases/latest"><strong>Download Wipe</strong></a> ·
    <a href="#how-to-use">How to use</a> ·
    <a href="#build-from-source">Build from source</a> ·
    <a href="CHANGELOG.md">Changelog (Chinese)</a> ·
    <a href="https://github.com/FranckStone/wipe/issues">Report an issue</a>
  </p>
</div>

---

Keep stray keystrokes out of your documents while wiping your keyboard, and avoid accidental clicks or trackpad gestures while cleaning your screen. Open Wipe, choose a cleaning mode, and hold to unlock when you are done.

Wipe is built with **SwiftUI + AppKit**, has no third-party package dependencies, and processes input locally. No account is required.

## Screenshots

<table>
  <tr>
    <th>Main window</th>
    <th>Keyboard cleaning mode</th>
  </tr>
  <tr>
    <td valign="top"><img src="docs/screenshots/main-window.jpg" width="460" alt="Actual Wipe main window with keyboard and screen cleaning options"></td>
    <td valign="top"><img src="docs/screenshots/keyboard-cleaning.jpg" width="420" alt="Actual Wipe keyboard cleaning panel with a blocked-key counter and hold-to-unlock control"></td>
  </tr>
</table>

These screenshots show the app running on macOS. **The app interface is currently in Chinese**; this document provides English instructions, with the original button labels where helpful.

## Choose a cleaning mode

| | Keyboard cleaning | Screen cleaning |
| :--- | :--- | :--- |
| Best for | Wiping keycaps and the keyboard surface | Wiping the screen, or cleaning the keyboard and trackpad together |
| Keyboard and media keys | Blocked | Blocked |
| Mouse and trackpad | Remain available so you can unlock | Clicks, movement, scrolling, and trackpad gestures are blocked |
| On-screen display | Floating unlock panel with a blocked-key counter | Black or white fullscreen overlays on all displays |
| How to exit | Hold the unlock control with your mouse or trackpad for **1.5 seconds** | Hold **Esc for 1.5 seconds**, or wait for the **120-second** automatic unlock |

- **Available in the menu bar**: close the main window and still start cleaning, reopen the window, or quit from the menu bar.
- **Black and white backgrounds**: press Space in screen mode to switch backgrounds and make smudges easier to see.
- **Hold to unlock**: a progress ring shows the hold gesture, reducing accidental exits while cleaning.

> The power button and Touch ID cannot be blocked. Avoid them while cleaning. Cleaning mode prevents accidental input; it does not provide authentication or a secure system lock.

## Download and install

**Requirements: macOS 13.0 or later. Current prebuilt downloads are for Apple Silicon (arm64).**

Visit the [latest release](https://github.com/FranckStone/wipe/releases/latest), or download v1.0.1 directly:

| File | Purpose |
| :--- | :--- |
| [Wipe-1.0.1-arm64.dmg](https://github.com/FranckStone/wipe/releases/download/v1.0.1/Wipe-1.0.1-arm64.dmg) | Recommended. Open it and drag Wipe into Applications |
| [Wipe-1.0.1-arm64.zip](https://github.com/FranckStone/wipe/releases/download/v1.0.1/Wipe-1.0.1-arm64.zip) | Extract it and move `Wipe.app` into Applications |
| [SHA256SUMS.txt](https://github.com/FranckStone/wipe/releases/download/v1.0.1/SHA256SUMS.txt) | Verify the downloaded files |

### First launch

1. Move Wipe into Applications, then open it.
2. In the main window, click “Request permission” (`请求权限`) or “Open System Settings” (`打开系统设置`).
3. Open **System Settings → Privacy & Security → Accessibility** and enable Wipe. If it is missing from the list, add `/Applications/Wipe.app` manually.
4. Return to Wipe and wait for the cleaning mode buttons to become available.

**About the macOS launch warning:** current downloads use ad-hoc signing and have not been notarized by Apple. If macOS cannot verify the developer, confirm the download came from this repository, attempt to open the app, then go to **System Settings → Privacy & Security → Open Anyway**. See [Apple's instructions](https://support.apple.com/en-us/102445) for details.

### Verify your download

Download `SHA256SUMS.txt` and both installation files into the same directory, then run this command there:

```sh
shasum -a 256 -c SHA256SUMS.txt
```

Both files should report `OK`. If you downloaded only one installation file, run `shasum -a 256 <filename>` and compare its hash with the corresponding entry in the checksum file.

## How to use

### Clean your keyboard

1. Choose “Clean keyboard” (`清洁键盘`) in the main window or menu bar.
2. Start cleaning once the panel says “Keyboard locked” (`键盘已锁定`). The panel counts blocked keystrokes.
3. When finished, use your mouse or trackpad to **hold the lock control for 1.5 seconds**, until the progress ring completes.

The mouse and trackpad stay active in keyboard mode. **There is no automatic unlock timer in this mode.** Esc is also blocked, so use the on-screen control to unlock.

### Clean your screen

1. Choose “Clean screen” (`清洁屏幕`) in the main window or menu bar.
2. Black overlays cover all displays, the pointer disappears, and keyboard, mouse, and trackpad input is blocked.
3. Press **Space** to switch to a white background. Press it again to return to black.
4. **Hold Esc continuously for 1.5 seconds** to exit. Releasing it early cancels the unlock gesture. The app also unlocks automatically after **120 seconds**.

Instructions fade out after about 3 seconds, while the automatic unlock countdown remains at the bottom. The black background is an app overlay; the display stays on.

## Permissions and privacy

Wipe needs **Accessibility** permission to intercept global input through macOS `CGEventTap` during cleaning. It stops intercepting input when you leave the cleaning mode.

- **No keystroke content is saved**: keyboard mode only counts blocked presses in memory. The counter resets each time cleaning starts.
- **No input data is uploaded**: the current app contains no network request, telemetry, or analytics service code.
- **No registration or login**: there are no accounts, cloud synchronization, or background automatic updates.

You can inspect the implementation in [InputBlocker.swift](Sources/Wipe/InputBlocker.swift) and [CleanController.swift](Sources/Wipe/CleanController.swift).

## FAQ

### Why are the cleaning buttons disabled?

Check that Wipe is enabled in **System Settings → Privacy & Security → Accessibility**, then return to the app. If the buttons remain disabled, quit and reopen Wipe, then check its permission again.

### Why did permission stop working after an update or rebuild?

Replacing the app or changing its signature may require granting permission again. Quit Wipe, remove its old Accessibility entry, and add the updated copy from Applications. For local builds, you can also use your own consistent signing certificate.

### How do I reopen the main window?

Click Wipe's menu bar icon and choose “Open Wipe window” (`打开 Wipe 窗口`). To exit the app completely, choose “Quit Wipe” (`退出 Wipe`).

### Are Intel Macs supported?

Published and verified downloads currently target Apple Silicon only. The build script accepts `ARCH=x86_64`, but no installation package verified on Intel hardware is available yet.

### Does screen mode turn off the display or replace the system lock screen?

Screen mode displays fullscreen overlays and blocks input. It keeps the display on and does not enable macOS authentication. Use the system lock screen when you need to protect access while away from your Mac.

## Build from source

You need macOS, **Swift 5.9 or later**, and Xcode or Xcode Command Line Tools. The project uses Swift Package Manager and requires no third-party packages.

```sh
git clone https://github.com/FranckStone/wipe.git
cd wipe
./build.sh
open build/Wipe.app
```

The app is generated at `build/Wipe.app`. By default, the script builds for the host architecture and uses ad-hoc signing, so no developer certificate is required.

To build, install, and launch in one step:

```sh
./build.sh --install
```

This command stops any running Wipe process and **replaces `/Applications/Wipe.app`**.

### Build options

| Setting | Default | Description |
| :--- | :--- | :--- |
| `VERSION` file | Current repository version | App version in `x.y.z` format |
| `BUILD_NUMBER` | `2` | Internal build number; override with an environment variable |
| `ARCH` | Host architecture | Accepts `arm64` or `x86_64` |
| `SIGN_IDENTITY` | `-` | Ad-hoc signing; set it to the name or identifier of a local code-signing certificate |

For example, choose an architecture, build number, and your own signing certificate:

```sh
ARCH=arm64 BUILD_NUMBER=3 SIGN_IDENTITY="Your code-signing certificate name" ./build.sh
```

### Project structure

```text
Sources/Wipe/
├── WipeApp.swift          # App entry point, menu bar, and shutdown cleanup
├── Views.swift            # Main window, unlock panel, and screen overlays
├── CleanController.swift  # Modes, permissions, countdown, and exit handling
└── InputBlocker.swift     # Global input event interception
Resources/                 # App icons
scripts/
├── make_icon.swift        # Icon generation
└── package_release.sh     # DMG, ZIP, and SHA-256 packaging
build.sh                   # Build, sign, and optionally install
VERSION                    # App version
```

### Package installation files

```sh
./scripts/package_release.sh
```

The script builds the app, verifies its signature, and writes these files to `build/release/`:

```text
Wipe-<version>-<architecture>.dmg
Wipe-<version>-<architecture>.zip
SHA256SUMS.txt
```

The DMG includes the app, an Applications shortcut, and the license. The app inside the ZIP also includes the license. The script generates and checks SHA-256 hashes; **it does not notarize the app or upload a GitHub Release**.

## Feedback and contributions

[Issues](https://github.com/FranckStone/wipe/issues) and [pull requests](https://github.com/FranckStone/wipe/pulls) are welcome.

For bug reports, include your macOS version, chip architecture, Wipe version, cleaning mode, and steps to reproduce. For permission problems, also include the app's Accessibility permission status.

After changing input interception or exit handling, verify keyboard unlocking, the Esc hold gesture, the 120-second automatic unlock, and input restoration when quitting on a Mac with Accessibility permission enabled. For multi-display changes, check overlays on every display as well.

## License

Wipe's source code and the icons in this repository are available under the [MIT License](LICENSE). You may use, modify, and distribute them while retaining the license and copyright notice.
