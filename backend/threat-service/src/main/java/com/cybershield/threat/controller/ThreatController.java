// package com.cybershield.threat.controller;

// import com.cybershield.threat.model.ScanResult;
// import com.cybershield.threat.repository.ScanRepository;
// import org.springframework.beans.factory.annotation.Autowired;
// import org.springframework.http.*; 
// import org.springframework.web.bind.annotation.*;
// import org.springframework.web.client.RestTemplate;

// // --- SAHI PDF IMPORTS (com.lowagie) ---
// import com.lowagie.text.*;
// import com.lowagie.text.pdf.*;
// import jakarta.servlet.http.HttpServletResponse;
// import java.io.IOException;
// import java.awt.Color; 
// // --------------------------------------

// import java.net.InetAddress;
// import java.util.Arrays;
// import java.util.List;
// import java.util.Map;
// import java.util.HashMap; // Naya import for stats

// @RestController
// @RequestMapping("/api/threat")
// @CrossOrigin(origins = "*", allowedHeaders = "*") 
// public class ThreatController {

//     @Autowired
//     private ScanRepository scanRepository;

//     private final String VT_API_KEY = "26d96a67aeadfd316b0115a59b2664f87f1f747ec134888ce1cbb1ca67a23d90";
//     private final String VT_URL = "https://www.virustotal.com/api/v3/domains/";

//     @GetMapping("/scan")
//     public ScanResult scanURL(
//             @RequestParam String url, 
//             @RequestParam(required = false, defaultValue = "Guest") String username) {
        
//         String fetchedIp;
//         String host = url.replace("http://", "").replace("https://", "").split("/")[0];
//         try {
//             fetchedIp = InetAddress.getByName(host).getHostAddress();
//         } catch (Exception e) {
//             fetchedIp = "Unavailable";
//         }

//         int finalScore = 0;
//         try {
//             RestTemplate restTemplate = new RestTemplate();
//             HttpHeaders headers = new HttpHeaders();
//             headers.set("x-apikey", VT_API_KEY);
//             HttpEntity<String> entity = new HttpEntity<>(headers);

//             ResponseEntity<Map> response = restTemplate.exchange(
//                 VT_URL + host, HttpMethod.GET, entity, Map.class);

//             if (response.getStatusCode() == HttpStatus.OK) {
//                 Map data = (Map) response.getBody().get("data");
//                 Map attributes = (Map) data.get("attributes");
//                 Map stats = (Map) attributes.get("last_analysis_stats");
                
//                 int malicious = (int) stats.get("malicious");
//                 int suspicious = (int) stats.get("suspicious");

//                 if (malicious > 0 || suspicious > 0) {
//                     finalScore = Math.min((malicious * 20) + (suspicious * 10), 100);
//                 } else {
//                     finalScore = calculateRisk(url);
//                 }
//             }
//         } catch (Exception e) {
//             System.out.println("VT API Fallback: Using keyword logic.");
//             finalScore = calculateRisk(url);
//         }

//         String status = (finalScore > 60) ? "PHISHING" : (finalScore > 30 ? "SUSPICIOUS" : "SAFE");
//         ScanResult result = new ScanResult(url, finalScore, status, username, fetchedIp);
        
//         return scanRepository.save(result);
//     }

//     @GetMapping("/history")
//     public List<ScanResult> getScanHistory(@RequestParam String username) {
//         return scanRepository.findByUsernameOrderByScanTimestampDesc(username);
//     }

//     // 🔥 NAYA FEATURE: Stats for Dashboard Graphs
//     @GetMapping("/stats")
//     public Map<String, Long> getStats(@RequestParam String username) {
//         List<ScanResult> history = scanRepository.findByUsernameOrderByScanTimestampDesc(username);
        
//         long safe = history.stream().filter(r -> "SAFE".equals(r.getStatus())).count();
//         long phishing = history.stream().filter(r -> "PHISHING".equals(r.getStatus())).count();
//         long suspicious = history.stream().filter(r -> "SUSPICIOUS".equals(r.getStatus())).count();
        
//         Map<String, Long> stats = new HashMap<>();
//         stats.put("safe", safe);
//         stats.put("phishing", phishing);
//         stats.put("suspicious", suspicious);
//         stats.put("total", (long) history.size());
//         return stats;
//     }

//     @GetMapping("/download-report/{id}")
//     public void downloadReport(@PathVariable Long id, HttpServletResponse response) throws IOException {
//         ScanResult result = scanRepository.findById(id)
//                 .orElseThrow(() -> new RuntimeException("Scan record not found with id: " + id));

//         response.setContentType("application/pdf");
//         response.setHeader("Content-Disposition", "attachment; filename=CyberShield_Report_" + id + ".pdf");

//         com.lowagie.text.Document document = new com.lowagie.text.Document(PageSize.A4);
//         PdfWriter.getInstance(document, response.getOutputStream());

//         document.open();

//         com.lowagie.text.Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 22, new Color(0, 51, 102));
//         com.lowagie.text.Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12);
//         com.lowagie.text.Font normalFont = FontFactory.getFont(FontFactory.HELVETICA, 12);

//         Paragraph title = new Paragraph("CyberShield - Threat Analysis Report", titleFont);
//         title.setAlignment(Element.ALIGN_CENTER);
//         title.setSpacingAfter(30);
//         document.add(title);

//         PdfPTable table = new PdfPTable(2);
//         table.setWidthPercentage(100);
//         table.setWidths(new float[] {3.5f, 6.5f});

//         addPdfCell(table, "Target URL:", headerFont);
//         addPdfCell(table, result.getUrl(), normalFont);

//         addPdfCell(table, "Security Status:", headerFont);
//         addPdfCell(table, result.getStatus(), normalFont);

//         addPdfCell(table, "Risk Score:", headerFont);
//         addPdfCell(table, String.valueOf(result.getRiskScore()) + "/100", normalFont);

//         addPdfCell(table, "IP Address:", headerFont);
//         addPdfCell(table, result.getIpAddress(), normalFont);

//         addPdfCell(table, "Scan Date:", headerFont);
//         addPdfCell(table, result.getScanTimestamp().toString(), normalFont);

//         document.add(table);

//         Paragraph footer = new Paragraph("\n\nDisclaimer: Generated by CyberShield AI Security Engine.", 
//                 FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 10, Color.GRAY));
//         footer.setAlignment(Element.ALIGN_CENTER);
//         document.add(footer);

//         document.close();
//     }

//     private void addPdfCell(PdfPTable table, String text, com.lowagie.text.Font font) {
//         PdfPCell cell = new PdfPCell(new Phrase(text, font));
//         cell.setPadding(10);
//         cell.setBackgroundColor(new Color(245, 245, 245));
//         table.addCell(cell);
//     }

//     private int calculateRisk(String url) {
//         int score = 10; 
//         List<String> riskyKeywords = Arrays.asList("login", "verify", "bank", "free", "gift", "update", "account");
//         List<String> riskyTlds = Arrays.asList(".xyz", ".tk", ".ml", ".ga", ".cf");

//         for (String word : riskyKeywords) {
//             if (url.toLowerCase().contains(word)) score += 20;
//         }
//         for (String tld : riskyTlds) {
//             if (url.toLowerCase().endsWith(tld)) score += 30;
//         }
//         return Math.min(score, 100);
//     }
// }


package com.cybershield.threat.controller;

import com.cybershield.threat.model.ScanResult;
import com.cybershield.threat.repository.ScanRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*; 
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.security.core.Authentication; // ✅ Added

// --- PDF IMPORTS ---
import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.awt.Color; 
// -------------------

import java.net.InetAddress;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/threat")
@CrossOrigin(origins = "*", allowedHeaders = "*") 
public class ThreatController {

    @Autowired
    private ScanRepository scanRepository;

    private final String VT_API_KEY = "26d96a67aeadfd316b0115a59b2664f87f1f747ec134888ce1cbb1ca67a23d90";
    private final String VT_URL = "https://www.virustotal.com/api/v3/domains/";

    @GetMapping("/scan")
    public ScanResult scanURL(
            @RequestParam String url, 
            Authentication authentication) { // ✅ Fixed: Removed username param
        
        String username = (authentication != null) ? authentication.getName() : "Guest";
        
        String fetchedIp;
        String host = url.replace("http://", "").replace("https://", "").split("/")[0];
        try {
            fetchedIp = InetAddress.getByName(host).getHostAddress();
        } catch (Exception e) {
            fetchedIp = "Unavailable";
        }

        int finalScore = 0;
        try {
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

                if (malicious > 0 || suspicious > 0) {
                    finalScore = Math.min((malicious * 20) + (suspicious * 10), 100);
                } else {
                    finalScore = calculateRisk(url);
                }
            }
        } catch (Exception e) {
            System.out.println("VT API Fallback: Using keyword logic.");
            finalScore = calculateRisk(url);
        }

        String status = (finalScore > 60) ? "PHISHING" : (finalScore > 30 ? "SUSPICIOUS" : "SAFE");
        ScanResult result = new ScanResult(url, finalScore, status, username, fetchedIp);
        
        return scanRepository.save(result);
    }

    @GetMapping("/history")
    public List<ScanResult> getScanHistory(Authentication authentication) { // ✅ Fixed: Filtered by Token
        String username = authentication.getName();
        return scanRepository.findByUsernameOrderByScanTimestampDesc(username);
    }

    @GetMapping("/stats")
    public Map<String, Long> getStats(Authentication authentication) { // ✅ Fixed: Stats for Logged-in User
        String username = authentication.getName();
        List<ScanResult> history = scanRepository.findByUsernameOrderByScanTimestampDesc(username);
        
        long safe = history.stream().filter(r -> "SAFE".equals(r.getStatus())).count();
        long phishing = history.stream().filter(r -> "PHISHING".equals(r.getStatus())).count();
        long suspicious = history.stream().filter(r -> "SUSPICIOUS".equals(r.getStatus())).count();
        
        Map<String, Long> stats = new HashMap<>();
        stats.put("safe", safe);
        stats.put("phishing", phishing);
        stats.put("suspicious", suspicious);
        stats.put("total", (long) history.size());
        return stats;
    }

    @GetMapping("/download-report/{id}")
    public void downloadReport(@PathVariable Long id, HttpServletResponse response) throws IOException {
        ScanResult result = scanRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Scan record not found with id: " + id));

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=CyberShield_Report_" + id + ".pdf");

        Document document = new Document(PageSize.A4);
        PdfWriter.getInstance(document, response.getOutputStream());

        document.open();
        Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 22, new Color(0, 51, 102));
        Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12);
        Font normalFont = FontFactory.getFont(FontFactory.HELVETICA, 12);

        Paragraph title = new Paragraph("CyberShield - Threat Analysis Report", titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        title.setSpacingAfter(30);
        document.add(title);

        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        table.setWidths(new float[] {3.5f, 6.5f});

        addPdfCell(table, "Target URL:", headerFont);
        addPdfCell(table, result.getUrl(), normalFont);
        addPdfCell(table, "Security Status:", headerFont);
        addPdfCell(table, result.getStatus(), normalFont);
        addPdfCell(table, "Risk Score:", headerFont);
        addPdfCell(table, String.valueOf(result.getRiskScore()) + "/100", normalFont);
        addPdfCell(table, "IP Address:", headerFont);
        addPdfCell(table, result.getIpAddress(), normalFont);
        addPdfCell(table, "Scan Date:", headerFont);
        addPdfCell(table, result.getScanTimestamp().toString(), normalFont);

        document.add(table);
        Paragraph footer = new Paragraph("\n\nDisclaimer: Generated by CyberShield AI Security Engine.", 
                FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 10, Color.GRAY));
        footer.setAlignment(Element.ALIGN_CENTER);
        document.add(footer);

        document.close();
    }

    private void addPdfCell(PdfPTable table, String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setPadding(10);
        cell.setBackgroundColor(new Color(245, 245, 245));
        table.addCell(cell);
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