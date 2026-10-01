# EmirCRAFT — degisiklikten sonra oyunu emulatorde ac.
# Kullanim:  powershell -ExecutionPolicy Bypass -File tools\emulatore_ac.ps1
#           powershell -ExecutionPolicy Bypass -File tools\emulatore_ac.ps1 -Shot ekran.png
# Yapar:  APK export -> emulatore kur -> baslat -> (istege bagli) ekran goruntusu
[Console]::OutputEncoding = [Text.Encoding]::UTF8
# adb bazen stderr'e bilgi yazar ("daemon not running"); PowerShell bunu
# Stop modunda hataya cevirip betigi kesiyor. Kontrolleri elle yapiyoruz.
$ErrorActionPreference = "Continue"

$repo    = Split-Path -Parent $PSScriptRoot
$godot   = "D:\Godot\Godot_v4.7.2-stable_win64_console.exe"
$adb     = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$apk     = "$repo\export\EmirCRAFT.apk"
$pkg     = "com.emircraft.game"
$shot    = $null
if ($args -contains "-Shot") { $shot = "C:\Users\mehme\AppData\Local\Temp\opencode\ekran.png" }

function Adim($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }

# --- 1. emulator acik mi -------------------------------------------------
& $adb start-server 2>&1 | Out-Null          # daemon yoksa baslat, sonra cihazlari oku
$dev = (& $adb devices 2>$null | Out-String)
if ($dev -notmatch "emulator-\d+\s+device") {
	Write-Host "HATA: Emulator bulunamadi. Android Studio'da AVD'yi baslat." -ForegroundColor Red
	exit 1
}
$boot = (& $adb shell getprop sys.boot_completed 2>$null | Out-String).Trim()
if ($boot -ne "1") { Adim "Emulator boot bekleniyor..."; Start-Sleep 20 }

# --- 2. export ------------------------------------------------------------
# Yeni .class_name varsa once import (CLAUDE.md kurali).
Adim "Godot --import (yeni sinif varsa gerekli)"
& $godot --headless --path $repo --import 2>&1 | Out-Null

Adim "APK export ediliyor (bu birkac dakika surebilir)..."
$ex = & $godot --headless --path $repo --export-debug "Android" $apk 2>&1
if (-not (Test-Path $apk)) {
	Write-Host "HATA: Export basarisiz." -ForegroundColor Red
	$ex | Select-Object -Last 20 | ForEach-Object { Write-Host $_ -ForegroundColor DarkRed }
	exit 1
}
Write-Host ("    {0:N1} MB" -f ((Get-Item $apk).Length / 1MB))

# --- 3. kur ---------------------------------------------------------------
Adim "Emulator kuruluyor..."
& $adb shell am force-stop $pkg 2>&1 | Out-Null
$ins = cmd /c "`"$adb`" install -r -t `"$apk`" 2>&1" | Out-String
if ($ins -notmatch "Success") {
	Write-Host "HATA: Kurulum basarisiz.`n$ins" -ForegroundColor Red
	exit 1
}

# --- 4. baslat + hata denetimi -------------------------------------------
Adim "Baslatiliyor..."
& $adb logcat -c 2>&1 | Out-Null
& $adb shell monkey -p $pkg -c android.intent.category.LAUNCHER 1 2>&1 | Out-Null
Start-Sleep 14

# --- 5. ekran goruntusu ---------------------------------------------------
if ($shot) {
	Start-Sleep 6
	# PowerShell'in ">" ciktisi bozdugu icin cmd uzerinden yaziyoruz.
	cmd /c "`"$adb`" exec-out screencap -p > `"$shot`""
	if (Test-Path $shot) {
		Write-Host ("    Ekran goruntusu: {0} ({1:N0} KB)" -f $shot, ((Get-Item $shot).Length / 1KB)) -ForegroundColor Green
	} else {
		Write-Host "    Ekran goruntusu alinamadi." -ForegroundColor Yellow
	}
}

# --- 6. hata raporu -------------------------------------------------------
$errs = (& $adb logcat -d -s godot:E AndroidRuntime:E 2>$null |
	Select-String -NotMatch "cached shader|_load_from_cache|beginning of" | Out-String).Trim()
if ($errs) {
	Write-Host "`n--- godot hatalari ---" -ForegroundColor Yellow
	Write-Host $errs -ForegroundColor DarkYellow
} else {
	Write-Host "`nHata yok. Emulatorde kontrol edebilirsin." -ForegroundColor Green
}
