# ApkStart User Manual and Troubleshooting Guide

> Version: v0.6.3 · Platform: Windows 10/11 x64 · Updated: 2026-11-19
>
> ApkStart is an Android app runner for Windows: **it lets Android apps install like native Windows software, appear on the desktop, and open with a double click.**
> This manual first shows you how to use it, then gives solutions you can follow step by step, organized by symptom. Every step refers to a button or menu that actually exists in the app.

---

## Table of Contents

1. [Understand ApkStart in 30 Seconds](#1-understand-apkstart-in-30-seconds)
2. [Installation and First Launch](#2-installation-and-first-launch)
3. [Everyday Use](#3-everyday-use)
4. [Three Core Concepts (the Key to Understanding Errors)](#4-three-core-concepts-the-key-to-understanding-errors)
5. [When Something Goes Wrong, Do This First: Health Check and Auto Detection](#5-when-something-goes-wrong-do-this-first-health-check-and-auto-detection)
6. [Solutions to Common Problems](#6-solutions-to-common-problems)
   - [6.1 "Hardware Acceleration Is Not Enabled" / Very Slow Startup](#61-hardware-acceleration-is-not-enabled--very-slow-startup)
   - [6.2 Installation Failed (INSTALL_FAILED_*)](#62-installation-failed-install_failed_)
   - [6.3 The System Image Has No ARM Translation Layer / ARM Apps Will Not Install or Crash](#63-the-system-image-has-no-arm-translation-layer--arm-apps-will-not-install-or-crash)
   - [6.4 adb Not Authorized (Allow USB Debugging)](#64-adb-not-authorized-allow-usb-debugging)
   - [6.5 Double Clicking the Icon Does Nothing / It Spins Forever / A Window With a Rotate Button Appears](#65-double-clicking-the-icon-does-nothing--it-spins-forever--a-window-with-a-rotate-button-appears)
   - [6.6 Quick Reference Table for Other Startup Problems](#66-quick-reference-table-for-other-startup-problems)
   - [6.7 Apps Have No Sound / Sound Is Very Quiet](#67-apps-have-no-sound--sound-is-very-quiet)
   - [6.8 Store Edition Fails to Start / 0xC0000135 (DLL Failed to Load)](#68-store-edition-fails-to-start--0xc0000135-dll-failed-to-load)
7. [Command Line Reference](#7-command-line-reference)
8. [Data and Folders](#8-data-and-folders)
9. [Getting Help and Sending Feedback](#9-getting-help-and-sending-feedback)

---

## 1. Understand ApkStart in 30 Seconds

```
Desktop icon (real app icon, .lnk)
      | Double click
      v
ApkStart.exe --launch <package name>
      | Android runtime not running? -> Start it automatically (Android 14 emulator, bundled or downloaded on first run)
      v
Open the app using the launch entry resolved by the system (not the main Activity hardcoded in the APK)
      v
Emulator window = app window (title changed, icon changed, portrait aspect ratio, fullscreen centered)
```

**Its features**

- **Double click an .apk to install it**: after the file association is registered in Explorer, double clicking an APK parses it, installs it, and creates a desktop icon automatically.
- **One desktop icon per app**: icons are extracted offline from inside the APK. Double clicking an icon goes straight into the app.
- **The app is a window**: native rendering, fullscreen fills the height of the screen and is centered, windowed mode can be dragged and resized, and each app remembers its own size.
- **Searchable in Windows**: shortcuts in both places, on the desktop and in the Start menu (`Programs\ApkStart\`).
- **Shared data**: `%USERPROFILE%\ApkStartShared` <-> Android `/sdcard/ApkStartShared`, synced in both directions.
- **Runtime included**: it does not depend on any emulator installed on your machine, such as MuMu, LDPlayer, or WSA.

> Note: this project is at an early stage. The author maintains it in spare time. It is open source, free, and has no ads. Running into problems is normal, and that is what this manual is for.

---

## 2. Installation and First Launch

### 2.1 Choose the Edition That Suits You

Both sources have identical content. Gitee is recommended inside China:

- GitHub: `github.com/RoutineMiku/apkstart/releases`
- Gitee: `gitee.com/daily-miku/apkstart/releases` (much faster with a direct connection inside China)

| Form | File name | When to choose it |
|---|---|---|
| **Store edition** | `ApkStart_<four-part version>_x64.msix` | Install from the Microsoft Store. Includes the full runtime, works offline after installation, updates are handled by the Store |
| **Full portable edition** | `ApkStart-v*-win64-full.zip` (about 830 MB, about 1.3 GB extracted) | You do not want to install or wait for a download: extract and use it, the runtime is all in the package |
| **Installer edition** | `ApkStart-v*-Setup.exe` (about 1.3 GB) | You want desktop and Start menu shortcuts and an uninstall entry |
| **Lightweight portable edition** | `ApkStart-v*-win64-portable.zip` (96 MiB, about 227 MB extracted) | You just want to try it first; the runtime is downloaded online on first launch |

> Warning: **always use the latest version (currently 0.6.3)**. Old versions (0.5.x and earlier) either have no bundled runtime and look for or download a 1.5 GB runtime on every launch, or use an embedded window by default. That is exactly the typical source of "very slow, will not open, a window with a rotate button appears". If you upgraded from an old version, make sure the desktop icon points to the new program folder.

### 2.2 What Happens on First Launch

1. **(Lightweight edition only) Download the runtime**: adb, Android Emulator, and the Android 14 system image. Measured at 10+ MB/s from the official source, with 8 threaded chunks and resumable downloads. The full and Store editions skip this step.
2. **Extract the image for the first time**: the xz image is extracted to `%APPDATA%\apkstart\system-images` (about 20 seconds, done only once).
3. **Create `/data` for the first time**: ApkStart generates ext4 user data with encryption and SELinux labels itself (the official image only has a 1 MB placeholder).
4. **Automatic startup**: after that, opening an app is just one `am start`. A cold start takes about 23 seconds, and about 10 seconds when a snapshot is hit.

> A slow first launch is normal. It is a one time cost. After that, apps open in seconds.

---

## 3. Everyday Use

### 3.1 Installing Apps

Choose any of the three methods:

- **Double click the APK file** (register the association first: Settings, System Integration, Associate .apk Files);
- Choose "Install App" in the main window;
- Command line: `ApkStart.exe <path\to.apk>`.

Split packages in `.apks` / `.xapk` form are supported (using `install-multiple` automatically). After installation, desktop and Start menu shortcuts are created automatically.

### 3.2 Opening Apps

Just double click the desktop icon. All apps share the same runtime, so **the second app starts almost instantly**.

### 3.3 Window and Display

| Action | Method |
|---|---|
| Switch between fullscreen and windowed | `F11` or the tray right click menu. Fullscreen only enlarges the window and does not change the aspect ratio of the picture |
| Rotate between portrait and landscape | `Ctrl+Alt+R` (global) or the rotate button in the title bar; the orientation is remembered for that app |
| Automatic fullscreen | Settings, Display and Window, Automatic Fullscreen (works best together with "Force Orientation") |
| Force landscape or portrait | Settings, Display and Window, Screen Orientation |

> The runtime is restarted only on the one occasion when "the panel orientation and the app orientation do not match" (about 40 seconds, and the title bar shows a hint). After that, apps with the same orientation open in seconds.

### 3.4 Keyboard Shortcuts

| Keys | Action |
|---|---|
| `F11` | Switch between fullscreen and windowed mode |
| `Ctrl+Alt+R` | Rotate the current app between portrait and landscape |
| `Ctrl+R` | Rotate inside the shell window (in native window mode, use `Ctrl+Alt+R`) |

### 3.5 File Sharing (Windows <-> Android)

`%USERPROFILE%\ApkStartShared` on this machine and `/sdcard/ApkStartShared` in Android are synced in both directions within seconds.
Entry point: Settings, Integration and Files, File Sharing (you can "Sync Now" or "Open Folder").

### 3.6 Settings Page Navigation

Since 0.6.0 the settings are divided into categories, with a search box at the top (enter keywords such as "landscape", "memory", or "proxy" to match across categories):

| Category | Main contents |
|---|---|
| Common and Installation | Runtime and environment, one click completion, start on boot, disk usage and cleanup |
| Display and Window | Display mode, automatic fullscreen, screen orientation, tablet layout, how windows are hosted |
| Controls and Input | Mouse buttons, keyboard mapping |
| Performance and Resources | Resource policy, graphics quality, data partition, system language, snapshots, startup warmup |
| Network and Downloads | Update and download sources, acceleration mirrors, number of download threads |
| Diagnostics and Repair | Machine health check, drivers and compatibility patches, auto detection |
| Integration and Files | Desktop and apps, file sharing, system integration |
| Updates and About | Software updates, About |
| Lab | Native Windows multi window multi instance (experimental), number kept in background |

> **Lab, Multi Instance (experimental)**: when this is on, a new app no longer forces the previous one to close. Multiple apps can stay in the background, you can switch back to them at any time, and login state is kept. Because the Android runtime has only one emulator window, only one app picture is shown in the foreground at a time. It is not true side by side multi window, and turning it on increases memory use. It is off by default. If you want stability, you can ignore it.

### 3.7 Online Updates

Settings, Updates and About, Check for Updates, or right click the tray icon and choose Check for Updates. The update path tests the sources live and picks the fastest one (GitHub / Gitee / mirror), downloads in parallel chunks, and switches source automatically on failure. Updating does not lose the runtime, installed apps, or snapshots.

Newer portable editions support **incremental updates**: each release also publishes a "code manifest" and a small package containing only program code (a few MB, while the whole installer is about 100 MB). If the version of your Electron shell has not changed, the update downloads only this small package, verifies files one by one, and replaces the program code, which takes a few seconds. If the shell version changed, the manifest is missing, or any verification fails, it falls back automatically to downloading the full package, so an update cannot break the program. The Store edition is still updated by the Microsoft Store.

> Note: incremental updates apply only to portable edition users who use "Check for Updates" to install from GitHub / Gitee. Users who installed from the Microsoft Store use the Store channel. Incremental updates have no effect on installed apps, Android data, the runtime, or snapshots.

---

## 4. Three Core Concepts (the Key to Understanding Errors)

Most "strange problems" have their root in one of the three things below. Spend a minute understanding them and troubleshooting afterwards becomes much easier.

### 4.1 Runtime / System Image

ApkStart does not emulate an "empty Android". It loads a **complete Android 14 system image** as the base.
Version 0.6.3 has only **one universal image** (Google Play x86_64), and both x86 and ARM apps run on it. It no longer splits into two sets, an "AOSP image / compatibility image", as old versions did.

- Image missing, damaged, or incompatible with old user data leads to startup failure, getting stuck at boot, or repeated restarts.
- User data (`/data`) is a thin differential layer, and one system image is shared by the whole machine.

### 4.2 Hardware Acceleration

To run fast, the emulator needs CPU virtualization acceleration. On Windows there are only two routes:

| Method | What it is | Who needs administrator rights | Restart needed after installing |
|---|---|---|---|
| **WHPX** | The built in Windows feature "Windows Hypervisor Platform" (HypervisorPlatform) | When enabling this feature | Yes |
| **AEHD** | Google's own kernel driver | When installing the driver | No |

**It can run without acceleration** (pure software emulation, TCG). Startup just takes minutes and the picture drops frames easily. That is "slow", not "failed to start". ApkStart falls back automatically, and retries automatically with up to 4 sets of parameters, in the order "rendering backend, acceleration method, memory and cold start".

> Do not treat **VirtualMachinePlatform** (used by WSL2) as the acceleration switch. The emulator needs **HypervisorPlatform**. If you enable only the former, `emulator -accel-check` will still say it is unavailable.

### 4.3 ARM Translation Layer

Most Android apps from China provide only **ARM native libraries** (arm64-v8a / armeabi-v7a), while the system image is **x86_64**, so a "translation layer" is needed to translate ARM instructions for the x86 CPU. The universal image in 0.6.3 includes the new `ndk_translation` translation layer, so installing ARM apps usually needs no settings at all.

- When an ARM app is met for the first time, if the translation layer components are not in place yet, ApkStart completes the compatibility image automatically and restarts the runtime to retry (see 6.3).
- Old images (API 30) have compatibility problems with the new translation layer (for example, ByteDance apps triggering `DoBadTrampoline` SIGABRT). The Android 14 image has fixed this.

---

## 5. When Something Goes Wrong, Do This First: Health Check and Auto Detection

Before going through this manual, let the app check itself first. It can fix most problems automatically.

### 5.1 Machine Health Check and Automatic Configuration

Location: Settings, Diagnostics and Repair, **Start Health Check**

- What it checks: whether CPU virtualization (VT-x/SVM) is on, whether Hyper-V and the Windows Hypervisor Platform are available, graphics card, video memory and driver, memory, system version, `emulator -accel-check`, and the AEHD driver.
- Click "**Apply Recommended Configuration**" to write the safe items automatically: memory, number of cores, rendering resolution, graphics quality, and forcing software emulation when there is no acceleration. It is saved as a machine profile and applied automatically in future.
- Result levels: `ok` (normal), `warn` (usable but optimization is recommended), `bad` (will not run if not handled). Each item has a color and an explanation.

There are only two kinds of things you need to do yourself:
- **BIOS virtualization**: restart, enter the BIOS, turn on Intel VT-x / AMD SVM, set it to Enabled (the app cannot do this step for you).
- **Windows features / acceleration driver**: see 6.1.

### 5.2 Auto Detection (Automatic Debugging)

Location: Settings, Diagnostics and Repair, "Auto Detection, Smart Diagnostics"

In the background it checks the machine every 10 minutes, lists problems in six categories, and each item can be **handled with one click** (restart the runtime, clear locks, clear orphan processes, invalidate snapshots, clean up disk, reset the Android network, and so on). After a fix it rechecks automatically:

| Category | Problems covered |
|---|---|
| Runtime | The real cause of the last startup failure, boot stuck, leftover lock files, orphan emulator processes, empty snapshot shells, no hardware acceleration |
| Device connection | adb not authorized, offline, the runtime is running but adb cannot see the device |
| Storage | Free disk space, the data partition configuration does not match reality, the shared folder is not writable |
| Settings | Screen orientation conflicts with the physical panel, automatic fullscreen does not take effect in a separate window |
| Network and logs | No network on the Android side, download sources unreachable, errors in recent logs |

> Two principles: a failed probe is not treated as a problem (when the state cannot be obtained it reports "unknown", and never reports blindly); and the same old problem does not disturb you repeatedly.

### 5.3 Export a Diagnostic Report

Location: Settings, Diagnostics and Repair, **Export Diagnostic Report** (or the button with the same name on the System Integration page)

The report is plain text and contains the machine configuration, the automatically selected startup parameters, logs, and diagnostic conclusions. Attaching it when you report a problem greatly speeds up locating the cause.

### 5.4 Built In User Manual and Automatic Tutorials

Since 0.6.3, this manual is **embedded in the app**: the "?" button in the title bar of the main window, and "Open the User Manual" in Settings, About, both open it directly. It can be searched, scrolled, and printed or saved as PDF. When opened, it goes automatically to the chapter related to the current fault.

Auto detection and repair also bring the tutorial to you:

- When auto detection finds a problem, there is a "Tutorial" button on the right of the problem item. Clicking it goes straight to the matching chapter;
- For problems such as hardware acceleration, installation failure, the ARM translation layer, adb authorization, and no sound, **when automatic repair fails, the matching tutorial pops up automatically**, so you do not need to come here and search;
- The same tutorial pops up automatically only once in one run, so it will not interrupt you repeatedly.

> Open it manually: the `?` button in the title bar. If you want to turn off automatic popups temporarily, you can turn off notifications in the auto detection settings. The tutorial can still be opened from the "Tutorial" button on a problem item.

---

## 6. Solutions to Common Problems

### 6.1 "Hardware Acceleration Is Not Enabled" / Very Slow Startup

**Symptoms**: Settings or Diagnostics says "there is currently no hardware acceleration" or "hardware acceleration is unavailable"; startup takes minutes and the picture drops frames.

**Be clear first**: this is usually "slow", not "will not open". ApkStart has already fallen back to software emulation automatically. You only need to enable acceleration if you want it to be smooth.

**Handle it by edition:**

- **Installer / portable edition**: Settings, Diagnostics and Repair, Machine Health Check, find "Hardware acceleration is not enabled", and click **Repair**. One UAC prompt appears, and WHPX is enabled automatically. If it cannot be enabled (the system does not support it, or you clicked No), it installs the AEHD driver instead automatically.
- **Microsoft Store (MSIX) edition**: Store apps **cannot elevate themselves**. Clicking "Repair" opens the "Turn Windows features on or off" dialog:
  1. Check **"Windows Hypervisor Platform" (HypervisorPlatform)**;
  2. After confirming, **restart the computer** once.

  You can also run this in an **administrator PowerShell**:

  ```powershell
  dism /online /enable-feature /featurename:HypervisorPlatform /all /norestart
  dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
  ```

> Two pitfalls: 1. Do not enable only VirtualMachinePlatform. That is not the acceleration the emulator needs. 2. If VT-x/SVM is not enabled in the BIOS, first enter the BIOS and enable it as in 5.1, otherwise enabling the system feature is useless.
> If the graphics driver is more than 3 years old, update it from the vendor's official website. ApkStart does not install drivers automatically (installing the wrong one is worse). Some old graphics cards and integrated graphics need a compatibility patch. See Settings, Diagnostics and Repair, Drivers and Compatibility Patches.

---

### 6.2 Installation Failed (INSTALL_FAILED_*)

**Symptoms**: an error is reported when installing an app. The text usually starts with "Installation failed:" and ends with an `INSTALL_*` error code.

ApkStart translates the original English errors into a friendly message. Handle it using the table below:

| Error code | Meaning | What to do |
|---|---|---|
| `INSTALL_FAILED_NO_MATCHING_ABIS` | The app provides only ARM libraries, and the current image has no ARM translation layer | **Usually handled automatically**: ApkStart switches to the compatibility image and retries. See [6.3](#63-the-system-image-has-no-arm-translation-layer--arm-apps-will-not-install-or-crash) |
| `INSTALL_FAILED_OLDER_SDK` | The app requires a higher Android version | A higher system image is needed; the current one is Android 14 (API 34), so this is rarely triggered |
| `INSTALL_PARSE_FAILED_NO_CERTIFICATES` | The APK has no valid signature | The APK is damaged or is not a regular package. Get the installer again |
| `INSTALL_PARSE_FAILED_INCONSISTENT_CERTIFICATES` / `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | The signature does not match the installed version | Uninstall the old version first, then install |
| `INSTALL_FAILED_VERSION_DOWNGRADE` | A higher version is already installed on the device | You cannot downgrade over it. Install a higher version or uninstall first |
| `INSTALL_FAILED_INSUFFICIENT_STORAGE` | Not enough disk space in the runtime | Clean up the disk, or change the runtime data folder to a drive with enough space (Settings, System Integration) |
| `INSTALL_FAILED_INVALID_APK` | The APK is damaged or incomplete | The download may not have finished. Download it again |
| `INSTALL_FAILED_INVALID_URI` | The APK path contains special characters or non English characters | Move the APK to a path in plain English, then install |
| `INSTALL_FAILED_ALREADY_EXISTS` | An app with the same name and a different signature already exists | Uninstall it first |
| `INSTALL_FAILED_DEPRECATED_SDK_VERSION` | An app targeting a very old Android | **Handled automatically**: ApkStart retries with the official bypass parameter |
| `INSTALL_FAILED_TEST_ONLY` | A test only package | **Handled automatically**: it retries automatically with the test package parameter |
| `INSTALL_FAILED_MISSING_SHARED_LIBRARY` | A required device feature or vendor library does not exist | The app depends on a specific vendor environment, which the emulator cannot provide |
| `INSTALL_FAILED_USER_RESTRICTION` | The system restricts installation | Restart the runtime and retry |
| `INSTALL_FAILED_CONFLICTING_PROVIDER` | A ContentProvider conflicts with an existing app | Uninstall the conflicting app |
| `INSTALL_FAILED_INTERNAL_ERROR` | An internal system error (usually not enough space, or startup had not finished) | Restart the runtime, wait until startup finishes, then retry |

> If the error is a raw English error outside the table above, export a diagnostic report as in 5.3 and send feedback.

---

### 6.3 The System Image Has No ARM Translation Layer / ARM Apps Will Not Install or Crash

**Symptoms**: installation reports `INSTALL_FAILED_NO_MATCHING_ABIS`, and the text says the app provides only ARM native libraries and the current system image has no ARM translation layer; or the app crashes as soon as it starts after installation, and the log shows `DoBadTrampoline`, `libndk_translation`, `UnsatisfiedLinkError`, or `...so not found`.

**How it works**: 0.6.3 uses **one universal Android 14 image** to support x86 and ARM at the same time, and the translation layer is built in. Old versions needed a manual image switch. That "Universal compatibility image (managed automatically)" switch is now **only for compatibility with old configurations, and normally you do not need to touch it manually**.

**What ApkStart does automatically:**

1. If installation reports `NO_MATCHING_ABIS`, it switches to the compatibility image automatically, restarts the runtime, reinstalls the already installed apps from the local APK backups, and installs again (see the log "Switching to the compatibility image and restarting the runtime...").
2. If an app crashes on startup and the log clearly points to the ARM translation layer (such as `DoBadTrampoline`), it switches to the Android 14 compatibility image automatically and retries (log "ARM translation layer crash detected, switching to the compatibility image automatically...").

**What you need to do:**

- **Wait patiently**: switching the image restarts the runtime. One switch takes about 40 seconds to 1 minute, and a hint window may appear during that time.
- **Confirm the image is in place**: Settings, Common and Installation, Runtime, and look at the status of "Universal compatibility image (managed automatically)". If it shows it is not downloaded, click "Download Compatibility Image" (about 1.5 GB). After it finishes, **restart the runtime** for it to take effect.
- **Still crashing**: a few apps have deeper anti emulator detection of their own (forcibly checking real sensors, the baseband, and so on) and cannot run in an emulator. Such apps give an explanation. That is a limitation, not a fault.

**What if you see a red "Installation failed", but the text says "Retrying after switching to the compatibility image automatically"?**

That is a display bug in an old version: the image file was clearly on disk, but it was reused on an old runtime without the translation layer enabled, the switch and retry were skipped, and failure was reported directly, while the hint text still said "retrying". **You are not using the latest code. Please upgrade to the latest build of 0.6.3** (the version this manual matches has fixed it: before installation it probes the real translation capability of the currently running runtime instead of only looking at whether the image file exists; `NO_MATCHING_ABIS` always triggers a switch, a restart, clearing the old snapshot, and a reinstall; if it fails a second time it tells you honestly and no longer falsely claims it is "retrying"). Upgrade and install once more.

> Tested: Hongguo Free Short Drama (com.phoenix.read, arm64-v8a only) installs normally on the Android 14 image with the new translation layer, enters the recommendation feed, and plays video. On the current runtime `ro.product.cpu.abilist` = `x86_64,arm64-v8a`, and the translation layer is in effect.

---

### 6.4 adb Not Authorized (Allow USB Debugging)

**Symptoms**: Diagnostics reports "adb not authorized" or "Android debugging authorization not completed", `adb devices` shows `unauthorized`, and apps never start.

**Correct approach (in order):**

1. Look for an emulator window on screen showing an **"Allow USB debugging?"** dialog. Go to that window and click **Allow**, and check **"Always allow from this computer"**. After that it will not ask again.
2. If the window cannot be clicked, or it never appears: Settings, Runtime, **Reset Android Data / Clear Android Data** and retry (this clears installed apps. The APK files are all still there and will be reinstalled automatically, and it does not affect the system itself).

> Warning: **never delete `%USERPROFILE%\.android\adbkey`**. Testing showed that is the reverse operation: Android writes a new public key only when the `adb_keys` file does not exist. If you replace the private key with a new one, the old public key stored in the system still applies, the two do not match, and authorization will never succeed.

> Command line troubleshooting: the ApkStart adb service runs on **dedicated port 5044** (completely separate from your own 5037):
> ```powershell
> $env:ANDROID_ADB_SERVER_PORT = 5044
> adb devices    # should show emulator-5554
> ```
> Do not manually `adb connect` to port 5555. The Play image pops up "Allow USB debugging" over the app, which looks as if the program is broken.

---

### 6.5 Double Clicking the Icon Does Nothing / It Spins Forever / A Window With a Rotate Button Appears

Almost all of these problems point to the **launch entry or window takeover**. Check in the order below.

**1. Confirm you are using the new program**

- Look at the start of the log `%APPDATA%\ApkStart\logs\app.log`: it should say `start v0.6.3`. If it shows `v0.5.x`, the desktop or Start menu icon points to an old folder.
- Old versions (0.5.x) have no bundled runtime and use an embedded window by default, which gives "very slow plus a shell window with a rotate button". Change to 0.6.3 and point the shortcut to the new `ApkStart.exe`.

**2. Have realistic expectations about startup time**

A cold start of about 23 to 48 seconds, and a restart for an orientation change of about 50 seconds, are in the normal range. During that time clicking the icon looks like "nothing happens", but it is actually starting up in the background. **Do not click repeatedly**: repeated clicks let the second instance take over the emulator, and the cleanup when the first instance exits may close the emulator with it, causing failure (0.6.3 added `owner.pid` protection, but waiting in a queue still looks like nothing happens). Click once and wait for it to come up.

**3. The native window was not taken over, so it fell back to the embedded window with a rotate button**

If the log shows `attach failed` or `emu:0`, the window agent did not find the emulator window and the program fell back to embedded mode (that is the shell window with a title bar and a rotate button that you see).
- This is easily triggered when starting from a directory junction or a non standard path. In 0.6.3 the agent resolves the real path before matching. If it still appears, send feedback with the log attached.

**4. Reset Android data (last resort)**

Settings, Common and Installation, **Reset Android Data** (with a second confirmation). This clears installed apps and data, but keeps the system itself. The app list is kept, and opening an app reinstalls it automatically. It is suitable for cases where nothing opens because the data partition is damaged or `/data` cannot be mounted.

---

### 6.6 Quick Reference Table for Other Startup Problems

ApkStart has **already handled most of these runtime errors automatically**. The table below explains what it did and what else you can do. If automatic handling does not work, export a diagnostic report as in 5.3.

| Diagnostic title | Automatic handling | What else you can do |
|---|---|---|
| Hardware acceleration unavailable | Fall back to software emulation | Enable acceleration as in 6.1 |
| Memory allocation failed | Lower the memory and number of cores | Close programs that use memory |
| Emulator port already in use | Switch to a free port automatically | Exit other emulators (Nox, MuMu, BlueStacks) or restart |
| Leftover lock file / "Running multiple emulators with the same AVD" | Clear the AVD lock automatically and retry | Make sure no other emulator is using the same runtime |
| System image missing, damaged, or incompatible with old data | Start again with clean user data | Settings, Runtime, delete the image and download it again |
| Quick start snapshot damaged | Discard the old snapshot and do a cold start | It is rebuilt on the next normal exit; or turn snapshots off |
| Runtime components deleted / VC++ runtime missing | None | Add ApkStart to the antivirus whitelist and extract it again; install the Microsoft VC++ 2015-2022 runtime |
| Not enough disk space | None | Change the runtime folder to a drive with enough space; turn snapshots off or make the data partition smaller |
| Path contains non English or special characters | Use a short path automatically | Move ApkStart to a plain English folder (such as `C:\ApkStart`) |
| CPU lacks instruction sets (AVX/SSE4) | None | Mostly a warning and it can still start; otherwise change to a machine that supports VT-x/AVX, or use an old engine |
| The current runtime does not accept this GPU mode | Reselect an available GPU mode by engine version | None |
| Graphics card / unknown error | Retry automatically with several sets of parameters | Update the graphics driver; or write a compatibility patch; if it still fails, export a diagnostic report |

**The desktop icon shows the ApkStart icon or a blank icon**: Settings, System Integration, **Rebuild Shortcuts** (rewrites the desktop and Start menu shortcuts from the current app list, and fixes the icons and the taskbar identity together). If a shortcut was moved and its path became invalid, it also needs to be rebuilt.

---

### 6.7 Apps Have No Sound / Sound Is Very Quiet

**Symptoms**: video and notification sounds in Android apps are completely silent; or other Windows software has sound and only apps in ApkStart have none.

**Distinguish first**: if the system itself has no sound, solve the Windows audio problem first. Only follow the steps below when only apps in ApkStart have no sound.

1. **Windows volume and output device**: click the volume icon in the taskbar, make sure it is not muted and the volume is not 0, and that the output device is the headphones or speakers you are using. Open the "Volume mixer" and check whether the ApkStart / Android runtime line has been muted separately or pulled down to 0.
2. **In app volume**: some apps set the media volume to 0 the first time you enter them. Turn it up in the app's own settings or with the Android side volume keys. Apps such as Bilibili and Douyin may also have turned off autoplay sound separately inside the app.
3. **The ApkStart sound switch**: Settings, Common and Installation, **Android App Sound** must be checked. Auto detection in 0.6.3 checks this item. If it finds it turned off, it reports it in Settings, Diagnostics and Repair, and clicking "Handle" turns it on with one click. **After changing it you must restart the Android runtime once** (the switch decides whether the emulator starts with `-no-audio`, so changing it while running does not produce sound immediately).
4. **Windows audio service**: press `Win+R`, enter `services.msc`, find **Windows Audio**, and make sure its status is "Running" and its startup type is "Automatic". If it is disabled, right click to start it. This is also found and reported by auto detection in 0.6.3. In an administrator PowerShell you can run `net start Audiosrv`.
5. **Bluetooth headphones / multiple output devices**: after switching to Bluetooth headphones, Windows sometimes does not move already running programs over. Disconnect and reconnect the headphones, or restart the Android runtime once.
6. **Still no sound**: send feedback after exporting a report in Settings, Diagnostics and Repair, Export Diagnostic Report. The report includes the sound switch and the audio service status, so it can locate directly whether the problem is the configuration, a system service, or the app itself.

> When automatic repair fails, the app opens this section automatically. If you turned off auto detection notifications, you can also enter manually from the "Tutorial" button on an auto detection problem item, or from `?` in the title bar.

---

### 6.8 Store Edition Fails to Start / 0xC0000135 (DLL Failed to Load)

**Symptoms**: after opening the app it spins forever or exits directly, and the diagnostic report shows exit code `0xC0000135` (decimal `3221225781`). This is most common in the **version installed from the Microsoft Store**.

**First correct a common misjudgment**: `0xC0000135` only means "a DLL failed to load". It does **not** necessarily mean the VC++ runtime is missing, and it does not necessarily mean antivirus software deleted a file. There are three possible causes behind the same exit code. Do not just reinstall repeatedly following the first one:

1. **Path limits of the Store (MSIX) edition**: the Store edition is installed in the read only `C:\Program Files\WindowsApps\...` folder. When the Android runtime starts child processes such as `qemu` from this folder, the child process looks for DLLs by relative path, which may be interrupted by the container's path redirection or environment isolation, so it cannot find a dependency and exits with `0xC0000135`. This is specific to the Store edition and cannot be solved by reinstalling VC++.
2. **The VC++ runtime really is missing**: the Android runtime (Qt6 / qemu) depends on Microsoft VC++ 2015-2022 (x64). If Settings, Diagnostics and Repair clearly reports "VC++ runtime (x64) missing", that is a **measured result that the dll file does not exist**, and you can click "Handle" to install it with one click.
3. **Antivirus software quarantined runtime files**: a dll in the runtime folder was quarantined or deleted, which also reports this code. Add the ApkStart installation folder and the runtime data folder to the antivirus whitelist, then install once more.

**Troubleshoot in order**:

1. **See whether the diagnostics really say VC++ is missing**: if Settings reports the item "VC++ runtime (x64) missing", click its one click repair. After installation, restart the computer and try again. **Do not** reinstall just because the exit code is `0xC0000135`. First confirm this item really was reported.
2. **VC++ was not reported, but it still fails, so it is most likely the Store edition path problem**: this is currently the most likely cause. Try in order:
   - Exit ApkStart completely (tray icon, Exit) and open it again;
   - Check "Controlled folder access / Ransomware protection" in the antivirus software, add ApkStart to the whitelist, and restart;
   - If it still fails, use the **portable edition** (`ApkStart-win64-portable` in the Releases of the GitHub / Gitee repository), put it in a plain English folder (such as `C:\ApkStart`), and run it. The portable edition is not installed under WindowsApps, so it bypasses this limit directly.
3. **To get the exact name of the failing DLL** (advanced): when reporting a problem, the most valuable thing is to tell the developer which dll is missing. You can look in Event Viewer, Windows Logs, Application, for an `Application Error` for ApkStart / emulator, and look at the `FaultingModuleName` field; or export a report in Settings, Diagnostics and Repair, Export Diagnostic Report, and send the report with your feedback.
4. **What if adb also crashes**: if the event log separately shows `adb.exe` reporting `0xC0000409`, that is a separate independent problem (a device connection abnormality), not the direct cause of the emulator exiting. Handle startup using steps 1 to 3 above first, and explain the adb problem separately in your feedback.

> This section pops up automatically: when a startup failure or repair failure is judged to be a DLL type problem, the app opens straight here. You can also enter manually at any time from the "Tutorial" button on an auto detection item, or from `?` in the title bar.

---

## 7. Command Line Reference

```
ApkStart.exe                          Open the main window
ApkStart.exe <path\to.apk>            Install an APK
ApkStart.exe --launch <package name>  Launch an app directly (this is what desktop shortcuts use)
```

---

## 8. Data and Folders

| Purpose | Location |
|---|---|
| Runtime (adb / emulator / image) | Bundled with the package, or `%APPDATA%\apkstart\runtime` (lightweight edition) |
| Extracted system image | `%APPDATA%\apkstart\system-images` |
| AVD / installed apps / snapshots | `%APPDATA%\apkstart\avd` |
| App icons | `%APPDATA%\apkstart\icons\<package name>.ico` |
| Settings and lists | `%APPDATA%\ApkStart\settings.json` / `apps.json` |
| Run logs / diagnostic reports | `%APPDATA%\ApkStart\logs\` |
| Windows <-> Android shared folder | `%USERPROFILE%\ApkStartShared` <-> `/sdcard/ApkStartShared` |

> "Reset Android Data" clears only the user data layer. The system image and APK files are kept. Updating the app does not lose the runtime, installed apps, or snapshots.
>
> Keep enough free space on drive C: the extracted image, the data partition, and snapshots together can reach several GB. Not enough space causes installation and startup failures.

---

## 9. Getting Help and Sending Feedback

When reporting a problem, please attach three things. They greatly speed up locating the cause:

1. **Diagnostic report**: Settings, Diagnostics and Repair, Export Diagnostic Report;
2. **The last 20 lines of app.log**: `%APPDATA%\ApkStart\logs\app.log`;
3. **Your version and form**: for example "Store edition 0.6.3" or "Full portable edition 0.6.3".

- GitHub: <https://github.com/RoutineMiku/apkstart> (Issues / Releases)
- Gitee: <https://gitee.com/daily-miku/apkstart>

---

*This manual matches v0.6.3 and is updated with versions. If the wording in the interface differs slightly from here, what the app actually displays takes precedence.*
