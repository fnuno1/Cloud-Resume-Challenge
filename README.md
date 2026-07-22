<<<<<<< HEAD
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
=======
# Introduction 
TODO: Give a short introduction of your project. Let this section explain the objectives or the motivation behind this project. 

# Getting Started
TODO: Guide users through getting your code up and running on their own system. In this section you can talk about:
1.	Installation process
2.	Software dependencies
3.	Latest releases
4.	API references

# Build and Test
TODO: Describe and show how to build your code and run the tests. 

# Contribute
TODO: Explain how other users and developers can contribute to make your code better. 

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)
>>>>>>> 84eaa2cb89205c20e9e7279cef025aad4a18876c
