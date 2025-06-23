# 📝 Commit Summary – ProjectStatusHub

**Datum:** 2025-06-23 16:10:00

## 🔢 Statistiky změn

- Změněno souborů: 2
- Přidáno řádků: 44
- Odstraněno řádků: 5

## 🗂️ Změněné soubory

– $file (+6 / -0)
– $file (+38 / -5)

## 📂 Git Status
```
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   data/repos.json
	modified:   menu.ps1

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.devtracker/
	status/ProjectStatusHub.json

no changes added to commit (use "git add" and/or "git commit -a")

```

## ➕ Přidané řádky (náhled)
```diff
+  },
+  {
+    "Nazev": "ProjectStatusHub",
+    "Cesta": "C:\\Scripts\\ProjectStatusHub",
+    "Stav": "⏳ Bez akce",
+    "PosledniZmena": null
+# 🔄 Automatické generování repos.json při každém spuštění
+Write-Host "🔍 Aktualizuji seznam repozitářů..." -ForegroundColor Cyan
+
+$roots = @($PSScriptRoot, (Join-Path $PSScriptRoot ".." | Resolve-Path | Select-Object -ExpandProperty Path))
+$repos = @()
+
+foreach ($root in $roots) {
+    if (Test-Path (Join-Path $root ".git")) {
+        $repos += [PSCustomObject]@{
+            Nazev = Split-Path $root -Leaf
+            Cesta = $root
+            Stav  = "⏳ Bez akce"
+            PosledniZmena = $null
+        }
```

## 🧾 Git Diff
```diff
diff --git a/data/repos.json b/data/repos.json
index 1fa6cda..bf04abd 100644
--- a/data/repos.json
+++ b/data/repos.json
@@ -4,5 +4,11 @@
     "Cesta": "C:\\Scripts\\Knihovnik_2.0",
     "Stav": "⏳ Bez akce",
     "PosledniZmena": null
+  },
+  {
+    "Nazev": "ProjectStatusHub",
+    "Cesta": "C:\\Scripts\\ProjectStatusHub",
+    "Stav": "⏳ Bez akce",
+    "PosledniZmena": null
   }
 ]
diff --git a/menu.ps1 b/menu.ps1
index 8b1854f..42f7ab0 100644
--- a/menu.ps1
+++ b/menu.ps1
@@ -32,13 +32,46 @@ $repoJson = Join-Path $PSScriptRoot "data\repos.json"
 $statusDir = Join-Path $PSScriptRoot "status"
 $scripts = Join-Path $PSScriptRoot "scripts"
 
-if (-not (Test-Path $repoJson)) {
-    Write-Warning "⛔ Soubor repos.json nenalezen. Spusť nejprve vytvor_hub.ps1"
-    Write-Host "`n[Enter] pro návrat..." -ForegroundColor DarkGray
-    [void][System.Console]::ReadLine()
-    return
+# 🔄 Automatické generování repos.json při každém spuštění
+Write-Host "🔍 Aktualizuji seznam repozitářů..." -ForegroundColor Cyan
+
+$roots = @($PSScriptRoot, (Join-Path $PSScriptRoot ".." | Resolve-Path | Select-Object -ExpandProperty Path))
+$repos = @()
+
+foreach ($root in $roots) {
+    if (Test-Path (Join-Path $root ".git")) {
+        $repos += [PSCustomObject]@{
+            Nazev = Split-Path $root -Leaf
+            Cesta = $root
+            Stav  = "⏳ Bez akce"
+            PosledniZmena = $null
+        }
+    }
+
+    $repos += Get-ChildItem -Path $root -Directory -Recurse -Force -ErrorAction SilentlyContinue |
+        Where-Object { Test-Path (Join-Path $_.FullName ".git") } |
+        ForEach-Object {
+            [PSCustomObject]@{
+                Nazev = Split-Path $_.FullName -Leaf
+                Cesta = $_.FullName
+                Stav  = "⏳ Bez akce"
+                PosledniZmena = $null
+            }
+        }
 }
 
+# Odstranit duplicity podle cesty
+$repos = $repos | Sort-Object Cesta -Unique
+
+if (-not (Test-Path (Split-Path $repoJson))) {
+    New-Item -ItemType Directory -Path (Split-Path $repoJson) -Force | Out-Null
+}
+
+$repos | ConvertTo-Json -Depth 2 | Set-Content -Path $repoJson -Encoding UTF8
+
+    Write-Host "✅ Vygenerováno repos.json s $($repos.Count) repozitář(i)" -ForegroundColor Green
+
+
 while ($true) {
     Clear-Host
 

```
