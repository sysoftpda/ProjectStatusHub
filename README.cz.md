# 📦 Project Status Hub

Lehký nástroj v PowerShellu pro přehlednou správu více Git projektů.  
Ideální pro každodenní vývoj – v práci, týmu i osobních repozitářích.

---

## ✨ Funkce

- 🔍 Automatická detekce projektů s `.git` a ignorování výjimek.
- 🟢 Start: uloží počáteční snapshot (`git status`, `git diff`).
- 🟡 Ukončení: porovná změny, vygeneruje `commit_summary.md`.
- ✅ Potvrzení: otevře přehled v editoru, umožní úpravu a provede commit a push.
- 📊 Interaktivní menu `menu.ps1` se stavem všech repozitářů.

---

## 📂 Struktura projektu

```
ProjectStatusHub/
├── scripts/
│   ├── menu.ps1
│   ├── start_project.ps1
│   ├── end_project.ps1
│   └── confirm_project.ps1
├── data/
│   └── repos.json
├── status/
│   └── NazevProjektu.json
```

Každý repozitář obsahuje `.devtracker/` se snapshoty a přehledem změn.

---

## ▶️ Jak to funguje

```powershell
.\scripts\menu.ps1
# Vyber projekt
# Spusť → Programuj → Ukonči → Potvrď → Hotovo 🎉
```

---

## 📽️ Animovaný náhled

Doporučený nástroj: [ScreenToGif](https://www.screentogif.com/) nebo OBS.  
Ulož animaci jako `preview.gif` a vlož takto:

```markdown
![Ukázka](preview.gif)
```

---

## 🙏 Poděkování

Autorem je Petr Kroča, nástroj vznikl s pomocí ProjectStatusHub Copilota.  
Používej, upravuj, sdílej – a hlavně, měj radost z dobře řízené práce.