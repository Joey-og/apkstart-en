# ApkStart

<p align="center"><img src="docs/images/logo.png" alt="ApkStart Logo" width="160" /></p>

[![CI](https://github.com/RoutineMiku/apkstart/actions/workflows/ci.yml/badge.svg)](https://github.com/RoutineMiku/apkstart/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/RoutineMiku/apkstart?include_prereleases&sort=semver)](https://github.com/RoutineMiku/apkstart/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11%20x64-0078D6.svg)](#)

**An Android app runner for Windows: Android apps are installed and used just like native Windows software.**
Note: This project is an early version, a hobby project the author works on after work and on days off. It is open source and free, has no ads, is admittedly not very polished yet, and has never been promoted through marketing accounts.

> **About this fork:** The Windows app UI in this fork has been translated from Simplified Chinese to English, so the program itself runs in English. The translation covers only user-facing text; code, commands, and technical identifiers are unchanged.

- 🖱️ **Double-click a .apk to install it**: Once the .apk file association is registered, double-click an APK in Explorer and it is automatically parsed, installed, and given a desktop icon, all without opening any emulator interface.
- 🧩 **One desktop icon per app**: Icons are extracted offline from inside the APK and converted to multi-size ICO files. Double-clicking the desktop icon launches that app directly, exactly like opening native Windows software.
- 🪟 **An app is a window**: The runtime starts in **windowed** mode (in headless mode Android produces no VSYNC, so the app process is alive but the screen is empty). ApkStart retitles that window, gives it the real app icon, and positions it at a portrait aspect ratio, making it a standalone app window. **Fullscreen** fills the screen height and centers the app, while **window mode** can be dragged and resized freely and remembers each app's size.
- 🔍 **Searchable in Windows**: Installation creates both a desktop shortcut and a Start menu shortcut (`Programs\ApkStart\`), so you can search by app name in the Start menu to go straight to it, and the taskbar groups windows by app.
- 📁 **Shared data**: `%USERPROFILE%\ApkStartShared` and `/sdcard/ApkStartShared` inside Android stay in continuous two-way sync, so files saved by Android apps appear directly on your machine.
- 🪶 **Extremely lightweight**: The shell itself has zero third-party dependencies (even the ZIP / PNG / ICO / AXML parsers are hand-written). The runtime is started on demand and reclaimed automatically when idle. You can also reuse an Android runtime already on your machine, for zero extra footprint.

![Main window](docs/images/app.png)

```
┌────────────────────────────────────────────────────────────┐
│  Desktop icon (real app icon, .lnk)                        │
│      │  Double-click                                       │
│      ▼                                                     │
│  ApkStart.exe --launch <package name>                      │
│      │  Runtime not running? It starts automatically       │
│      │  (Android Emulator + API 34)                        │
│      ▼                                                     │
│  Starts via the LAUNCHER entry resolved by the system      │
│  (not the main Activity inside the APK)                    │
│      │  Watched for 18 seconds; on crash it retries,       │
│      │  resets data, or fills in permissions               │
│      ▼                                                     │
│  Emulator window = app window (retitled, real icon,        │
│  portrait ratio, centered in fullscreen)                   │
└────────────────────────────────────────────────────────────┘
```

## Download and use (no building required)

Both sources carry identical content. Gitee is recommended inside China:

- GitHub: [github.com/RoutineMiku/apkstart/releases](https://github.com/RoutineMiku/apkstart/releases)
- Gitee: [gitee.com/daily-miku/apkstart/releases](https://gitee.com/daily-miku/apkstart/releases) (much faster with a direct connection inside China)

Install packages (three forms, identical content and version numbers):

| Form | File name | When to choose it |
|---|---|---|
| Store edition | `ApkStart_<four-part version>_x64.msix` | Install from the Microsoft Store. Includes the full runtime, works offline after installation; updates are handled by the Store |
| Full portable edition | `ApkStart-v*-win64-full.zip` (about 830 MB, about 1.3 GB extracted) | **No installation and no waiting for downloads**: extract and use. The runtime (emulator + system image) is all in the package |
| Installer edition | `ApkStart-v*-Setup.exe` (about 1.3 GB) | You want desktop/Start menu shortcuts and an uninstall entry |
| Lightweight portable edition | `ApkStart-v*-win64-portable.zip` (96 MiB, about 227 MB extracted) | You just want to try it first; the runtime downloads online on first launch |

> In every form, `ApkStart.exe` carries a **brand icon and version resources** (FileDescription = `ApkStart Android App Runner`,
> CompanyName = `RoutineMiku`, version kept in sync with `package.json`), instead of Electron's default icon and `33.x` version number.
> When packaging from source yourself: `npm run pack` (lightweight) / `npm run pack:full` (full) / `npm run build:msix` (Store package).

### How the picture fills the window

The emulator's **physical panel orientation** (`hw.lcd.width/height`) is the real shape of the picture. When the panel orientation
does not match the `screenOrientation` the app declares for itself, Android gives the app only a narrow letterboxed strip in the middle,
with black bars on both sides. Resizing the window, changing `wm size`, or restyling the letterbox cannot fill it
(this combination was tested item by item; see the comments in `src/core/apk.js`).

So ApkStart **parses `AndroidManifest.xml` offline when installing an APK** and works out whether the app is naturally landscape or portrait
(the launch Activity is weighted; apps that are all `sensor` / `fullSensor` are asked for their actual value from Android once after their first run), stores the result in
`apps.json`, and picks the panel accordingly at launch:

- Portrait apps such as Hongguo short dramas get a portrait panel, 720x1280, upright and filling the window, with density 190 (sw606dp) giving a tablet layout at the same time;
- Landscape apps such as Modu get a landscape panel, 1280x720, upright and filling the window.

The runtime restarts only on the one occasion when "panel orientation and app orientation disagree" (about 40 seconds, and the title bar shows a hint).
After that, apps with the same orientation open in seconds. The rotate button in the title bar **remembers** the orientation for that app (other apps are unaffected),
and Settings, App window, Screen orientation can be set to "Force landscape / Force portrait".

The layout is decided by "logical density": a width of 720 at 190 dpi equals **606dp**, just over Android's 600dp tablet breakpoint.
Hongguo's two-column episode page and split settings page only appear at this density (the image's default 320 dpi gives only 360dp, a phone layout).
This is the "Tablet layout" switch in Settings, on by default; turning it off returns to the phone layout.

### Online updates (automatically picks the faster source)

Settings, **Software update**, "Check for updates", or right-click the tray icon and choose "Check for updates". When a new version is found, click "Update now".

- The installer edition downloads `ApkStart-v*-Setup.exe` and installs it silently;
- The lightweight edition downloads `ApkStart-v*-win64-portable.zip`, extracts it, and overwrites the **program directory**. The runtime directory (`%APPDATA%\apkstart\runtime`), installed apps, and snapshots are not in the program directory, so an update loses nothing;
- The replacement is done by a standalone PowerShell script (wait for the main process to exit, overwrite, relaunch). There is **no "please close the program manually" dialog**, and no emulator window is left behind on the desktop.

The update path does not hard-connect to GitHub. Instead it **tests and chooses on the spot every time**:

1. It asks both GitHub and Gitee for the latest version and takes the higher version number (one source timing out or being blocked does not affect the other);
2. It lists "direct source connection / same-named Gitee asset / mirror prefix" as candidates and really downloads 256 KB from each address to measure speed,
   counting only the throughput **after the first byte arrives** (handshake time is excluded, otherwise a high-latency, high-bandwidth source would be misjudged as slow);
3. It sorts by measured speed and downloads in parallel chunks over the fastest route, automatically switching to the next one on failure.

"Download and update sources" in Settings can force one side only (for corporate networks that allow a single domain),
can turn off the public acceleration mirrors, or can use a custom mirror prefix. Gitee attachments have a 100 MB single-file limit.
The portable package, compressed with 7-Zip deflate (`-mx=9`), is **95.0 MB**, so Gitee also carries
a single whole package you can extract by double-clicking (the older version that had to be split into `.part1/.part2` and joined by hand has been retired).
Same-named packages on the two sources are not exactly the same size. The client picks one source by speed test and downloads it whole; it never mixes pieces.

Both repositories are public, and Gitee's release list can be read anonymously, so no token is needed.
(Only when Gitee rate limiting returns 403/429 do you need to fill in a read-only token in Settings to raise the quota.)


**Default behavior out of the box** (no need to hunt through Settings):

- Starts automatically at boot and stays in the tray; double-click a desktop icon to go straight into the app.
- After installing an APK, it automatically creates both **desktop and Start menu** shortcuts, and Windows Search can find the app name directly; shortcuts an old version missed are filled in automatically at startup.
- App windows are rendered natively (not screen casting): **fullscreen** fills the screen height, centered, keeping the phone aspect ratio without distortion; **window mode** keeps portrait, can be dragged and resized freely, and remembers each app's size separately. Press `F11` or right-click the tray at any time to switch.
- After installation, the runtime permissions the app requested are granted automatically, so you never get stuck on a system permission prompt; if an app crashes, it retries automatically and, when necessary, resets the app data and relaunches.
- **The network uses the host's network directly**: the Android side goes through QEMU user-mode NAT and its traffic reuses the host's physical network card. **No virtual network adapter or virtual switch is created on Windows** (no driver to install, no extra network adapter). No downloads are needed to get online, and no network settings need changing.

## The Settings page: categorized, and searchable

The number of settings keeps growing, so since 0.6.0 the Settings page is divided by purpose into eight categories, with a navigation column on the left:

| Category | What it contains |
|---|---|
| General and installation | Runtime and environment, one-click completion, start at boot, disk usage and cleanup |
| Display and windows | Display mode, automatic fullscreen, screen orientation, automatic image rotation, tablet layout, window hosting method, Android system settings |
| Controls and input | Mouse keys, keyboard mapping (game controller) |
| Performance and resources | Resource policy, graphics quality, data partition, system language, Chinese input method, snapshots, prewarm at boot, advanced parameters |
| Network and downloads | Update and download sources, public acceleration mirrors, download thread count |
| Diagnostics and repair | Machine health check and automatic configuration, drivers and compatibility patches, auto detection and smart diagnostics |
| Integration and files | Desktop and apps, file sharing, system integration |
| Updates and about | Software update, About |

There is also a search box at the top: type keywords such as "landscape", "memory", or "proxy" and matching items are shown **across categories**,
so you never get "found it but cannot see it". The category you last visited is remembered, and the page opens where you left it next time.

## Auto detection (automatic debugging)

Settings, **Diagnostics and repair**, "Auto detection, smart diagnostics". It inspects the machine in the background on a schedule and lists problems by category:

- **Runtime**: the real cause of the last startup failure, a stuck boot, leftover lock files, orphan emulator processes, empty snapshot shells, no hardware acceleration
- **Device connection**: adb unauthorized (Android asked "Allow USB debugging?" and nobody tapped it), offline, the runtime is running but adb cannot see the device
- **Storage**: free disk space, a data partition configuration value that disagrees with the actual value (a differencing disk blocking expansion), a shared folder that is not writable
- **Settings**: a screen orientation policy fighting the physical panel, automatic fullscreen not taking effect under standalone windows
- **Network / logs**: no network on the Android side, download sources unreachable, errors in the recent logs

Every problem can be handled in one click (restart the runtime, clear locks, clear orphan processes, discard snapshots, clean the disk, reset the Android network, and so on).
It re-checks automatically after a repair.

Two principles: **a failed probe is never treated as a problem** (if a status cannot be obtained it reports "unknown" and never raises a false alarm),
and **you are reminded only once when a new problem appears** (old problems do not nag repeatedly, and a recovery is recorded silently).
It runs every 10 minutes by default, and you can turn it off or change the interval on the same page.

## Building from source

```powershell
# 1. Install dependencies (including the Electron runtime)
npm install

# 2. Start and complete the runtime deployment (one-time download of adb / Android Emulator / system image)
npm start

# 3. (Optional) Register double-click installation for .apk
npm run assoc:on

# 4. Package the portable edition (no installation, ready to distribute)
npm run pack
# Output: dist/ApkStart-win64-portable/ApkStart.exe
# 5. Compress it into a zip for release (you must use this script, not Compress-Archive: the result is 5 MB bigger and will not fit on Gitee)
node build/zip.js dist/ApkStart-win64-portable ApkStart-win64-portable.zip
```

### Single-file EXE (full runtime built in, no network needed after installation)

If you want "send out one EXE, the other person double-clicks it and it runs, with no waiting for downloads", use this:

```powershell
# First prepare engine/ as a distributable runtime (system.img with xz/LZMA2 maximum compression, 3.1 GB down to about 1.1 GB;
# this also trims parts of the emulator that are not needed: the arm64 QEMU, Vulkan backends, multilingual packs, qsn/self-test tools, VR resources)
npm run runtime

# Then build the installer EXE (electron-builder nsis target, installs into the current user's directory)
npm run build:exe
# Output: dist/release/ApkStart-<version>-Setup.exe
```

Size breakdown (measured): Electron about 180 MB, the emulator after slimming about 480 MB, the system image after xz compression about 1.1 GB,
giving a final installer of about 1.32 GB (about 490 MB saved compared with the gzip approach). The hard floor for further compression is system.img
(it is the Android system itself, and a verity-protected image, so GMS components cannot be trimmed from outside).
The network uses host NAT by default and creates no virtual network adapter, so it does not depend on any extra driver either.

On first launch, the xz image is expanded into `%APPDATA%\apkstart\system-images` (about 20 seconds, done only once),
and the expanded copy is reused directly after that. The AVD and installed apps are always stored in `%APPDATA%\apkstart\avd`,
so nothing is lost even if the portable edition is extracted to a temporary directory each time.

## The runtime: fully standalone, no dependency on any third-party emulator

ApkStart is a **self-contained** project. All runtime components are downloaded, verified, and managed by ApkStart itself (located in `%APPDATA%\apkstart\runtime`).
The lightweight edition downloads the whole package by default from **this project's GitHub Release** (`ApkStart-runtime-*.zip`), and only falls back to the official sources in the table below if that fails:

| Component | Source | Size | Purpose |
|---|---|---|---|
| adb (platform-tools) | Official dl.google.com source | ~8 MB | Installing and launching Android apps |
| Android Emulator | Official dl.google.com source (8-thread parallel download) | ~440 MB | The runtime engine (with its own device models and GPU translation) |
| Android 14 generic system image (Google Play x86_64) | Official dl.google.com source | Source image ~3.1 GB (about 1.1 GB after xz) | The only base layer: x86 apps, apps with ARM-only libraries, and GMS all run; the image is the system, nothing to install |
| AEHD driver (optional) | Official dl.google.com source | ~0.2 MB | Hardware acceleration (or use the Windows "Virtual Machine Platform" WHPX) |

On first use, the "Runtime" page guides you through this deployment (**one-click deployment**):
1. adb, the runtime engine, and the system image download automatically (the official source measures at 10+ MB/s);
2. After deployment it **boots automatically**, and after that double-clicking a desktop icon starts everything automatically, with nothing to notice.

![Runtime deployment wizard](docs/images/setup.png)

**Device compatibility (handled automatically, no intervention needed)**

- Without hardware acceleration it falls back to software emulation automatically; a failed startup retries with up to 4 sets of parameters, in the order "rendering backend, acceleration method, memory/cold boot".
- `-gpu` is chosen automatically by engine version (37.x uses `software`, older versions use `swiftshader_indirect`); deprecated modes are no longer used.
- Memory and core counts are derived automatically from physical memory (2-4 GB / 2-4 cores), the data partition is reduced from 16 GB to 4 GB; ports are picked dynamically from free ones, Chinese paths are converted to short paths automatically, and AVD lock files are cleaned up automatically.
- Failure causes are translated into plain language with repair suggestions; you can "Export a diagnostic report" in Settings.
- Large file downloads use **8-thread chunking with resume** by default, and sources that do not support Range fall back to a single stream automatically.
- **Only its own runtime is used, unrelated to other emulators**: ApkStart does not detect, take over, or drive MuMu / LDPlayer / BlueStacks / WSA installed on your machine;
  whether they are installed, how they upgrade, and how their ports change has no effect on ApkStart. Settings no longer offers an option to "switch engine" either.
- **Machine health check and automatic configuration**: after installation it first checks CPU virtualization (VT-x/SVM), the Windows hypervisor platform,
  the graphics card and video memory, memory, and the system version. What can be changed automatically (memory / cores / graphics quality / rendering backend) is written straight into Settings and fixed as a driver.
  Things that need administrator rights get a button, and things that can only be changed in the BIOS come with instructions. See [docs/preflight.md](docs/preflight.md).
- **Driver (compatibility patch) extensions**: if a machine only runs with changed startup parameters (an old graphics card with a low GLES version, no hardware acceleration,
  a driver version that crashes as soon as hardware rendering is on), you can write a JSON patch declaring which machines it matches and which parameters it changes on a match.
  The Settings page can import and enable patches and export a template for this machine; a patch only changes allow-listed startup items and executes no code. See [docs/drivers.md](docs/drivers.md).

**Container-style low-cost running**

- **Read-only base layer**: one copy of `system-images/` for the whole machine, shared by all apps, instead of storing AOSP and compatibility image sets side by side.
- **Thin writable layer**: a single AVD uses differencing user data plus named quickboot snapshots; after the last app window closes (when idle), the memory state is stored as a snapshot, so the next boot resumes instead of cold booting.
- **Idle prewarm (on by default)**: like WSA and the Tencent App Store PC edition, ApkStart guides the Android environment up in the background as soon as it starts (the window stays hidden the whole time), so opening an app is reduced to a single `am start`. The cost is about 1 GB of memory resident while idle, and it can be turned off in Settings.
- **Faster cold starts**: acceleration and engine version probe results are cached on disk (invalidated by the exe fingerprint), pointless `wmic` process enumeration is skipped, boot probing uses an adaptive interval (starting at 350 ms), and guest-side preparation commands are merged into one adb round trip; one startup waits 5-10 seconds less.
- **`/data` is made by ApkStart itself**: the `userdata.img` in the official system image is only a 1 MB all-zero placeholder, and the real formatting was originally done by SDK tools. Starting `emulator.exe` directly skips that step, so `/data` cannot mount, the guest falls into a recovery reboot loop, and it looks like "waiting for minutes and it still will not open". Now the first launch generates its own ext4 with 4 KB blocks, `ENCRYPT` (file-level encryption), and `ext_attr` (SELinux labels), and expands it to the configured capacity with the bundled `qemu-img` and `resize2fs`. Measured cold start is about 23 seconds, and about 10 seconds when a snapshot is hit.
- Snapshot integrity checking: empty shells left by an interrupted save (a `snapshot.pb` of only a few dozen bytes) are recognized and cleaned up; the new emulator writes `ram.bin` (older versions wrote `ram.img`), and both names are recognized, so a freshly saved 3 GB snapshot is never again misjudged as an empty shell and deleted.
- **Command windows never appear**: QEMU's console window belongs to `conhost.exe`, whose pid does not match QEMU's, so a pid allowlist cannot hide any of them; the emulator's network daemon `netsimd` also pops up its own black window. The approach is now "open standing suppression **before** starting the emulator, plus fallback matching by window class name/title (emulator / qemu / netsim), plus a scan every 120 ms for the first 90 seconds of boot".
- **Opening software shows only the software's interface**: the emulator main window (`Android Emulator - apkstart5554`) never appears on the desktop on its own. It is either suppressed and hidden, or already embedded into the app window with `SetParent`. When you close an app window, it is **first** detached from the host window and hidden, and **then** the host is destroyed (in the reverse order Windows would reattach it to the desktop and show it); after an app exits, the window agent keeps "guarding" for up to 3 minutes, so an emulator that exits mid-boot does not flash a black window tens of seconds later.
- **On-demand downloads**: the generic image is only completed when an app with ARM-only native libraries is encountered; `.apks` / `.xapk` split packages are installed automatically with `install-multiple`.
- **Reclaimable**: non-x86_64 QEMU targets are trimmed at build time (about 400 MB); the Settings page can clean up old images, old snapshots, lock files, and leftover AVDs.

## Directory structure

```
apkstart/
├─ src/
│  ├─ main.js              Main process: windows/tray/single instance/command line dispatch/IPC
│  ├─ preload.js           Secure bridge
│  ├─ ui/                  Renderer layer (native HTML/CSS/JS, no framework)
│  └─ core/
│     ├─ zip.js            Minimal ZIP reader (extracts on demand)
│     ├─ axml.js           Android binary XML parsing
│     ├─ arsc.js           resources.arsc resource table parsing (restores app names/icon paths)
│     ├─ apk.js            APK metadata: package name/version/launch Activity/icon/ABI
│     ├─ png.js            Zero-dependency PNG encoder + program icon drawing
│     ├─ shortcut.js       Multi-size ICO generation + .lnk shortcuts
│     ├─ assoc.js          .apk file association (HKCU, no administrator needed)
│     ├─ adb.js            adb client (install/launch/sync/screenshot/...)
│     ├─ engine.js         Runtime management: probing/emulator hosting/idle reclamation
│     ├─ sharer.js         Host and Android shared folder two-way sync
│     ├─ installer.js      Installation pipeline orchestration
│     └─ store.js          App list and settings persistence
├─ engine/                 Runtime component download cache (emulator / system-images / platform-tools)
├─ tools/platform-tools/   Where the portable adb goes
├─ test/                   Unit tests + Electron integration tests + smoke screenshots
├─ build/pack.js           Portable edition packaging
└─ scripts/assoc.js        .apk association command line switch
```

## Command line

```
ApkStart.exe                      Open the main window
ApkStart.exe <path\to.apk>        Install an APK
ApkStart.exe --launch <pkg name>  Launch an app directly (desktop shortcuts use this argument)
```

## Tests

```powershell
npm test                                   # Pure Node unit tests + engine chain tests (no network needed)
npm run test:boot                          # Real boot test: verifies QEMU parameters/disk creation/graceful shutdown with a 61 MB Alpine guest
npm run selftest                           # Runtime self-test: with Android installed, verifies install, launch, screenshot, shared folder in one go
electron test/electron-integration.js      # ICO / shortcut integration test
electron . --smoke test\shot.png           # Launch the app and take a screenshot (UI smoke test)
```

`npm run selftest` is the "acceptance command" after the system is installed. It checks the current device in order: the adb connection,
the Android version, freeform support, and two-way sync of the shared folder. Adding `--apk some-app.apk` also runs the full
install, standalone window launch, foreground confirmation, and screenshot flow.

## Design trade-offs (honest notes)

- **Not a hypervisor built from scratch**: an Android kernel, GPU translation, and the ART runtime are multi-year projects. This project chooses to stand on the shoulders of AOSP/QEMU/adb and concentrate its effort on the "native app-level experience", which is the same architectural approach shared by products such as the Tencent App Store PC edition and Google Play Games on PC.
- **The shared folder is sync, not a mount**: without root on Windows there is no way to mount an NTFS directory on the Android side, so second-level two-way sync is used to reach the same experience.
- **ARM-only apps / ByteDance apps**: turning on "ARM compatibility mode" in Settings switches to the **Android 14 (API 34) Google Play image** (with the new ndk_translation translation layer built in), so apps with ARM-only native libraries can be installed and run. **Hongguo Free Short Dramas (com.phoenix.read, arm64-v8a-only) was tested and installs normally, reaches the recommendation feed, and plays video**. On the old API 30 image, ByteDance's own non-standard signal handler triggers a protective assertion in the translation layer (`DoBadTrampoline` SIGABRT); the new translation layer in the Android 14 image has fixed this. A few apps carry deeper anti-emulator detection of their own (such as forcibly verifying real sensors or a baseband) and may still be limited; when an installation fails or a launch crashes, ApkStart explains why in plain language.

| Hongguo Free Short Dramas running in ApkStart compatibility mode (Android 14, AEHD hardware acceleration) |
|:---:|
| ![Hongguo short dramas running in ApkStart compatibility mode](docs/images/compat-hongguo-playing.png) |

### What to do about the "hardware acceleration is not enabled" hint

An Android emulator on Windows has only two acceleration routes:

| Method | What it is | Who needs an administrator | Restart needed after installing |
|---|---|---|---|
| **WHPX** | The built-in Windows feature "Windows Hypervisor Platform" | When enabling the feature | Yes |
| **AEHD** | Google's own kernel driver | When installing the driver | No |

- **Installer / portable editions**: Settings, Environment check, click **Repair** on the right of "Hardware acceleration is not enabled". One UAC prompt appears and WHPX is enabled automatically; if that cannot be done (the system does not support it, or you clicked No), it automatically installs the AEHD driver instead.
- **Microsoft Store (MSIX) edition**: Store apps **cannot elevate themselves**, so clicking "Repair" opens the "Turn Windows features on or off" dialog for you. Tick
  **"Windows Hypervisor Platform"** (HypervisorPlatform in English), confirm, and **restart the computer** once.

  You can also run this yourself in an administrator PowerShell:

  ```powershell
  dism /online /enable-feature /featurename:HypervisorPlatform /all /norestart
  dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
  ```

> Note: do not enable only "Virtual Machine Platform (VirtualMachinePlatform)". That is what WSL2 uses; the emulator needs
> **"Windows Hypervisor Platform (HypervisorPlatform)"**. With only the former enabled, `emulator -accel-check` will still say it is unavailable.
>
> It also runs without acceleration (pure software emulation), it just takes minutes to boot. That is the point of the hint in the app,
> not a startup failure.

### What to do if a desktop icon is wrong or shows the ApkStart icon

Every Android app's desktop shortcut should use **its own icon** (extracted from the APK at installation time and stored in
`%APPDATA%\apkstart\icons\<package name>.ico`). If it shows ApkStart's green play button, or a blank icon:

1. **Settings, System integration, Rebuild shortcuts** (this rewrites the desktop and Start menu shortcuts from the current app list,
   fixing the icons and taskbar identity along with them);
2. If that does not fix it, delete the shortcut, then right-click the app in ApkStart and choose recreate shortcut / reinstall it once.

> Why it breaks: early versions, when tidying icons, pointed the `IconLocation` of these `.lnk` icons uniformly at ApkStart's brand image;
> also, after moving the whole portable directory somewhere else, the absolute paths recorded in the `.lnk` files become invalid. One rebuild fixes it.
>
> One more note: every app's shortcut carries its own AppUserModelID,
> so after **pinning to the taskbar**, the taskbar button and the pinned item use the same app icon and do not collapse into ApkStart.

### Why `adb devices` cannot see this Android device

ApkStart's adb service runs on **dedicated port 5044**, completely separated from your own adb on the system (5037), so your Android Studio / scrcpy does not fight it for devices, and it does not kill an emulator you started by hand.

To connect to it from the command line:

```powershell
$env:ANDROID_ADB_SERVER_PORT = 5044
adb devices              # You will see emulator-5554
```

⚠️ Do **not** manually `adb connect` to port `5555`: the Play edition system image pops up the "Allow USB debugging?" system dialog, and it covers the Android app that is running, making it look like the program has a problem.

## About the author

ApkStart is developed and maintained by **RoutineMiku**.

- GitHub: <https://github.com/RoutineMiku/apkstart>
- WeChat Official Account: scan the code to follow

<p align="center"><img src="docs/images/brand.png" alt="About panel: Official Account QR code and project links" width="560" /></p>

<p align="center"><i>Powered by <b>RoutineMiku</b></i></p>

## Contributing

Issues and PRs are welcome. The shell keeps zero third-party dependencies; please run `npm test` before submitting. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

[MIT](LICENSE). Release packages contain only ApkStart's own code and the Electron runtime. They do not distribute Android system images, QEMU binaries, or Google components; those are downloaded on demand from official sources by the user's machine on first launch, under their respective licenses.
