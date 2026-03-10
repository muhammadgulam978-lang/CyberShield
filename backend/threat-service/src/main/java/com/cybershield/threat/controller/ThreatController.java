package com.cybershield.threat.controller;

import com.cybershield.threat.model.ScanResult;
import com.cybershield.threat.repository.ScanRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.Arrays;
import java.util.List;

@RestController
@RequestMapping("/api/threat")
@CrossOrigin(origins = "*") // 👈 Crucial for Flutter Web/Android
public class ThreatController {

    @Autowired
    private ScanRepository scanRepository;

    @GetMapping("/scan")
    public ScanResult scanUrl(@RequestParam String url) {
        System.out.println("===> DEBUG: Authenticated Scan for: " + url);

        List<String> dangerKeywords = Arrays.asList("login", "verify", "update", "bank", "secure", "free");
        List<String> suspiciousTlds = Arrays.asList(".xyz", ".top", ".gq", ".ml", ".cf", ".tk", ".bit");

        String lowerUrl = url.toLowerCase();
        boolean hasDangerWord = dangerKeywords.stream().anyMatch(lowerUrl::contains);
        boolean hasSuspiciousTld = suspiciousTlds.stream().anyMatch(tld -> lowerUrl.endsWith(tld));

        int score = 10;
        String status = "SAFE";

        if (hasDangerWord) {
            score = 85;
            status = "PHISHING";
        } else if (hasSuspiciousTld || url.length() > 50) {
            score = 50;
            status = "SUSPICIOUS";
        }

        // Hardcoded "tester" for now, or get from SecurityContext
        ScanResult result = new ScanResult(url, score, status, "tester");
        return scanRepository.save(result);
    }

    @GetMapping("/history")
    public List<ScanResult> getScanHistory(@RequestParam String username) {
        return scanRepository.findByUsernameOrderByScanTimestampDesc(username);
    }
}