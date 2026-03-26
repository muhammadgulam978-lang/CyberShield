# 🛡️ CyberShield - AI Threat Detection System

CyberShield is a professional, microservices-based cybersecurity application designed to analyze URLs for phishing and malicious threats. It features a secure, multi-user environment with real-time analytics.

---

## 🏗️ System Architecture
The project follows a **Microservices Architecture** to ensure scalability and separation of concerns.

```mermaid
graph TD
    A[Flutter Mobile App] -->|JWT Token + Request| B{Security Filter}
    B -->|Authenticate| C[Auth Service]
    B -->|Scan URL| D[Threat Service]
    D -->|AI Analysis| E[VirusTotal / Internal Engine]
    C -->|User Data| F[(MySQL Database)]
    D -->|History & Stats| F
    D -->|Generate PDF| G[Detailed Analysis Report]
