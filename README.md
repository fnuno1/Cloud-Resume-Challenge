# Cloud Resume Challenge — Azure DevOps

Personal resume site built on Azure, managed via Azure DevOps CI/CD.

**Live site:** https://fabianresume.dev
**Azure DevOps:** dev.azure.com/nufaze84/Cloud_Resume-Challenge

---

## Architecture

```
Browser
  └── Azure Static Web App (fabian-resume-site)
        └── frontend/index.html + style.css
              └── JavaScript fetch → Azure Function App (fabian-resume-api)
                    └── GetResumeCounter → Azure Cosmos DB
```

## Pipeline

```
Push to feature branch
  └── PR created → Validate stage runs automatically
        ├── File existence checks
        ├── Internal reference checks
        └── File size sanity check
  └── PR approved + merged to main
        └── Deploy stage triggers
              └── Manual approval gate (production environment)
                    └── Azure Static Web Apps deployment
```

## Repo Structure

```
/
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── images/
├── .azuredevops/
│   └── pull_request_template.md
├── azure-pipelines.yml
└── README.md
```

## Setup

### Variable Group
Pipelines → Library → Variable Groups → cloud-resume-secrets
- AZURE_STATIC_WEB_APPS_API_TOKEN (secret) — from fabian-resume-site → Manage deployment token

### Environment Approval Gate
Pipelines → Environments → production → Approvals and checks → Approvals
- Required approver: nufaze84

### Branch Policy (main)
- Require PR before merge
- Require linked work item
- Require Validate stage to pass

## Resources

- Static Web App: fabian-resume-site (cloud-resume-challenge RG)
- Function App: fabian-resume-api (cloud-resume-challenge RG)
- Custom domain: fabianresume.dev