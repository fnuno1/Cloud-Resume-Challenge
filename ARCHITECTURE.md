# Final Architecture Summary

## Overview

This project implements a full end-to-end cloud architecture for a dynamic resume website. It combines a static frontend, a serverless backend, a NoSQL database, and a CI/CD pipeline  all deployed on Azure and automated through GitHub Actions.

## Frontend (Static Website)

- Hosted as a static site (e.g., Azure Static Web Apps or GitHub Pages).
- Custom domain: fabianresume.dev.
- Displays live visitor count using a JavaScript fetch call.
- Fetches data from the Azure Function App via /api/GetResumeCounter.
- Includes responsive design, custom styling, and professional branding.

## Backend (Azure Function App)

- Azure Function App running Python 3.11.
- Single HTTP-triggered function:
  - GetResumeCounter  increments and returns the visitor count.
- Uses Azure-managed identity for secure access to Cosmos DB.
- CORS configured to allow fabianresume.dev.

## Database (Azure Cosmos DB)

- NoSQL database using the Core (SQL) API.
- Stores a single document containing the visitor counter.
- Partition key: /id.
- Automatically scales with demand.
- Accessed securely via Function App identity.

## CI/CD Pipeline (GitHub Actions)

- Automatically deploys backend code on every push to main.
- Key steps:
  - Install Python dependencies into .python_packages
  - Zip and publish the Function App
  - Sync triggers
- Uses Azure federated credentials for passwordless authentication.
- Ensures backend stays in sync with repo changes.

## Security & Governance

- No secrets stored in code.
- GitHub  Azure authentication handled via OIDC.
- CORS restricted to production domain.
- Principle of least privilege applied to Function App identity.

## Data Flow Summary

1. User visits fabianresume.dev  
2. Frontend JavaScript calls the Function App endpoint  
3. Function App reads and increments the counter in Cosmos DB  
4. Updated count is returned to the frontend  
5. Frontend updates the DOM with the live number  

## Result

- Fully cloudpowered resume site  
- Realtime visitor analytics  
- Automated deployments  
- Secure, scalable, and productionready architecture  
- Demonstrates practical Azure, DevOps, and automation skills  
