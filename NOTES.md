# Cloud Resume Challenge — Project Notes
# ============================================================
# Author:      Fabian Nuno
# Org:         dev.azure.com/nufaze84
# Project:     Cloud_Resume-Challenge
# Live URL:    https://fabianresume.dev
# Last Updated: July 22, 2026 (afternoon session)
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
| Static Web App | fabian-resume-site | cloud-resume-challenge | Recreated July 22, 2026 |
| Function App | fabian-resume-api | cloud-resume-challenge | Visitor counter backend |
| Cosmos DB | (linked to Function App) | cloud-resume-challenge | Stores visitor count |
| Custom Domain | fabianresume.dev | — | Azure DNS — re-added July 22 |
| Custom Domain | www.fabianresume.dev | — | Azure DNS — re-added July 22 |

### Azure DevOps

| Item | Value |
|---|---|
| Organization | dev.azure.com/nufaze84 |
| Project | Cloud_Resume-Challenge |
| Repo | Cloud_Resume-Challenge |
| Pipeline | Cloud_Resume-Challenge |
| Variable Group | cloud-resume-secrets |
| Environment | production (3-day approval gate) |

### Internal Static Web App URLs

| Version | Hostname |
|---|---|
| Original (deleted) | green-moss-0aa44c60f.2.azurestaticapps.net |
| Current (July 22 recreation) | salmon-pond-0c70b1b0f.7.azurestaticapps.net |

---

## Session Log

---

### July 22, 2026 (Morning) — Initial Migration to Azure DevOps

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

**Fix (VS Code terminal at D:\Cloud-Resume-Challenge):**
```powershell
git config --global --add safe.directory D:/Cloud-Resume-Challenge
```

---

#### Step 2 — Redirect git remote from GitHub to Azure DevOps

```powershell
git remote remove origin
git remote add origin https://nufaze84@dev.azure.com/nufaze84/Cloud_Resume-Challenge/_git/Cloud_Resume-Challenge
git remote -v
```

---

#### Step 3 — Add .gitattributes to enforce LF line endings

Moving to Azure DevOps on Windows causes git to automatically convert
LF to CRLF on checkout, corrupting unicode characters. The .gitattributes
file must be committed FIRST before any other files.

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

---

#### Step 4 — Add inline comments, variable group, environment, pipeline

- Added thorough inline comments to azure-pipelines.yml, index.html, style.css
- Created variable group `cloud-resume-secrets` with `AZURE_STATIC_WEB_APPS_API_TOKEN`
- Created `production` environment with 3-day (4320 minute) approval gate
- Created and ran the pipeline — Validate passed green in 3 seconds

---

#### Step 5 — Deploy failure investigation

**Root cause:** Static Web App was linked to GitHub as its deployment
authority. Azure enforces this at the platform level — token-based
deployments from non-GitHub sources are rejected.

**Attempts made:**
1. Reset deployment token — failed
2. Added production_branch parameter to AzureStaticWebApp@0 task — failed
3. Tried to change Deployment authorization policy in portal — radio button grayed out
4. Ran `az staticwebapp disconnect` in Azure Cloud Shell — disconnected GitHub but
   deployment still failed because the task requires active repo linkage

**Solution: Switch to SWA CLI**
The AzureStaticWebApp@0 task requires repo linkage. The SWA CLI authenticates
via token only with no repo linkage required. Switched deploy method to swa CLI.

---

### July 22, 2026 (Afternoon) — Site Redesign, Static Web App Recreation, Full Deployment

---

#### Step 6 — Frontend redesign

Complete rewrite of index.html and style.css:

**HTML changes:**
- Title changed to "Fabian Nuno — DevOps Engineer"
- Fonts: Roboto → Inter (body) + JetBrains Mono (labels/meta)
- Header rebuilt with eyebrow label, cert title line, bordered icon buttons
- Visitor counter moved into dedicated visitor bar below header
- Summary rewritten — leads with "Certified DevOps Engineer (AZ-400)"
- Experience section: each job now a bordered card with hover effect
- Certifications: rebuilt as single-column list with featured Azure cert rows
- AZ-400 added as top cert, AZ-204 added as second cert
- Education: "Expected 2026" → "2026"
- Footer rebuilt with contact info and tech stack note

**CSS changes:**
- Complete rewrite with CSS custom property design token system
- Dark theme refined: #0d0d0f background, #3b82f6 azure accent
- Card system for job entries with border hover transitions
- Cert item rows with featured class for Azure certs
- Full responsive breakpoint at 600px
- prefers-reduced-motion accessibility support

**Content updates (synced with LCPtracker resume):**
- Azure Administrator bullets updated with exact numbers:
  - 75 → nearly 400 employees
  - 5-stage CI/CD pipeline, 33 Pester tests
  - 30-60 min → under 5 min onboarding
  - 22+ Conditional Access policies, 232+ devices
  - 71.65% Secure Score
  - Hired and trained 4 helpdesk employees
- IT Technician II bullets tightened and clarified

**Cert URLs updated:**
- AZ-400: 28AC06E23317E732 (was incorrectly using AZ-104 URL)
- AZ-204: 830A193D5DCE3793 (was incorrectly using AZ-104 URL)
- AZ-104: BFD78BCEE36269B4 (unchanged)

**Badge images added:**
- AZ-400.png added to frontend/images/
- AZ-204.png added to frontend/images/
- Both saved with dashes in filename — HTML references AZ-400.png and AZ-204.png

**Visitor label fix:**
- .visitor-label color changed from --text-dim (#555568) to --text-muted (#8888a0)
- Font size increased from 0.72rem to 0.78rem
- Was blending into the dark header background — now clearly readable

---

#### Step 7 — SWA CLI --env flag troubleshooting

After switching to SWA CLI, deployment still failed due to --env flag issues.
Full history:

| Attempt | Flag Used | Result |
|---|---|---|
| 1 | --env production | Failed — environment didn't exist on old disconnected SWA |
| 2 | --env default | Failed — "The environment name 'default' is invalid" on fresh SWA |
| 3 | (omitted) | Pipeline green but deployed to "preview" slot, not production |
| 4 | --env production | SUCCESS — Azure Portal shows production slot labeled "Production" |

**Key lesson:** The SWA CLI --env flag maps to the slot name shown in the
Azure Portal Environments blade, not the internal CLI environment name.
The production slot is labeled "Production" in the portal → use --env production.

---

#### Step 8 — Delete and recreate fabian-resume-site

**Why deletion was necessary:**
After `az staticwebapp disconnect`, the Static Web App entered a broken state
where no deployment method worked. All non-destructive options were exhausted:

1. Reset deployment token — failed
2. Fresh token via Azure CLI — failed
3. AzureStaticWebApp@0 with production_branch — failed
4. SWA CLI with --env default — failed
5. az staticwebapp update with --token — failed (BadRequest)
6. az staticwebapp update with --login-with-ado — unrecognized argument

**Recreation settings:**
- Source: Other (not Azure DevOps — Azure couldn't create a PAT for nufaze84)
- Name: fabian-resume-site (same name)
- Resource group: cloud-resume-challenge
- Region: eastus2
- SKU: Free
- Deployment configuration: Deployment token (set at creation — not grayed out)

**Why "Other" source worked:**
Selecting "Other" creates the Static Web App with no managed source control
connection. Azure creates it with just a deployment token. This is exactly
what we needed since we manage the pipeline ourselves in Azure DevOps.

**New internal hostname:** salmon-pond-0c70b1b0f.7.azurestaticapps.net

---

#### Step 9 — Re-add custom domains

After recreation, custom domains were re-added using "Custom domain on Azure DNS":

| Domain | Method | Status |
|---|---|---|
| www.fabianresume.dev | Azure DNS auto-created CNAME | Validated immediately |
| fabianresume.dev | Azure DNS auto-created TXT + A records | Validated after ~2 minutes |

Azure automatically created all necessary DNS records because the DNS zone
(fabianresume.dev) is managed in the same Azure subscription. No manual
DNS record creation was required.

**Custom domain SSL cert expiry:**
- fabianresume.dev: 2027-01-16
- www.fabianresume.dev: 2027-01-22

---

#### Step 10 — First successful end-to-end deployment

Pipeline run #20260722.9:
- ✅ Validate — 3 seconds
- ✅ Install SWA CLI — 21 seconds
- ✅ Deploy via SWA CLI — 27 seconds (--env production)
- ✅ fabianresume.dev loads new design
- ✅ Visitor counter working
- ✅ Both custom domains validated

---

## Pending Items

- [ ] Create User Stories in Azure Boards for all July 22 changes
- [ ] Set up branch policy on main (require PR, require linked work item)
- [ ] Delete old backup files: index3.html, index3.html.bak, style3.css
- [ ] Update NOTES.md with SWA CLI skill and azure-devops-coach skill created
- [ ] Test full proper workflow: User Story → feature branch → PR → Validate → Deploy

---

## Key Lessons Learned

1. **Platform constraints vs YAML issues** — The AzureStaticWebApp@0 task
   failure was not a YAML or token problem. It was an Azure platform constraint
   requiring repo linkage. Always distinguish between code problems and
   platform constraints before troubleshooting.

2. **SWA CLI --env flag maps to portal slot names** — The production slot
   is labeled "Production" in the Azure Portal Environments blade. Use
   --env production. The internal CLI name "default" only applies in
   specific disconnected states and is unreliable.

3. **"Other" source for custom pipelines** — When creating a Static Web App
   for a custom CI/CD pipeline, use "Other" as the source. This avoids
   managed pipeline conflicts and immediately enables token-based deployment.

4. **Fresh SWA deployment environment quirks** — A brand new Static Web App
   with "WaitingForDeployment" status will reject --env default. The first
   deployment without --env goes to a "preview" slot. Use --env production
   to target the actual production slot.

5. **Azure DNS auto-creates records** — When using "Custom domain on Azure DNS"
   and the DNS zone is in the same subscription, Azure automatically creates
   all necessary DNS records (TXT, CNAME, A). No manual record creation needed.

6. **Safest approach first** — Six non-destructive approaches were tried before
   recommending deletion. Deletion is always the last resort, never the first.

7. **Comments document decisions** — The full --env flag history is preserved
   in the pipeline YAML comments so anyone reading it understands the journey.

---

## Reference Commands

### Git (VS Code terminal at D:\Cloud-Resume-Challenge)
```powershell
# Add git to PATH for this session (flash drive limitation)
$env:PATH += ";C:\Program Files\Git\cmd"

# Check current remote
git remote -v

# Stage, commit, push
git add <file>
git commit -m "message"
git push origin main
```

### Azure CLI (Azure Cloud Shell at PS /home/fabian)
```bash
# List Static Web App environments
az staticwebapp environment list \
  --name fabian-resume-site \
  --resource-group cloud-resume-challenge \
  --query "[].{Name:name, Status:status, Hostname:hostname}" \
  --output table

# Get current deployment token
az staticwebapp secrets list \
  --name fabian-resume-site \
  --resource-group cloud-resume-challenge \
  --query "properties.apiKey" \
  --output tsv

# Show Static Web App state
az staticwebapp show \
  --name fabian-resume-site \
  --resource-group cloud-resume-challenge \
  --query "{name:name, repositoryUrl:repositoryUrl, branch:branch}" \
  --output table
```

### SWA CLI (used in pipeline — reference only)
```bash
# Install
npm install -g @azure/static-web-apps-cli@latest

# Deploy to production slot (correct command)
swa deploy frontend/ \
  --env production \
  --deployment-token <token>
```