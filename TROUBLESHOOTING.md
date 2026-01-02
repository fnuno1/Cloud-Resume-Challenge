# Troubleshooting Log

## Environment Setup
- **Issue:** `node`, `npm`, and `func` not recognized in PowerShell.
- **Resolution:** Reinstalled Node.js LTS with PATH enabled, restarted VS Code/PowerShell.

## Azure Functions Core Tools
- **Issue:** `func` command not found.
- **Resolution:** Installed Core Tools globally via npm. Verified with `func --version` → 4.6.0.

## Project Root Detection
- **Issue:** `func azure functionapp publish` failed with "Unable to find project root".
- **Resolution:** Navigated to `frontend/api` where `host.json` exists.

## Runtime Detection
- **Issue:** Worker runtime was `None`.
- **Resolution:** Published with explicit runtime flag `--python`.

## Python Version Warning
- **Issue:** Local Python version mismatch with Azure Function App (`Python|3.11`).
- **Resolution:** Allowed remote build to succeed. Future fix: install Python 3.11 locally.

## Deployment Success
- **Outcome:** Remote build completed, triggers synced. Function `GetResumeCounter` live at:

## Deployment Success
- **Outcome:** Remote build completed, triggers synced. Function `GetResumeCounter` live at:
        https://fabian-resume-api.azurewebsites.net/api/getresumecounter