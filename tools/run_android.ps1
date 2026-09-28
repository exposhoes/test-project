# EmirCRAFT'ı derler, çalışan emülatöre/cihaza kurar ve başlatır.
# Android Studio'daki "EmirCRAFT" Run yapılandırması bu betiği çağırır.
$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$root = Split-Path -Parent $PSScriptRoot
$godot = if ($env:GODOT) { $env:GODOT } else { (Get-ChildItem "D:\Godot\Godot_v*_console.exe" | Sort-Object Name | Select-Object -Last 1).FullName }
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$apk = Join-Path $root "export\EmirCRAFT.apk"
$pkg = "com.emircraft.game"

# Emülatör açılıyorsa hazır olmasını bekle (en fazla ~3 dakika).
Write-Host "Emülatör bekleniyor..."
$ready = $false
for ($i = 0; $i -lt 90; $i++) {
	if (& $adb devices | Select-String "\tdevice$") {
		$boot = (& $adb shell getprop sys.boot_completed 2>$null | Out-String).Trim()
		if ($boot -eq "1") { $ready = $true; break }
	} elseif ($i % 10 -eq 5) {
		# "offline" takılmasını çözmek için adb bağlantısını yenile.
		& $adb reconnect offline 2>&1 | Out-Null
	}
	Start-Sleep -Seconds 2
}
if (-not $ready) {
	Write-Host "Emülatör hazır olmadı. Device Manager'da emülatörün ⋮ menüsünden Cold Boot Now yapıp tekrar dene."
	exit 1
}
Write-Host "Emülatör hazır."

# Buluttaki son değişiklikleri al; yerel değişiklik varsa çekmeden devam eder.
Write-Host "Güncelleniyor..."
& git -C $root pull --ff-only 2>&1 | Out-String | Write-Host

Write-Host "Derleniyor: $godot"
New-Item -ItemType Directory -Force (Join-Path $root "export") | Out-Null
& $godot --headless --path $root --export-debug "Android" $apk 2>&1 | Select-String "ERROR|SCRIPT ERROR|DONE.*export"
if (-not (Test-Path $apk)) { Write-Host "APK üretilemedi."; exit 1 }

Write-Host "Kuruluyor..."
& $adb wait-for-device
for ($try = 1; $try -le 3; $try++) {
	& $adb wait-for-device
	$out = cmd /c "`"$adb`" install -r `"$apk`" 2>&1" | Out-String
	if ($out -match "Success|UPDATE_INCOMPATIBLE|signatures do not match") { break }
	Write-Host "Kurulum denemesi $try başarısız, tekrar deneniyor..."
	Start-Sleep 3
}
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
