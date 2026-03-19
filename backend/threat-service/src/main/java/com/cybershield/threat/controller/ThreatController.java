package com.cybershield.threat.controller;

import com.cybershield.threat.model.ScanResult;
import com.cybershield.threat.repository.ScanRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.net.InetAddress;
import java.util.Arrays;
import java.util.List;

@RestController
@RequestMapping("/api/threat")
@CrossOrigin(origins = "*") 
public class ThreatController {

    @Autowired
    private ScanRepository scanRepository;

    @GetMapping("/scan")
    public ScanResult scanURL(
            @RequestParam String url, 
            @RequestParam(required = false, defaultValue = "Guest") String username) {
        
        // 1. Fetch IP Address
        String fetchedIp;
        try {
            String host = url.replace("http://", "").replace("https://", "").split("/")[0];
            fetchedIp = InetAddress.getByName(host).getHostAddress();
        } catch (Exception e) {
            fetchedIp = "Unavailable";
        }

        // 2. Risk Calculation
        int score = calculateRisk(url);
        String status = (score > 40) ? "SUSPICIOUS" : "SAFE";

        // 3. Create & Save Result
        ScanResult result = new ScanResult(url, score, status, username, fetchedIp);
        
        return scanRepository.save(result);
    }

    @GetMapping("/history")
    public List<ScanResult> getScanHistory(@RequestParam String username) {
        return scanRepository.findByUsernameOrderByScanTimestampDesc(username);
    }

    private int calculateRisk(String url) {
        int score = 10; 
        List<String> riskyKeywords = Arrays.asList("login", "verify", "bank", "free", "gift", "update", "account");
        List<String> riskyTlds = Arrays.asList(".xyz", ".tk", ".ml", ".ga", ".cf");

        for (String word : riskyKeywords) {
            if (url.toLowerCase().contains(word)) score += 20;
        }

        for (String tld : riskyTlds) {
            if (url.toLowerCase().endsWith(tld)) score += 30;
        }

        return Math.min(score, 100);
    }
}