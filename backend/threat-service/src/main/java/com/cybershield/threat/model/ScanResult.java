package com.cybershield.threat.model;

import jakarta.persistence.*; // Zaroori annotations ke liye
import java.time.LocalDateTime;

@Entity // Is se Spring Boot table banayega
@Table(name = "scan_history")
public class ScanResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // Database Primary Key

    private String url;
    private int riskScore;
    private String status;
    private String username; // History track karne ke liye naya field
    private LocalDateTime scanTimestamp; // Time track karne ke liye

    // 1. Default Constructor (Already present)
    public ScanResult() {}

    // 2. Original Parameterized Constructor (Already present)
    public ScanResult(String url, int riskScore, String status) {
        this.url = url;
        this.riskScore = riskScore;
        this.status = status;
    }

    // 3. NEW Constructor (Error fix karne ke liye - 4 Arguments)
    public ScanResult(String url, int riskScore, String status, String username) {
        this.url = url;
        this.riskScore = riskScore;
        this.status = status;
        this.username = username;
        this.scanTimestamp = LocalDateTime.now(); // Auto current time
    }

    // --- Getters (Pehle wale + Naye wale) ---
    public Long getId() { return id; }
    public String getUrl() { return url; }
    public int getRiskScore() { return riskScore; }
    public String getStatus() { return status; }
    public String getUsername() { return username; }
    public LocalDateTime getScanTimestamp() { return scanTimestamp; }

    // Setters (JPA ke liye zaroori hain)
    public void setId(Long id) { this.id = id; }
    public void setUsername(String username) { this.username = username; }
    public void setScanTimestamp(LocalDateTime scanTimestamp) { this.scanTimestamp = scanTimestamp; }
}