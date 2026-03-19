package com.cybershield.threat.controller;

import com.cybershield.threat.model.ScanResult;
import com.cybershield.threat.repository.ScanRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate; // Naya Import
import java.net.InetAddress;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/threat")
@CrossOrigin(origins = "*") 
public class ThreatController {

    @Autowired
    private ScanRepository scanRepository;

    // VirusTotal Configuration
    private final String VT_API_KEY = "26d96a67aeadfd316b0115a59b2664f87f1f747ec134888ce1cbb1ca67a23d90";
    private final String VT_URL = "https://www.virustotal.com/api/v3/domains/";

    @GetMapping("/scan")
    public ScanResult scanURL(
            @RequestParam String url, 
            @RequestParam(required = false, defaultValue = "Guest") String username) {
        
        // 1. Fetch IP Address (Aapka Purana Code)
        String fetchedIp;
        String host = url.replace("http://", "").replace("https://", "").split("/")[0];
        try {
            fetchedIp = InetAddress.getByName(host).getHostAddress();
        } catch (Exception e) {
            fetchedIp = "Unavailable";
        }

        // 2. Risk Calculation (Hybrid: API + Old Logic)
        int finalScore = 0;
        
        try {
            // VirusTotal API Call
            RestTemplate restTemplate = new RestTemplate();
            HttpHeaders headers = new HttpHeaders();
            headers.set("x-apikey", VT_API_KEY);
            HttpEntity<String> entity = new HttpEntity<>(headers);

            ResponseEntity<Map> response = restTemplate.exchange(
                VT_URL + host, HttpMethod.GET, entity, Map.class);

            if (response.getStatusCode() == HttpStatus.OK) {
                Map data = (Map) response.getBody().get("data");
                Map attributes = (Map) data.get("attributes");
                Map stats = (Map) attributes.get("last_analysis_stats");
                
                int malicious = (int) stats.get("malicious");
                int suspicious = (int) stats.get("suspicious");

                // Agar API se malicious results milen toh unhein priority den
                if (malicious > 0 || suspicious > 0) {
                    finalScore = Math.min((malicious * 20) + (suspicious * 10), 100);
                } else {
                    // Agar API kahe "Safe", toh phir bhi aapka purana keyword check check karega
                    finalScore = calculateRisk(url);
                }
            }
        } catch (Exception e) {
            // Fallback: Agar API fail ho jaye (Internet ya Limit ka masla), toh purana logic chalayen
            System.out.println("VT API Fallback: Using keyword logic.");
            finalScore = calculateRisk(url);
        }

        String status = (finalScore > 60) ? "PHISHING" : (finalScore > 30 ? "SUSPICIOUS" : "SAFE");

        // 3. Create & Save Result
        ScanResult result = new ScanResult(url, finalScore, status, username, fetchedIp);
        
        return scanRepository.save(result);
    }

    @GetMapping("/history")
    public List<ScanResult> getScanHistory(@RequestParam String username) {
        return scanRepository.findByUsernameOrderByScanTimestampDesc(username);
    }

    // Aapka Original Risk Logic (Keep it as it is)
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