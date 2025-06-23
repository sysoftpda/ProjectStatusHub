# ====================================================================
# Název skriptu : confirm_project.ps1
# Účel          : Potvrzení a odeslání commit změn vybraného projektu
#
# ✦ Funkce:
#   - Načte commit_summary.md
#   - Zeptá se na potvrzení a provede git commit + push
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
$summaryPath = Join-Path $projectPath ".devtracker\commit_summary.md"

if (-not (Test-Path $summaryPath)) {
    Write-Warning "❌ Soubor commit_summary.md nebyl nalezen. Spusť nejprve end_project.ps1"
    Write-Host "`n[Enter] pro návrat..." -ForegroundColor DarkGray
    [void][System.Console]::ReadLine()
    exit
}

Clear-Host
Write-Host "📄 Náhled commit_summary.md" -ForegroundColor Cyan
Write-Host "──────────────────────────────────────────────────────"
Get-Content $summaryPath -TotalCount 30
Write-Host "..." -ForegroundColor DarkGray
Write-Host "──────────────────────────────────────────────────────"
Write-Host ""
# Otevřít editor pro revizi commit_summary.md
Write-Host "`n📝 Otevírám commit_summary.md pro případnou úpravu..." -ForegroundColor Cyan
Start-Process notepad.exe -Wait $summaryPath

# Potvrzení po úpravě
$go = Read-Host "✅ Uložený commit_summary.md odeslat do repozitáře? (A/N)"
if ($go -ne "A" -and $go -ne "a") {
    Write-Host "`n❎ Operace zrušena." -ForegroundColor Yellow
    Write-Host "`n[Enter] pro návrat..." -ForegroundColor DarkGray
    [void][System.Console]::ReadLine()
    exit
}

Push-Location $projectPath

git add . | Out-Null
$commitMessage = "Update – $projectName @ $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git commit -m $commitMessage
git push

Pop-Location

# Aktualizuj status
$statusObj = [PSCustomObject]@{
    Stav = "✅ Commit odeslán"
    PosledniZmena = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
}

$statusObj | ConvertTo-Json -Depth 2 | Set-Content -Path $statusFile -Encoding UTF8

Write-Host "`n🚀 Změny commitnuty a odeslány do vzdáleného repozitáře" -ForegroundColor Green
Write-Host "🧾 Commit message: $commitMessage"
Write-Host "`n[Enter] pro návrat..." -ForegroundColor DarkGray
[void][System.Console]::ReadLine()