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
  [fabian-resume-api.azurewebsites.net/api/GetResumeCounter](https://fabian-resume-api.azurewebsites.net/api/GetResumeCounter)

---

## Visitor Counter Integration

### CORS Blocking Frontend Requests

- **Issue:** Browser console showed CORS errors when fetching the visitor counter:  
  ```
  Access to fetch at 'https://fabian-resume-api.azurewebsites.net/api/GetResumeCounter'
  from origin 'https://fabianresume.dev' has been blocked by CORS policy
  ```
- **Cause:** Azure Function App did not allow requests from the custom domain.  
- **Resolution:** Added `https://fabianresume.dev` to **CORS** settings in Azure Portal → Function App → CORS.

### DOM Element Not Found

- **Issue:** Console error:  
  ```
  TypeError: Cannot set properties of null (setting 'textContent')
  ```
- **Cause:** JavaScript targeted `id="visitor-count"` but HTML used `id="counter"`.  
- **Resolution:** Updated HTML to:  
  ```html
  <span id="visitor-count">Loading...</span>
  ```  
  ensuring it matched the script.

### Final Working Script

```javascript
async function updateVisitorCount() {
  try {
    const response = await fetch("https://fabian-resume-api.azurewebsites.net/api/GetResumeCounter");
    const data = await response.json();
    document.getElementById("visitor-count").textContent = data.count;
  } catch (error) {
    console.error("Failed to fetch visitor count:", error);
  }
}

window.onload = updateVisitorCount;
```

### Outcome

- Visitor counter now updates correctly on page load.  
- API fetch succeeds with no CORS or DOM errors.  
- Resume site displays the live count (e.g., `Visitor Count: 27`).

# CI/CD Pipeline Troubleshooting (GitHub Actions)

## Missing or Incorrect Python Dependencies

- **Issue:** Azure Function App returned runtime errors due to missing Python modules (e.g., `azure-cosmos`).  
- **Cause:** Dependencies were not included in the deployment package.  
- **Resolution:** Added all required modules to `requirements.txt` and committed the file. GitHub Actions then installed dependencies during the build step.

## `.python_packages` Not Being Packaged

- **Issue:** Deployment succeeded but runtime still failed with module import errors.  
- **Cause:** GitHub Actions workflow did not run `pip install -r requirements.txt --target=".python_packages"` before zipping.  
- **Resolution:** Updated workflow to explicitly install dependencies into `.python_packages` before publishing.

## Incorrect Working Directory in Workflow

- **Issue:** GitHub Actions attempted to deploy from the repo root instead of the Function App folder.  
- **Cause:** `working-directory` was not set to `frontend/api`.  
- **Resolution:** Updated workflow step:  
  ```yaml
  working-directory: ./frontend/api
  ```

## Missing Azure Credentials in GitHub Actions

- **Issue:** Workflow failed with authentication errors when deploying to Azure.  
- **Cause:** Azure federated credentials were not configured or not linked to the correct subscription.  
- **Resolution:**  
  - Created a federated credential in Azure AD for the GitHub repo.  
  - Added `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID` to GitHub Secrets.  
  - Verified with `azure/login@v1` step.

## Function App Not Updating After Push

- **Issue:** Deployment logs showed success, but the live Function App still served old code.  
- **Cause:** The workflow zipped the wrong directory or skipped the publish step.  
- **Resolution:** Ensured the workflow used:  
  ```yaml
  func azure functionapp publish fabian-resume-api
  ```  
  and that the correct folder was zipped.

## Case Sensitivity in API Route

- **Issue:** Frontend fetch failed with 404 even though the Function App was deployed.  
- **Cause:** Azure Functions are case-sensitive. The route was deployed as `GetResumeCounter` but frontend called `getresumecounter`.  
- **Resolution:** Updated frontend to call the correct route:  
  ```
  /api/GetResumeCounter
  ```

## Successful CI/CD Deployment

- **Outcome:**  
  - GitHub Actions installs dependencies  
  - Packages `.python_packages`  
  - Publishes the Function App  
  - Syncs triggers  
  - Backend updates automatically on every push  
  - Frontend fetches live data successfully

