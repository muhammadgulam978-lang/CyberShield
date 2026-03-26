# 🛡️ CyberShield AI: Enterprise Threat Intelligence System

CyberShield is a distributed, microservices-driven cybersecurity platform designed to mitigate web-based threats. By leveraging **AI-driven heuristic analysis** and **real-time metadata extraction**, it provides users with a comprehensive security posture against phishing and malicious URLs.

---

## 🏗️ High-Level System Architecture

The system utilizes a **Decoupled Microservices Architecture**, ensuring high availability and fault tolerance. All communications between the Flutter Client and Backend Services are protected via **Stateful JWT Security Interceptors**.

```mermaid
graph LR
    subgraph "Client Layer (Frontend)"
        A[Flutter Mobile/Web App]
    end

    subgraph "Security & Gateway"
        B{JWT Auth Interceptor}
        C[Spring Security Filter Chain]
    end

    subgraph "Core Services (Microservices)"
        D[Auth Service: 9090]
        E[Threat Service: 9091]
    end

    subgraph "External Intelligence"
        F[VirusTotal API / AI Engine]
        G[PDF Reporting Engine]
    end

    subgraph "Persistence Layer"
        H[(MySQL - User Data)]
        I[(MySQL - Threat History)]
    end

    A --> B
    B --> C
    C -->|Validate Token| D
    C -->|Analyze Request| E
    E -->|Heuristic Lookup| F
    E -->|Generate Artifact| G
    D --> H
    E --> I
