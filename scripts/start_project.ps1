# ====================================================================
# Název skriptu : start_project.ps1
# Účel          : Spuštění práce na konkrétním projektu (uložení snapshotu)
#
# ✦ Funkce:
#   - Ověří Git repozitář
#   - Uloží snapshot startovní verze
#   - Zaznamená začátek práce v status.json
#
# Autor         : Petr Kroča
# Vytvořeno     : 2025-06-24
# ====================================================================

param (
    [Parameter(Mandatory = $true)]
    [string]$projectPath
)

$root = Split-Path $PSScriptRoot -Parent
$statusDir = Join-Path $root "status"
$projectName = Split-Path $projectPath -Leaf
$statusFile = Join-Path $statusDir "$projectName.json"

if (-not (Test-Path "$projectPath\.git")) {
    Write-Warning "❌ Cesta '$projectPath' není Git repozitář."
    Write-Host "`n[Enter] pro návrat..." -ForegroundColor DarkGray
    [void][System.Console]::ReadLine()
    exit
}

$snapshotDir = Join-Path $projectPath ".devtracker\start_snapshot"
if (-not (Test-Path $snapshotDir)) {
    New-Item $snapshotDir -ItemType Directory -Force | Out-Null
}

# Git snapshot
Push-Location $projectPath
git status > "$snapshotDir\status.txt"
git diff > "$snapshotDir\diff.txt"
Pop-Location

# Záznam do status souboru
$statusObj = [PSCustomObject]@{
    Stav = "🟢 Rozpracováno"
    PosledniZmena = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
}

$statusObj | ConvertTo-Json -Depth 2 | Set-Content -Path $statusFile -Encoding UTF8

Write-Host "`n✅ Projekt '$projectName' označen jako ROZPRACOVANÝ" -ForegroundColor Green
Write-Host "📄 Snapshot uložen do: .devtracker\start_snapshot" -ForegroundColor Cyan
Write-Host "`n[Enter] pro návrat..." -ForegroundColor DarkGray
[void][System.Console]::ReadLine()