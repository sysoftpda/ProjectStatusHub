# ====================================================================
# Název skriptu : vytvor_hub.ps1
# Účel          : Vytvoří strukturu pro Project Status Hub a inicializační skripty
#
# ✦ Funkce:
#   - Vytvoří složky: modules, scripts, data, status
#   - Vygeneruje základní .ps1 a .psm1 soubory s hlavičkami
#   - Prohledá sousední adresáře a uloží seznam git repozitářů
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
        exit
    } else {
        Write-Warning "❌ PowerShell 7 nebyl nalezen na $pwshPath"
        Write-Host "⚠️ Doporučeno: stáhni jej z https://aka.ms/pwsh"
        Write-Host "`n[Enter] pro návrat..." -ForegroundColor DarkGray
        [void][System.Console]::ReadLine()
        exit
    }
}

$root = $PSScriptRoot
$subFolders = "modules", "scripts", "data", "status"

foreach ($f in $subFolders) {
    $path = Join-Path $root $f
    if (-not (Test-Path $path)) {
        New-Item $path -ItemType Directory | Out-Null
        Write-Host "✅ Vytvořeno: $f" -ForegroundColor Green
    }
}

# -- Vytvoření souborů se základní hlavičkou --

$files = @{
    "scripts\menu.ps1" = @"
# ====================================================================
# Název skriptu : menu.ps1
# Účel          : Interaktivní přehled a správa více Git projektů
#
# ✦ Funkce:
#   - Zobrazuje seznam známých projektů
#   - Zobrazuje status (např. rozpracováno, commitnuto)
#   - Umožňuje spustit start/end/confirm skripty pro daný projekt
#
# Autor         : Petr Kroča
# Vytvořeno     : 2025-06-24
# ====================================================================

"@;

    "scripts\start_project.ps1" = @"
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

"@;

    "scripts\end_project.ps1" = @"
# ====================================================================
# Název skriptu : end_project.ps1
# Účel          : Uloží snapshot po práci a připraví commit summary
#
# ✦ Funkce:
#   - Porovná se start snapshotem
#   - Zaznamená změny a připraví commit_summary.md
#
# Autor         : Petr Kroča
# Vytvořeno     : 2025-06-24
# ====================================================================

"@;

    "scripts\confirm_project.ps1" = @"
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

"@;

    "modules\RepoStatus.psm1" = @"
# ====================================================================
# Název souboru : RepoStatus.psm1
# Účel          : Správa seznamu projektů a jejich stavů
#
# ✦ Funkce:
#   - Get-RepoList
#   - Add-Repo
#   - Update-RepoStatus
#   - Load-Status / Save-Status
#
# Autor         : Petr Kroča
# Vytvořeno     : 2025-06-24
# ====================================================================

"@
}

foreach ($entry in $files.GetEnumerator()) {
    $filePath = Join-Path $root $entry.Key
    if (-not (Test-Path $filePath)) {
        $entry.Value | Set-Content -Path $filePath -Encoding UTF8
        Write-Host "📄 Vytvořen soubor: $($entry.Key)" -ForegroundColor Cyan
    }
}

# -- Prohledání okolních složek a sestavení seznamu projektů --

$parent = Split-Path $root -Parent
# Vynucené pole pomocí statického [object[]] přetypování
$repoList = @()

Get-ChildItem -Path $parent -Directory | Where-Object {
    $hasGit = Test-Path "$($_.FullName)\.git"
    $ignored = Test-Path "$($_.FullName)\noGIT"
    return $hasGit -and (-not $ignored)
} | ForEach-Object {
    $repoList += [PSCustomObject]@{
        Nazev = $_.Name
        Cesta = $_.FullName
        Stav  = "⏳ Bez akce"
        PosledniZmena = $null
    }
}

# 💡 Zde vytvoříme generic list, který ConvertTo-Json nezamění za objekt
$typedList = New-Object 'System.Collections.Generic.List[Object]'
$repoList | ForEach-Object { [void]$typedList.Add($_) }

$typedList | ConvertTo-Json -Depth 2 -AsArray | Set-Content "$root\data\repos.json" -Encoding UTF8
Write-Host "`n📦 Detekováno projektů: $($typedList.Count) → uloženo do data\repos.json" -ForegroundColor Yellow

Write-Host "`n✅ Project Status Hub připraven!" -ForegroundColor Green
Write-Host "`n[Enter] pro ukončení..." -ForegroundColor DarkGray
[void][System.Console]::ReadLine()