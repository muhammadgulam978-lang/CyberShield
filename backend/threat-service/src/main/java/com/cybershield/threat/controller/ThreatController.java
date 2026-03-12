package com.cybershield.threat.controller;

import com.cybershield.threat.model.ScanResult;
import com.cybershield.threat.repository.ScanRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.Arrays;
import java.util.List;

@RestController
@RequestMapping("/api/threat")
@CrossOrigin(origins = "*") 
public class ThreatController {

    @Autowired
    private ScanRepository scanRepository;

    @GetMapping("/scan")
    public ScanResult scanURL(@RequestParam String url, @RequestParam(required = false, defaultValue = "Guest") String username) {
        // 1. Fetch IP Address
        String fetchedIp;
        try {
            // URL clean up for IP fetching
            String host = url.replace("http://", "").replace("https://", "").split("/")[0];
            fetchedIp = java.net.InetAddress.getByName(host).getHostAddress();
        } catch (Exception e) {
            fetchedIp = "Unavailable";
        }

        // 2. Risk Calculation (Engine Logic)
        int score = calculateRisk(url);
        String status = (score > 40) ? "SUSPICIOUS" : "SAFE";

        // 3. Create & Save Result (Constructor matching our new model)
        ScanResult result = new ScanResult(url, score, status, username, fetchedIp);
        
        return scanRepository.save(result);
    }

    @GetMapping("/history")
    public List<ScanResult> getScanHistory(@RequestParam String username) {
        return scanRepository.findByUsernameOrderByScanTimestampDesc(username);
    }

    // 🛡️ Internal Threat Engine Method
    private int calculateRisk(String url) {
        int score = 10; // Base score for any site
        
        // List of high-risk keywords
        List<String> riskyKeywords = Arrays.asList("login", "verify", "bank", "free", "gift", "update", "account");
        
        // List of high-risk TLDs
        List<String> riskyTlds = Arrays.asList(".xyz", ".tk", ".ml", ".ga", ".cf");

        // Keyword check
        for (String word : riskyKeywords) {
            if (url.toLowerCase().contains(word)) {
                score += 20;
            }
        }

        // TLD check
        for (String tld : riskyTlds) {
            if (url.toLowerCase().endsWith(tld)) {
                score += 30;
            }
        }

        // Cap score at 100
        return Math.min(score, 100);
    }
}