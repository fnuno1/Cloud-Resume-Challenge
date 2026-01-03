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
