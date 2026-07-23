# Cloud Resume Challenge — Azure DevOps

Personal resume site built on Azure, managed via a custom Azure DevOps CI/CD pipeline.
Demonstrates serverless architecture, CI/CD automation, secrets management, and infrastructure-as-code patterns.

**Live site:** https://fabianresume.dev
**Azure DevOps:** dev.azure.com/nufaze84/Cloud_Resume-Challenge

---

## Architecture

```
Browser
  └── Custom Domain (fabianresume.dev) — Azure DNS
        └── Azure Static Web App (fabian-resume-site)
              ├── frontend/index.html
              ├── frontend/style.css
              └── frontend/images/
                    └── JavaScript fetch → Azure Function App (fabian-resume-api)
                          └── GetResumeCounter (Python HTTP trigger)
                                └── Azure Cosmos DB — visitor count storage
```

---

## CI/CD Pipeline

Two-stage Azure DevOps pipeline with manual approval gate before any production deployment.

```
Push to feature branch
  └── PR created → Validate stage runs automatically
        ├── File existence checks (index.html, style.css, images/)
        ├── Internal reference checks (CSS link, visitor counter API URL)
        └── File size sanity check (catches empty/corrupt files)
  └── PR approved + squash merged to main
        └── Deploy stage triggers
              └── Manual approval gate (production environment — 3 day timeout)
                    └── SWA CLI deploys frontend/ to fabian-resume-site
                          └── Deployment summary logged (build #, commit SHA, timestamp)
```

**Why SWA CLI instead of the AzureStaticWebApp@0 task:**
The official task requires active repository linkage at the Azure platform level.
The SWA CLI authenticates via deployment token only — no repo linkage required.
This gives full control over the pipeline without Azure managing it.

---

## Repo Structure

```
/
├── frontend/
│   ├── index.html              — resume HTML (fully commented)
│   ├── style.css               — stylesheet with CSS design tokens (fully commented)
│   └── images/                 — cert logos and social icons
├── .azuredevops/
│   └── pull_request_template.md
├── .gitattributes              — enforces LF line endings (never remove)
├── azure-pipelines.yml         — CI/CD pipeline definition (fully commented)
├── NOTES.md                    — living project notes and troubleshooting log
└── README.md
```

---

## Azure DevOps Setup

### Variable Group
- Pipelines → Library → Variable Groups → `cloud-resume-secrets`
- `AZURE_STATIC_WEB_APPS_API_TOKEN` (secret 🔒) — from Azure Portal → fabian-resume-site → Manage deployment token

### Environment Approval Gate
- Pipelines → Environments → `production` → Approvals and checks → Approvals
- Required approver: nufaze84
- Timeout: 3 days (4320 minutes)

### Branch Policy (main)
- Require PR before merge — no direct pushes to main
- Require linked work item — no ticket, no merge
- Require Validate stage to pass before merge is allowed

---

## Azure Resources

| Resource | Name | Resource Group |
|---|---|---|
| Static Web App | fabian-resume-site | cloud-resume-challenge |
| Function App | fabian-resume-api | cloud-resume-challenge |
| Cosmos DB | (linked to Function App) | cloud-resume-challenge |
| Custom Domain | fabianresume.dev | Azure DNS |

**Cost:** Static Web App on Free tier. Function App on Consumption plan.
Effective cost for this project is ~$0/month at resume traffic volumes.

---

## Key Engineering Decisions

**LF line endings (.gitattributes):**
Committed before any other files. Git's automatic CRLF conversion on Windows
corrupts unicode characters in HTML and PowerShell files. The .gitattributes file
enforces LF for all text files and marks binary files (PNG, ICO) correctly.
Never remove this file.

**SWA CLI --env production:**
After recreating the Static Web App with "Other" as the deployment source,
the production slot is labeled "Production" in the Azure Portal Environments blade.
The SWA CLI flag `--env production` targets this slot correctly.
Using `--env default` or omitting `--env` deploys to the wrong environment.

**Deployment token auth:**
The Static Web App was created with "Other" as the source (not GitHub or Azure DevOps)
so Azure does not manage the pipeline. The deployment token in the variable group
is the only authentication mechanism — no OAuth, no repo linkage required.

---

## Tech Stack

- **Frontend:** HTML, CSS, JavaScript (vanilla — no framework)
- **Backend:** Azure Functions (Python), Azure Cosmos DB
- **Hosting:** Azure Static Web Apps (Free tier)
- **CI/CD:** Azure DevOps Pipelines (YAML, multi-stage)
- **DNS:** Azure DNS
- **Fonts:** Inter + JetBrains Mono (Google Fonts)