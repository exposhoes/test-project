# EmirCRAFT bölümlerini otomatik videoya kaydeder (Godot Movie Maker).
# Kullanım: tools\kayit.ps1            -> tüm bölümler
#           tools\kayit.ps1 sinav lav  -> sadece bu bölümler
# Videolar "videolar\" klasörüne <bölüm>.avi olarak yazılır. Shorts dikey (720x1280), uzunlar yatay (1280x720).
$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$root = Split-Path -Parent $PSScriptRoot
$godot = if ($env:GODOT) { $env:GODOT } else { (Get-ChildItem "D:\Godot\Godot_v*_console.exe" | Sort-Object Name | Select-Object -Last 1).FullName }
$out = Join-Path $root "videolar"
New-Item -ItemType Directory -Force $out | Out-Null

# Bölüm listesi ve formatları episodes.gd'den okunur.
$text = Get-Content (Join-Path $root "scripts\film\episodes.gd") -Raw -Encoding UTF8
$eps = [regex]::Matches($text, '"id":\s*"([a-z0-9_]+)"[^\n]*') | ForEach-Object {
	$long = $_.Value -match '"format":\s*"long"'
	[pscustomobject]@{ Id = $_.Groups[1].Value; Long = $long }
}
if ($args.Count -gt 0) { $eps = $eps | Where-Object { $args -contains $_.Id } }

foreach ($e in $eps) {
	$res = if ($e.Long) { "1280x720" } else { "720x1280" }
	$file = Join-Path $out "$($e.Id).avi"
	Write-Host "Kaydediliyor: $($e.Id) ($res)"
	& $godot --path $root --resolution $res --fixed-fps 30 --write-movie $file res://scenes/film.tscn -- "--bolum=$($e.Id)" | Out-Null
}
Write-Host "Bitti. Videolar: $out"
