package com.cybershield.threat.model;

import jakarta.persistence.*; 
import java.time.LocalDateTime;

@Entity 
@Table(name = "scan_history")
public class ScanResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; 

    private String url;
    private int riskScore;
    private String status;
    private String username; 
    
    @Column(name = "ip_address") // Naya field jo humne SQL mein add kiya
    private String ipAddress;

    private LocalDateTime scanTimestamp; 

    // 1. Default Constructor
    public ScanResult() {}

    // 2. Original Parameterized Constructor
    public ScanResult(String url, int riskScore, String status) {
        this.url = url;
        this.riskScore = riskScore;
        this.status = status;
        this.scanTimestamp = LocalDateTime.now();
    }

    // 3. Updated Constructor (5 Arguments - IP Address ke saath)
    public ScanResult(String url, int riskScore, String status, String username, String ipAddress) {
        this.url = url;
        this.riskScore = riskScore;
        this.status = status;
        this.username = username;
        this.ipAddress = ipAddress;
        this.scanTimestamp = LocalDateTime.now();
    }

    // --- Getters ---
    public Long getId() { return id; }
    public String getUrl() { return url; }
    public int getRiskScore() { return riskScore; }
    public String getStatus() { return status; }
    public String getUsername() { return username; }
    public String getIpAddress() { return ipAddress; } // Naya Getter
    public LocalDateTime getScanTimestamp() { return scanTimestamp; }

    // --- Setters ---
    public void setId(Long id) { this.id = id; }
    public void setUrl(String url) { this.url = url; }
    public void setRiskScore(int riskScore) { this.riskScore = riskScore; }
    public void setStatus(String status) { this.status = status; }
    public void setUsername(String username) { this.username = username; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; } // Naya Setter
    public void setScanTimestamp(LocalDateTime scanTimestamp) { this.scanTimestamp = scanTimestamp; }
}