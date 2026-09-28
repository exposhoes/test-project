# EmirCRAFT'ı derler, çalışan emülatöre/cihaza kurar ve başlatır.
# Android Studio'daki "EmirCRAFT" Run yapılandırması bu betiği çağırır.
$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$root = Split-Path -Parent $PSScriptRoot
$godot = if ($env:GODOT) { $env:GODOT } else { (Get-ChildItem "D:\Godot\Godot_v*_console.exe" | Sort-Object Name | Select-Object -Last 1).FullName }
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$apk = Join-Path $root "export\EmirCRAFT.apk"
$pkg = "com.emircraft.game"

if (-not (& $adb devices | Select-String "\tdevice$")) {
	Write-Host "Çalışan emülatör yok. Device Manager'dan emülatörü başlatıp tekrar dene."
	exit 1
}

# Buluttaki son değişiklikleri al; yerel değişiklik varsa çekmeden devam eder.
Write-Host "Güncelleniyor..."
& git -C $root pull --ff-only 2>&1 | Out-String | Write-Host

Write-Host "Derleniyor: $godot"
New-Item -ItemType Directory -Force (Join-Path $root "export") | Out-Null
& $godot --headless --path $root --export-debug "Android" $apk 2>&1 | Select-String "ERROR|SCRIPT ERROR|DONE.*export"
if (-not (Test-Path $apk)) { Write-Host "APK üretilemedi."; exit 1 }

Write-Host "Kuruluyor..."
& $adb wait-for-device
$out = & $adb install -r $apk 2>&1 | Out-String
Write-Host $out
if ($out -match "UPDATE_INCOMPATIBLE|signatures do not match") {
	Write-Host "İmza uyuşmadı, eski sürüm kaldırılıp yeniden kuruluyor..."
	& $adb uninstall $pkg | Out-Null
	& $adb install $apk
} elseif ($out -notmatch "Success") {
	Write-Host "Kurulum başarısız. Emülatörün açık olduğundan emin olup tekrar dene."
	exit 1
}

& $adb shell am force-stop $pkg
& $adb logcat -c
& $adb shell monkey -p $pkg 1 | Out-Null
Write-Host "Başlatıldı. Godot logları (durdurmak için kırmızı kare):"
& $adb logcat -s godot:* AndroidRuntime:E
