# ====================================================================
# Název skriptu : menu.ps1
# Účel          : Interaktivní přehled a správa více Git projektů
#
# ✦ Funkce:
#   - Zobrazuje seznam známých repozitářů
#   - Umožňuje spustit start/end/confirm skripty pro daný projekt
#
# Autor         : Petr Kroča
# Vytvořeno     : 2025-06-24
# ====================================================================

# === Přepnutí do PowerShell 7, pokud běžíme v PowerShell 5 ===
if ($PSVersionTable.PSVersion.Major -lt 7) {
    $pwshPath = "$env:ProgramFiles\PowerShell\7\pwsh.exe"
    if (Test-Path $pwshPath) {
        Write-Host "⚙️ Přepínám do PowerShell 7 ($pwshPath)..." -ForegroundColor Cyan
        & $pwshPath -NoLogo -NoProfile -File $PSCommandPath
        return
    } else {
        Write-Warning "❌ PowerShell 7 nebyl nalezen na $pwshPath"
        Write-Host "⚠️ Doporučeno: stáhni jej z https://aka.ms/pwsh"
        Write-Host "`n[Enter] pro návrat..." -ForegroundColor DarkGray
        [void][System.Console]::ReadLine()
        return
    }
}

Clear-Host

$repoJson = Join-Path $PSScriptRoot "data\repos.json"
$statusDir = Join-Path $PSScriptRoot "status"
$scripts = Join-Path $PSScriptRoot "scripts"

# 🔄 Automatické generování repos.json při každém spuštění
Write-Host "🔍 Aktualizuji seznam repozitářů..." -ForegroundColor Cyan

$roots = @($PSScriptRoot, (Join-Path $PSScriptRoot ".." | Resolve-Path | Select-Object -ExpandProperty Path))
$repos = @()

foreach ($root in $roots) {
    if (Test-Path (Join-Path $root ".git")) {
        $repos += [PSCustomObject]@{
            Nazev = Split-Path $root -Leaf
            Cesta = $root
            Stav  = "⏳ Bez akce"
            PosledniZmena = $null
        }
    }

    $repos += Get-ChildItem -Path $root -Directory -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName ".git") } |
        ForEach-Object {
            [PSCustomObject]@{
                Nazev = Split-Path $_.FullName -Leaf
                Cesta = $_.FullName
                Stav  = "⏳ Bez akce"
                PosledniZmena = $null
            }
        }
}

# Odstranit duplicity podle cesty
$repos = $repos | Sort-Object Cesta -Unique

if (-not (Test-Path (Split-Path $repoJson))) {
    New-Item -ItemType Directory -Path (Split-Path $repoJson) -Force | Out-Null
}

$repos | ConvertTo-Json -Depth 2 | Set-Content -Path $repoJson -Encoding UTF8

    Write-Host "✅ Vygenerováno repos.json s $($repos.Count) repozitář(i)" -ForegroundColor Green


while ($true) {
    Clear-Host

    try {
        $raw = Get-Content $repoJson -Raw -ErrorAction Stop
        $repoList = $raw | ConvertFrom-Json
    } catch {
        Write-Warning "❌ Chyba při načítání 'repos.json': $_"
        Write-Host "`n[Enter] pro návrat..." -ForegroundColor DarkGray
        [void][System.Console]::ReadLine()
        return
    }

    if ($repoList -isnot [System.Collections.IEnumerable] -or $repoList -is [PSCustomObject]) {
        $repoList = @($repoList)
    }

    if ($repoList.Count -eq 0) {
        Write-Warning "⚠️ V seznamu projektů není nic evidováno."
        Write-Host "`n[Enter] pro návrat..." -ForegroundColor DarkGray
        [void][System.Console]::ReadLine()
        return
    }

    Write-Host "📁 PROJECT STATUS HUB – PŘEHLED REPOZITÁŘŮ `n" -ForegroundColor Cyan

    $index = 1
    $repoList | ForEach-Object {
        $nazev = $_.Nazev
        $cesta = $_.Cesta

        $statusFile = Join-Path $statusDir "$nazev.json"
        $stav = "⏳ Neznámý"
        $zmena = ""

        if (Test-Path $statusFile) {
            try {
                $data = Get-Content $statusFile -Raw | ConvertFrom-Json
                $stav = $data.Stav
                $zmena = $data.PosledniZmena
            } catch {
                $stav = "⚠️ Chyba dat"
            }
        }

        Write-Host (" $index) " + $nazev.PadRight(25) + "$stav".PadRight(20) + $zmena) -ForegroundColor Yellow
        $index++
    }

    Write-Host "`nZvol číslo projektu, nebo X pro konec:"
    $volba = Read-Host "Volba"

    if ($volba -eq "X") {
        Write-Host "`n👋 Ukončeno"
        Write-Host "`n[Enter] pro ukončení..." -ForegroundColor DarkGray
        [void][System.Console]::ReadLine()
        break
    }

    [int]$zvoleno = $volba
    if ($zvoleno -gt 0 -and $zvoleno -le $repoList.Count) {
        $proj = $repoList[$zvoleno - 1]
        Write-Host "`n👉 Zvolen projekt: $($proj.Nazev)`n"

        Write-Host "  1) ▶️ Spustit práci (start)"
        Write-Host "  2) ⏹️ Ukončit práci (end)"
        Write-Host "  3) ✅ Potvrdit commit (confirm)"
        $akce = Read-Host "Zvol akci"

        switch ($akce) {
            "1" { . (Join-Path $scripts "start_project.ps1") $proj.Cesta }
            "2" { . (Join-Path $scripts "end_project.ps1") $proj.Cesta }
            "3" { . (Join-Path $scripts "confirm_project.ps1") $proj.Cesta }
            default { Write-Warning "❌ Neplatná akce." }
        }

        Write-Host "`n[Enter] pro návrat do menu..." -ForegroundColor DarkGray
        [void][System.Console]::ReadLine()
    } else {
        Write-Warning "❌ Neplatný výběr."
        Write-Host "`n[Enter] pro návrat..." -ForegroundColor DarkGray
        [void][System.Console]::ReadLine()
    }
}