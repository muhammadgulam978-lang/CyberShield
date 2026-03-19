package com.cybershield.threat.model;

import jakarta.persistence.*; 
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity 
@Table(name = "scan_history")
@Data
@NoArgsConstructor
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

    // Constructor for saving new scans
    public ScanResult(String url, int riskScore, String status, String username, String ipAddress) {
        this.url = url;
        this.riskScore = riskScore;
        this.status = status;
        this.username = username;
        this.ipAddress = ipAddress;
        this.scanTimestamp = LocalDateTime.now();
    }
}