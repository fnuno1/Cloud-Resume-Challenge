# Cloud Resume Challenge — Project Notes
# ============================================================
# Author:      Fabian Nuno
# Org:         dev.azure.com/nufaze84
# Project:     Cloud_Resume-Challenge
# Live URL:    https://fabianresume.dev
# Last Updated: July 22, 2026
# ============================================================
#
# PURPOSE OF THIS DOCUMENT:
# This is a living notes document that tracks every significant
# decision, change, problem, and solution made to this project.
# Update this file every time a meaningful change is made to
# the repo, pipeline, or Azure infrastructure.
#
# This document serves three purposes:
#   1. Personal runbook — so you can recreate this from scratch
#   2. Troubleshooting reference — documents what went wrong and why
#   3. Portfolio artifact — demonstrates engineering decision-making
# ============================================================

---

## Project Overview

The Cloud Resume Challenge is a personal resume website built
on Azure. It demonstrates real cloud engineering skills by
hosting a static resume site with a serverless visitor counter
backend, custom domain, HTTPS, and a full CI/CD pipeline.

### Architecture

```
Browser
  └── Custom Domain (fabianresume.dev)
        └── Azure Static Web App (fabian-resume-site)
              ├── frontend/index.html   — resume HTML
              ├── frontend/style.css    — stylesheet
              └── frontend/images/      — cert logos, icons
                    └── JavaScript fetch → Azure Function App (fabian-resume-api)
                          └── GetResumeCounter (HTTP trigger, Python)
                                └── Azure Cosmos DB — visitor count storage
```

### Azure Resources

| Resource | Name | Resource Group | Notes |
|---|---|---|---|
| Static Web App | fabian-resume-site | cloud-resume-challenge | Hosts the frontend |
| Function App | fabian-resume-api | cloud-resume-challenge | Visitor counter backend |
| Cosmos DB | (linked to Function App) | cloud-resume-challenge | Stores visitor count |
| Custom Domain | fabianresume.dev | — | Purchased via Namecheap, DNS on Azure |

### Azure DevOps

| Item | Value |
|---|---|
| Organization | dev.azure.com/nufaze84 |
| Project | Cloud_Resume-Challenge |
| Repo | Cloud_Resume-Challenge |
| Pipeline | Cloud_Resume-Challenge |
| Variable Group | cloud-resume-secrets |
| Environment | production |

---

## Session Log

---

### July 22, 2026 — Initial Migration to Azure DevOps

#### Background

The project originally lived on a flash drive (D:\Cloud-Resume-Challenge)
and deployed to Azure Static Web Apps via GitHub Actions from:
  github.com/fnuno1/Cloud-Resume-Challenge

The goal was to migrate the deployment pipeline from GitHub Actions
to Azure DevOps, enabling Agile work item tracking, PR-linked user
stories, and a custom multi-stage YAML pipeline with approval gates.

---

#### Step 1 — Fix git safe directory error

The repo lived on a flash drive (D:\) which does not record file
ownership. Git blocks operations on repos from filesystems that
don't record ownership as a security measure.

**Fix:**
Run in VS Code terminal (D:\Cloud-Resume-Challenge):
```powershell
git config --global --add safe.directory D:/Cloud-Resume-Challenge
```

**Why this matters:**
This is a Windows security behavior — not a git bug. Any repo on
an external drive or network share may require this fix.

---

#### Step 2 — Redirect git remote from GitHub to Azure DevOps

The repo was pointed at GitHub. We needed to redirect it to the
new Azure DevOps repo without losing any commit history.

**Commands run in VS Code terminal (D:\Cloud-Resume-Challenge):**
```powershell
# Remove the GitHub remote
git remote remove origin

# Add the Azure DevOps remote
git remote add origin https://nufaze84@dev.azure.com/nufaze84/Cloud_Resume-Challenge/_git/Cloud_Resume-Challenge

# Verify
git remote -v
```

---

#### Step 3 — Add .gitattributes to enforce LF line endings

**Problem:** Moving to Azure DevOps on Windows causes git to
automatically convert LF line endings to CRLF on checkout.
This corrupts unicode characters in HTML and PowerShell files
(em dashes, bullet characters, pipe symbols) — a lesson learned
from the TSS IT Automation project.

**Fix:** Add a .gitattributes file BEFORE any other commits that
enforces LF for all text files and marks binary files correctly.
This must be the FIRST commit — if you commit other files first,
git has already applied its default CRLF conversion.

**.gitattributes rules applied:**
```
*.html    eol=lf
*.css     eol=lf
*.js      eol=lf
*.json    eol=lf
*.yml     eol=lf
*.yaml    eol=lf
*.md      eol=lf
*.png     binary
*.jpg     binary
*.gif     binary
*.ico     binary
```

**Push sequence (order matters):**
```powershell
# Stage .gitattributes FIRST
git add .gitattributes
git commit -m "Add .gitattributes to enforce LF line endings"

# Then stage everything else
git add .
git commit -m "Initial commit: frontend, pipeline, and repo structure"

# Push — force was required because Azure DevOps auto-generated
# a default README that conflicted with our local history
git push -u origin main --force
```

**Note on force push:** The --force flag was safe here because
the only content on the remote was the auto-generated Azure DevOps
README placeholder. Never force push to a shared repo with real
commit history.

---

#### Step 4 — Add inline comments to all code files

Using the Windows MCP filesystem connector, Claude added thorough
inline comments to all three files explaining every decision:

- azure-pipelines.yml — pipeline stages, conditions, variable group usage
- frontend/index.html — every HTML element, section, class, and the JS fetch
- frontend/style.css  — every CSS token, selector, and design decision

**Why this matters:**
Inline comments make code readable to anyone reviewing it —
including future hiring managers looking at the portfolio.
It also demonstrates the AZ-400 principle of documentation
as part of the DevOps process, not an afterthought.

---

#### Step 5 — Create Variable Group for secrets

Secrets must never be hardcoded in YAML. The deployment token
grants write access to the production Static Web App — if it
leaked into source code it would be a security vulnerability.

**Setup:**
- Azure DevOps → Pipelines → Library → + Variable group
- Name: `cloud-resume-secrets`
- Description: Secrets for the Cloud Resume Challenge CI/CD pipeline.
  Contains the Azure Static Web Apps deployment token for
  fabian-resume-site (fabianresume.dev). Token authenticates the
  pipeline agent to deploy frontend files without storing credentials
  in code. Managed by nufaze84.
- Variable: `AZURE_STATIC_WEB_APPS_API_TOKEN` (marked secret 🔒)
- Pipeline permissions: authorized for Cloud_Resume-Challenge pipeline

**Important:** The variable group name in the YAML must match
exactly — casing and spacing included. Our first run failed
because the group was named "Cloud -Resume-Secret" (with a space)
while the YAML referenced "cloud-resume-secrets". Always verify
the name matches before running.

---

#### Step 6 — Create Production Environment with Approval Gate

The "production" environment in Azure DevOps adds a manual approval
gate before any deployment goes live. This means even if all
validation passes, no files reach the live site until you explicitly
approve the deployment.

**Setup:**
- Azure DevOps → Pipelines → Environments → New environment
- Name: `production` (must match the environment: field in the YAML)
- Resource: None
- Approvals and checks → + Approvals
- Required approver: nufaze84
- Timeout: 3 days (4320 minutes) — auto-cancels if not approved

**Why 3 days:**
Long enough to not rush approvals, short enough that deployments
don't sit in limbo indefinitely. For a real production app at a
company this would typically be 4-8 hours.

---

#### Step 7 — First Pipeline Run

**Validate stage:** All checks passed green in 3 seconds.
- ✅ Verify required files exist
- ✅ Internal reference checks
- ✅ File size sanity check

**Deploy stage:** FAILED. Multiple attempts, same error:
```
The content server has rejected the request with: BadRequest
Reason: No matching Static Web App was found or the api key was invalid.
```

---

#### Step 8 — Troubleshooting the Deploy Failure

This was the most complex part of the session. Full diagnostic
journey documented here for reference.

**Attempt 1 — Assumed wrong token**
Reset the deployment token in Azure Portal → Manage deployment token.
Updated the variable group with the new token. Still failed.

**Attempt 2 — Added production_branch parameter to task**
Added `production_branch: 'main'` to the AzureStaticWebApp@0 task
inputs to give it explicit context about which environment to target.
Still failed with the same error.

**Root cause identified:**
The Static Web App was configured with GitHub as its deployment
authority (Deployment authorization policy = GitHub in the
Configuration blade). Azure enforces this at the platform level —
any token-based deployment from a non-GitHub source is rejected
regardless of whether the token is valid.

**Attempt 3 — Disconnect GitHub via Azure Portal**
The Configuration blade showed the Deployment authorization policy
radio button but it was grayed out — Azure locks it when GitHub
is the active source. Clicking "Change account" opened a GitHub
OAuth flow which would have deepened the GitHub connection, not
removed it. We cancelled that.

**Attempt 4 — Disconnect via Azure CLI**
Run in Azure Cloud Shell (PS /home/fabian):
```bash
az staticwebapp disconnect \
  --name fabian-resume-site \
  --resource-group cloud-resume-challenge
```

This successfully removed the GitHub connection. The Configuration
blade confirmed the Deployment configuration section disappeared
entirely — the Static Web App was now in a "no source" state.

**New problem discovered:**
After disconnecting, the AzureStaticWebApp@0 task still failed.
Further research revealed that Azure Static Web Apps was designed
with the assumption that it is always connected to a source control
system. The AzureStaticWebApp@0 task requires an active repo
linkage — even a valid token cannot override this platform constraint
for a disconnected Static Web App.

**Decision: Switch to SWA CLI**
The Azure Static Web Apps CLI (swa deploy) authenticates purely
via deployment token with no repository linkage required. This is
the correct tool for custom CI/CD pipelines that operate outside
of Azure's managed deployment system.

The original AzureStaticWebApp@0 task is preserved in the YAML
as a commented-out reference with a full explanation of why it
was replaced.

---

#### Step 9 — Switch Deploy Method to SWA CLI

Updated azure-pipelines.yml to replace AzureStaticWebApp@0 with
the SWA CLI deploy steps:

```yaml
# Install SWA CLI
- script: |
    npm install -g @azure/static-web-apps-cli@latest
    swa --version
  displayName: 'Install SWA CLI'

# Deploy using token-only authentication
- script: |
    swa deploy $(frontendPath) \
      --env production \
      --deployment-token $(AZURE_STATIC_WEB_APPS_API_TOKEN)
  displayName: 'Deploy via SWA CLI'
```

**Why SWA CLI works where the task did not:**
The task is a wrapper around Azure's managed deployment system
which requires repo registration. The SWA CLI is a direct API
client that sends files to the Static Web App's content endpoint
using only the deployment token — no repo registration needed.

---

## Pending Items

- [ ] Confirm SWA CLI deploy succeeds end-to-end
- [ ] Add AZ-400 and AZ-204 badge PNG files to frontend/images/
- [ ] Update AZ-204 Credly URL in index.html with correct share link
- [ ] Set up branch policy on main (require PR, require linked work item)
- [ ] Delete old index3.html and style3.css backup files from frontend/
- [ ] Test full pipeline flow: feature branch → PR → Validate → merge → Deploy

---

## Key Lessons Learned

1. **Platform constraints vs. YAML issues** — Always distinguish between
   a problem in your pipeline code and a constraint enforced by the
   Azure platform itself. The deploy failure was not a YAML problem.

2. **Safest approach first** — Before making destructive changes (deleting
   files, disconnecting sources), try every non-destructive option first.
   Document your reasoning at each step.

3. **.gitattributes must be first** — On Windows, LF/CRLF corruption is
   real. The .gitattributes file must be committed before any other files
   or git will have already applied its default conversion.

4. **Variable group naming is exact** — One space in the wrong place
   causes a pipeline authorization failure that looks like a permissions
   error. Always verify the exact name matches the YAML reference.

5. **Comments are documentation** — Keeping the AzureStaticWebApp@0 task
   as a commented-out reference with an explanation is better than
   deleting it. Anyone reading the pipeline can understand the history.

---

## Reference Commands

### Git (run in VS Code terminal at D:\Cloud-Resume-Challenge)
```powershell
# Add git to PATH for this session (flash drive limitation)
$env:PATH += ";C:\Program Files\Git\cmd"

# Check current remote
git remote -v

# Stage and commit
git add <file>
git commit -m "message"
git push origin main
```

### Azure CLI (run in Azure Cloud Shell at PS /home/fabian)
```bash
# Check Static Web App status
az staticwebapp show \
  --name fabian-resume-site \
  --resource-group cloud-resume-challenge \
  --query "{name:name, repositoryUrl:repositoryUrl, branch:branch}" \
  --output table

# Disconnect source control
az staticwebapp disconnect \
  --name fabian-resume-site \
  --resource-group cloud-resume-challenge
```

### SWA CLI (used in pipeline — reference only)
```bash
# Install
npm install -g @azure/static-web-apps-cli@latest

# Deploy
swa deploy frontend/ \
  --env production \
  --deployment-token <token>
```