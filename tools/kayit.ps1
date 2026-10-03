# EmirCRAFT bölümlerini bilgisayarda otomatik videoya çeker (emülatör gerekmez).
# Godot'nun film kaydedicisi bölümü kare kare işler; ffmpeg MP4'e çevirir.
#   tools\kayit.ps1 bolum1            tek bölüm
#   tools\kayit.ps1 hepsi             tüm bölümler (var olanları atlar)
#   tools\kayit.ps1 hepsi -Yenile     hepsini baştan
# Çıktı: ..\videolar\shorts\ (dikey 1080x1920) ve ..\videolar\uzun\ (yatay 3840x2160, 4K)
param(
	[Parameter(Position = 0)][string]$Bolum = "hepsi",
	[switch]$Yenile,
	# Yatay videoyu AVI yerine PNG kare dizisi olarak kaydet (4 GB AVI sınırına takılırsa; çok yavaş: kare başına ~4 sn).
	[switch]$Png,
	# Yatay video varsayılan olarak 1080p kaydedilir (Mehmet: "ilk baştaki kayda dön"); -Dort ile 4K.
	[switch]$Hd,
	[switch]$Dort,
	[string]$Cikti = ""
)
$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$root = Split-Path -Parent $PSScriptRoot
$godot = if ($env:GODOT) { $env:GODOT } else { (Get-ChildItem "D:\Godot\Godot_v*_console.exe" | Sort-Object Name | Select-Object -Last 1).FullName }
$ffmpeg = if (Get-Command ffmpeg -ErrorAction SilentlyContinue) { (Get-Command ffmpeg).Source } else { "C:\ffmpeg\ffmpeg.exe" }
if (-not $Cikti) { $Cikti = Join-Path (Split-Path -Parent $root) "videolar" }
$override = Join-Path $root "override.cfg"
# Baştan kesilecek süre (sn); geri sayım kaldırıldığı için 0.
$basKes = 0

$liste = & $godot --headless --path $root --script res://tools/kayit.gd -- --liste 2>&1 |
	Select-String "^BOLUM\|" | ForEach-Object { $p = $_.Line.Split("|"); [pscustomobject]@{ Id = $p[1]; Format = $p[2]; Ad = $p[3] } }
if (-not $liste) { Write-Host "Bölüm listesi alınamadı."; exit 1 }
$secilen = if ($Bolum -eq "hepsi") { $liste } else { $liste | Where-Object { $_.Id -eq $Bolum } | Select-Object -First 1 }
if (-not $secilen) { Write-Host "Bölüm bulunamadı: $Bolum"; exit 1 }

$gorulen = @{}
foreach ($b in $secilen) {
	if ($gorulen.ContainsKey($b.Id)) { Write-Host "ATLANDI (aynı id iki bölümde): $($b.Ad)"; continue }
	$gorulen[$b.Id] = $true
	$dikey = $b.Format -eq "short"
	$klasor = Join-Path $Cikti $(if ($dikey) { "shorts" } else { "uzun" })
	New-Item -ItemType Directory -Force $klasor | Out-Null
	$ad = ($b.Ad -replace ":", " -") -replace '[\\/*?"<>|]', ""
	$mp4 = Join-Path $klasor "$ad.mp4"
	if ((Test-Path $mp4) -and -not $Yenile) { Write-Host "Var, atlandı: $ad"; continue }
	$avi = Join-Path $env:TEMP "emircraft_$($b.Id).avi"
	# Pencere ekrana sığacak kadar küçük açılır; görüntü tam çözünürlükte işlenir.
	$ayar = if ($dikey) {
		"[display]`nwindow/size/viewport_width=1080`nwindow/size/viewport_height=1920`nwindow/stretch/mode=`"viewport`"`nwindow/stretch/scale=1.0`nwindow/size/window_width_override=405`nwindow/size/window_height_override=720`nwindow/size/initial_position_type=0`nwindow/size/initial_position=Vector2i(-2600, 60)`n"
	} else {
		"[display]`nwindow/size/viewport_width=3840`nwindow/size/viewport_height=2160`nwindow/stretch/mode=`"viewport`"`nwindow/stretch/scale=3.0`nwindow/size/window_width_override=960`nwindow/size/window_height_override=540`nwindow/size/initial_position_type=0`nwindow/size/initial_position=Vector2i(-2600, 60)`n[editor]`nmovie_writer/mjpeg_quality=0.6`n"
	}
	# 4K kareler büyük: geçici AVI C: yerine çıktı sürücüsüne yazılır (yer sorunu olmasın).
	if (-not $dikey) { $avi = Join-Path $Cikti "_gecici_$($b.Id).avi" }
	if (-not $Dort -and -not $dikey) { $ayar = $ayar.Replace("viewport_width=3840", "viewport_width=1920").Replace("viewport_height=2160", "viewport_height=1080").Replace("stretch/scale=3.0", "stretch/scale=1.5") }
	Write-Host "Kaydediliyor: $ad"
	Set-Content $override -Encoding ASCII -Value $ayar
	if ($dikey -or -not $Png) {
		try {
			& $godot --path $root --write-movie $avi --fixed-fps 30 --script res://tools/kayit.gd -- $b.Id 2>&1 |
				Select-String "SCRIPT ERROR|frames at" | ForEach-Object { Write-Host "  $($_.Line.Trim())" }
		} finally {
			Remove-Item $override -Force -ErrorAction SilentlyContinue
		}
		if (-not (Test-Path $avi)) { Write-Host "  HATA: kayıt üretilemedi."; continue }
		& $ffmpeg -v error -y -ss $basKes -i $avi -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -c:a aac -b:a 160k -movflags +faststart $mp4
		Remove-Item $avi -Force -ErrorAction SilentlyContinue
	} else {
		# 4K: AVI dosyası 4 GB sınırını aşıp görüntüyü yarıda kesiyor; kareler tek tek PNG olarak yazılır.
		$kareler = Join-Path $Cikti "_gecici\$($b.Id)"
		if (Test-Path $kareler) { Remove-Item $kareler -Recurse -Force -Confirm:$false }
		New-Item -ItemType Directory -Force $kareler | Out-Null
		try {
			& $godot --path $root --write-movie (Join-Path $kareler "k.png") --fixed-fps 30 --script res://tools/kayit.gd -- $b.Id 2>&1 |
				Select-String "SCRIPT ERROR|frames at" | ForEach-Object { Write-Host "  $($_.Line.Trim())" }
		} finally {
			Remove-Item $override -Force -ErrorAction SilentlyContinue
		}
		$sayi = (Get-ChildItem $kareler -Filter "k*.png").Count
		if ($sayi -eq 0) { Write-Host "  HATA: kayıt üretilemedi."; continue }
		Write-Host "  $sayi kare yazıldı"
		& $ffmpeg -v error -y -framerate 30 -i (Join-Path $kareler "k%08d.png") -i (Join-Path $kareler "k.wav") -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -c:a aac -b:a 192k -shortest -movflags +faststart $mp4
		if (Test-Path $mp4) { Remove-Item $kareler -Recurse -Force -Confirm:$false }
	}
	if (Test-Path $mp4) { Write-Host ("  Hazır: {0} ({1:N1} MB)" -f $mp4, ((Get-Item $mp4).Length / 1MB)) } else { Write-Host "  HATA: MP4'e çevrilemedi." }
}
Write-Host "Bitti. Videolar: $Cikti"
