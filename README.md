# 🌐 Cloud Resume Challenge — Fabian Nuno

![CI/CD](https://img.shields.io/badge/GitHub%20Actions-ready-blue?logo=githubactions)

This is my personal resume website built as part of the **Cloud Resume Challenge**.  
It showcases my front-end development skills, certifications, and cloud readiness.  
Backend, CI/CD, and Azure integrations will be added in the next phase.

---

## 📊 Live Visitor Counter

This project includes a fully functional, cloud‑backed visitor counter.

The counter is powered by:
  Azure Functions (Python)
  Azure Cosmos DB (NoSQL)
  HTTP‑triggered API endpoint
  JavaScript fetch call that updates the count in real time
  CORS‑secured communication between frontend and backend
Every page load triggers the API, increments the count in Cosmos DB, and displays the updated total instantly.

## 📄 Project Overview

This resume site is built using:

- HTML5 for structure
- CSS3 for styling and layout
- Google Fonts for clean typography
- Local images for icons and certification badges
- Azure Functions + Cosmos DB for backend logic
- GitHub Actions for CI/CD automation
- Azure DNS + custom domain for production hosting

The design uses a dark theme, responsive layout, hover effects, and clean typography to create a professional and modern resume experience.

---

## 🧰 Technologies Used

HTML5
CSS3
JavaScript
Azure Functions (Python)
Azure Cosmos DB
GitHub Actions
Azure DNS
Custom domain: fabianresume.dev

📚 ## Documentation

- [Architecture Overview](ARCHITECTURE.md)
- [Troubleshooting Log](TROUBLESHOOTING.md)

## 📁 File Structure

/Cloud-Resume-Challenge
│── index.html
│── styles.css
│── /images
│── /frontend/api (Azure Function App)
│── ARCHITECTURE.md
│── TROUBLESHOOTING.md
└── README.md

## 🚀 How to Run

1. Clone or download the repository.
2. Open `index.html` in any browser.
3. Backend calls will work only when deployed (local browsing is static)

---

🎯 Goals Achieved
Built a professional resume site from scratch
Implemented a serverless backend with Azure Functions
Integrated Cosmos DB for persistent storage
Automated deployments with GitHub Actions
Configured Azure DNS + custom domain
Added a real‑time visitor counter
Documented architecture and troubleshooting for reproducibility

## 🌐 Domain & DNS Configuration

🌐 Domain & DNS Configuration
The domain fabianresume.dev was purchased through Namecheap and delegated to Azure DNS.

Completed steps:

Created Azure DNS Zone

Updated Namecheap nameservers:

ns1‑04.azure‑dns.com

ns2‑04.azure‑dns.net

ns3‑04.azure‑dns.org

ns4‑04.azure‑dns.info

Verified DNS propagation

Enabled Azure‑managed HTTPS certificates

TThis will make the site publicly accessible at [https://fabianresume.dev](https://fabianresume.dev)

📌 Next Enhancements
Add recruiter click tracking
Add analytics dashboard
Add automated uptime monitoring
Expand CI/CD to include frontend deployment pipeline

## 👤 About Me

**Fabian Nuno** — Azure Administrator at Total Site Solutions  
Focused on secure infrastructure, automation, and empowering teams through scalable systems.  
Currently completing a B.S. in Cloud Computing at WGU.

---

📬 Contact

## 📬 Contact

- Email: [fnguno@gmail.com](mailto:fnguno@gmail.com)
- GitHub: [fnuno1](https://github.com/fnuno1)
- LinkedIn: [fabian-nuno](https://www.linkedin.com/in/fabian-nuno)
- Location: Georgetown, TX
