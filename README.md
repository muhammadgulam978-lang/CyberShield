# <p align="center">🛡️ CyberShield AI: Enterprise Threat Intelligence System</p>

<p align="center">
  <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" alt="Maintained">
  <img src="https://img.shields.io/badge/Backend-Spring_Boot_3.x-red.svg" alt="Spring Boot">
  <img src="https://img.shields.io/badge/Security-Spring_Security_JWT-yellow.svg" alt="Security">
  <img src="https://img.shields.io/badge/Frontend-Flutter_3.x-blue.svg" alt="Flutter">
  <img src="https://img.shields.io/badge/Database-MySQL-orange.svg" alt="MySQL">
  <img src="https://img.shields.io/badge/API-REST_/__OpenAPI_3.0-lightgrey.svg" alt="API">
</p>

## 📌 System Overview
<p align="center">
</p>

CyberShield is a distributed, **microservices-driven cybersecurity platform** designed to mitigate web-based threats. By leveraging **AI-driven heuristic analysis** and **real-time metadata extraction**, it provides users with a comprehensive security posture against phishing and malicious URLs.

---

## 🏗️ High-Level System Architecture (Visualized)

The system utilizes a **Decoupled Microservices Architecture**, ensuring high availability and fault tolerance. All communications between the Flutter Client and Backend Services are protected via **Stateful JWT Security Interceptors**. The PDF Reporting Engine provides automated forensic artifacts.

```mermaid
graph LR
    %% Defining Node Styles for a Color-ful Diagram
    %% Client (Cyan)
    classDef client fill:#e1f5fe,stroke:#01579b,stroke-width:2px,rx:10,ry:10;
    %% Security (Yellow)
    classDef security fill:#fff9c4,stroke:#fbc02d,stroke-width:2px,stroke-dasharray: 5 5,rx:10,ry:10;
    %% Services (Red/LightRed)
    classDef service fill:#ffebee,stroke:#b71c1c,stroke-width:2px,rx:10,ry:10;
    %% Data (Orange)
    classDef data fill:#fff3e0,stroke:#e65100,stroke-width:2px,stroke-dasharray: 3 3,rx:5,ry:5;
    %% Reports (Green)
    classDef report fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px,rx:10,ry:10;

    %% Client Layer (Presentation)
    subgraph "Presentation Layer (Client)"
        A[Flutter Mobile App]:::client
        H[Flutter Web App]:::client
    end

    %% Security & Gateway Layer
    subgraph "Security & Gateway"
        B{JWT Auth Interceptor}:::security
        C[Spring Security Filter Chain]:::security
    end

    %% Core Services Layer
    subgraph "Core Services (Spring Boot)"
        D[Auth Service: 9090]:::service
        E[Threat Service: 9091]:::service
    end

    %% External & Generation Layer
    subgraph "External Intelligence & Generation"
        F[VirusTotal API / AI Engine]:::data
        G[PDF Reporting Engine]:::report
    end

    %% Persistence Layer (Database)
    subgraph "Persistence Layer (MySQL)"
        I[(MySQL - User Data)]:::data
        J[(MySQL - Threat History)]:::data
    end

    A --> B
    H --> B
    B --> C
    C -->|Validate Token| D
    C -->|Analyze Request| E
    E -->|Heuristic Lookup| F
    E -->|Forensic PDF Generate| G
    D --> I
    E --> J
