# 📦 Project Status Hub

A lightweight PowerShell tool for managing and tracking the development status of multiple Git repositories.  
Designed for developers who value clarity, control, and simplicity in their daily workflow.

---

## ✨ Features

- 🔍 Auto-detects Git projects from a specified root folder.
- 🟢 Start tracking: saves a snapshot of the working state (`git status`, `git diff`).
- 🟡 End tracking: compares changes, generates a rich `commit_summary.md`.
- ✅ Confirm & Push: opens summary in editor for review, then commits and pushes.
- 📊 Central menu (`menu.ps1`) to view current status of all projects.

---

## 📂 Project Structure

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
│   └── project_name.json
```

Each Git project also stores its metadata inside `.devtracker/`

---

## ▶️ Example Workflow

```powershell
.\scripts\menu.ps1
# Choose project
# Start → Work → End → Confirm → Done 🎉
```

---

## 📽️ Preview

You can record a short terminal demo using tools like [ScreenToGif](https://www.screentogif.com/) or OBS, save it as `preview.gif`, and embed it like this:

```markdown
![Preview](preview.gif)
```

---

## 🙏 Credits

Crafted by Petr Kroča with support from ProjectStatusHub Copilot.  
Use it, fork it, improve it — and enjoy your dev time.