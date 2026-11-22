; ApkStart custom NSIS script
; Purpose: before uninstallation starts, first end any runtime processes that may still be resident in the background.
; Otherwise they will lock files in the installation folder, so uninstallation is not clean and third party shredding tools cannot delete them either.
;
; After ApkStart exits, a detached qemu may still remain (so the next launch is instant),
; so the uninstall step must clean this up itself as a fallback.

; End of installation: add another fallback layer for the desktop icon.
; The createDesktopShortcut of electron-builder uses its own CreateShortcuts flow.
; In some environments (desktop redirected by OneDrive, shortcuts rolled back by security software) creation can fail,
; and the user finds nothing on the desktop after installation. Here the native NSIS CreateShortcut writes it once more:
; $DESKTOP uses SHGetFolderPath, which correctly follows the desktop redirection path. It is written as an idempotent operation,
; and running it again with electron-builder only overwrites the same .lnk.
!macro customInstall
  DetailPrint "Creating desktop shortcut..."
  CreateShortcut "$DESKTOP\ApkStart.lnk" "$INSTDIR\ApkStart.exe" "" "$INSTDIR\ApkStart.exe" 0 \
    SW_SHOWNORMAL "" "ApkStart - Run Android apps directly on your computer"
  CreateDirectory "$SMPROGRAMS\ApkStart"
  CreateShortcut "$SMPROGRAMS\ApkStart\ApkStart.lnk" "$INSTDIR\ApkStart.exe" "" "$INSTDIR\ApkStart.exe" 0 \
    SW_SHOWNORMAL "" "ApkStart - Run Android apps directly on your computer"
!macroend

!macro customUnInstall
  ; First delete the shortcut entries it wrote itself (nothing should remain when ApkStart is not installed)
  Delete "$DESKTOP\ApkStart.lnk"
  Delete "$SMPROGRAMS\ApkStart\ApkStart.lnk"
  RMDir "$SMPROGRAMS\ApkStart"

  DetailPrint "Ending leftover ApkStart processes..."
  ; /F force kills, /T includes child processes. When the process does not exist, taskkill returns 128, which can be ignored.
  nsExec::Exec 'taskkill.exe /F /T /IM ApkStart.exe'
  nsExec::Exec 'taskkill.exe /F /T /IM qemu-system-x86_64.exe'
  nsExec::Exec 'taskkill.exe /F /T /IM qemu-system-i386.exe'
  nsExec::Exec 'taskkill.exe /F /T /IM emulator.exe'
  nsExec::Exec 'taskkill.exe /F /T /IM emulator-check.exe'
  nsExec::Exec 'taskkill.exe /F /T /IM adb.exe'
  nsExec::Exec 'taskkill.exe /F /T /IM netsimd.exe'
  ; Give the processes a little time to really exit and release file handles
  Sleep 1500
!macroend
