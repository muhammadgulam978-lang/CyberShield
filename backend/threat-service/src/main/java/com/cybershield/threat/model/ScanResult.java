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
    
    @Column(name = "ip_address")
    private String ipAddress;

    private LocalDateTime scanTimestamp; 

    // 1. Default Constructor (Hibernate ke liye zaroori hai)
    public ScanResult() {
    }

    // 2. Full Constructor (Jo aap use kar rahe hain)
    public ScanResult(String url, int riskScore, String status, String username, String ipAddress) {
        this.url = url;
        this.riskScore = riskScore;
        this.status = status;
        this.username = username;
        this.ipAddress = ipAddress;
        this.scanTimestamp = LocalDateTime.now();
    }

    // 3. MANUAL GETTERS (Jo Controller ko chahiye)
    public Long getId() { return id; }
    public String getUrl() { return url; }
    public int getRiskScore() { return riskScore; }
    public String getStatus() { return status; }
    public String getUsername() { return username; }
    public String getIpAddress() { return ipAddress; }
    public LocalDateTime getScanTimestamp() { return scanTimestamp; }

    // 4. MANUAL SETTERS (Optional but safe to have)
    public void setId(Long id) { this.id = id; }
    public void setUrl(String url) { this.url = url; }
    public void setRiskScore(int riskScore) { this.riskScore = riskScore; }
    public void setStatus(String status) { this.status = status; }
    public void setUsername(String username) { this.username = username; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
    public void setScanTimestamp(LocalDateTime scanTimestamp) { this.scanTimestamp = scanTimestamp; }
}