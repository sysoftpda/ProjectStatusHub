# ====================================================================
# Název skriptu : end_project.ps1
# Účel          : Uloží snapshot po práci a připraví commit summary
#
# ✦ Funkce:
#   - Porovná se start snapshotem
#   - Zaznamená změny a připraví commit_summary.md (se statistikami)
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

$devDir = Join-Path $projectPath ".devtracker"
$startSnapshot = Join-Path $devDir "start_snapshot"
$endSnapshot   = Join-Path $devDir "end_snapshot"
$summaryPath   = Join-Path $devDir "commit_summary.md"

if (-not (Test-Path $startSnapshot)) {
    Write-Warning "⚠️ Nebyl nalezen počáteční snapshot. Spusť nejprve start_project.ps1"
    Write-Host "`n[Enter] pro návrat..." -ForegroundColor DarkGray
    [void][System.Console]::ReadLine()
    exit
}

# Ulož aktuální snapshot
if (-not (Test-Path $endSnapshot)) {
    New-Item $endSnapshot -ItemType Directory -Force | Out-Null
}

Push-Location $projectPath

git status > "$endSnapshot\status.txt"
git diff > "$endSnapshot\diff.txt"
git diff --name-status > "$endSnapshot\filestatus.txt"
git diff --numstat > "$endSnapshot\numstat.txt"

Pop-Location

# Načti diffy a stav
$diff = Get-Content "$endSnapshot\diff.txt" -Raw
$status = Get-Content "$endSnapshot\status.txt" -Raw
$nameStat = Get-Content "$endSnapshot\filestatus.txt"
$numStat = Get-Content "$endSnapshot\numstat.txt"

# Výpis souborů + změnové statistiky
$changedFiles = @()
$totalAdded = 0
$totalRemoved = 0

foreach ($line in $numStat) {
    $parts = $line -split "\t"
    if ($parts.Length -eq 3) {
        $added = [int]$parts[0]
        $removed = [int]$parts[1]
        $file = $parts[2]

        $changedFiles += "– `$file` (+$added / -$removed)"
        $totalAdded += $added
        $totalRemoved += $removed
    }
}

# Vytáhni přidané řádky z diffu
$addedLines = $diff -split "`n" | Where-Object { $_ -like '+*' -and ($_ -notlike '+++*') }
$addedLines = $addedLines | Select-Object -First 20

# Sestav commit summary
$lines = @()
$lines += "# 📝 Commit Summary – $projectName"
$lines += ""
$lines += "**Datum:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$lines += ""
$lines += "## 🔢 Statistiky změn"
$lines += ""
$lines += "- Změněno souborů: $($changedFiles.Count)"
$lines += "- Přidáno řádků: $totalAdded"
$lines += "- Odstraněno řádků: $totalRemoved"
$lines += ""
$lines += "## 🗂️ Změněné soubory"
$lines += ""
$lines += $changedFiles
$lines += ""
$lines += "## 📂 Git Status"
$lines += '```'
$lines += $status
$lines += '```'
$lines += ""
$lines += "## ➕ Přidané řádky (náhled)"
$lines += '```diff'
$lines += $addedLines
$lines += '```'
$lines += ""
$lines += "## 🧾 Git Diff"
$lines += '```diff'
$lines += $diff
$lines += '```'

$lines | Set-Content -Path $summaryPath -Encoding UTF8

# Uložení statusu
$statusObj = [PSCustomObject]@{
    Stav = "🟡 Připraveno k potvrzení"
    PosledniZmena = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
}

$statusObj | ConvertTo-Json -Depth 2 | Set-Content -Path $statusFile -Encoding UTF8

Write-Host "`n✅ Projekt '$projectName' označen jako HOTOVO k potvrzení" -ForegroundColor Green
Write-Host "📝 commit_summary.md připraven v .devtracker" -ForegroundColor Cyan
Write-Host "`n[Enter] pro návrat..." -ForegroundColor DarkGray
[void][System.Console]::ReadLine()