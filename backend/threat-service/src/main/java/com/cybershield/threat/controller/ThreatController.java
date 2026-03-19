// package com.cybershield.threat.controller;

// import com.cybershield.threat.model.ScanResult;
// import com.cybershield.threat.repository.ScanRepository;
// import org.springframework.beans.factory.annotation.Autowired;
// import org.springframework.http.*;
// import org.springframework.web.bind.annotation.*;
// import org.springframework.web.client.RestTemplate; // Naya Import
// import java.net.InetAddress;
// import java.util.Arrays;
// import java.util.List;
// import java.util.Map;


// @RestController
// @RequestMapping("/api/threat")
// @CrossOrigin(origins = "*") 
// public class ThreatController {

//     @Autowired
//     private ScanRepository scanRepository;

//     // VirusTotal Configuration
//     private final String VT_API_KEY = "26d96a67aeadfd316b0115a59b2664f87f1f747ec134888ce1cbb1ca67a23d90";
//     private final String VT_URL = "https://www.virustotal.com/api/v3/domains/";

//     @GetMapping("/scan")
//     public ScanResult scanURL(
//             @RequestParam String url, 
//             @RequestParam(required = false, defaultValue = "Guest") String username) {
        
//         // 1. Fetch IP Address (Aapka Purana Code)
//         String fetchedIp;
//         String host = url.replace("http://", "").replace("https://", "").split("/")[0];
//         try {
//             fetchedIp = InetAddress.getByName(host).getHostAddress();
//         } catch (Exception e) {
//             fetchedIp = "Unavailable";
//         }

//         // 2. Risk Calculation (Hybrid: API + Old Logic)
//         int finalScore = 0;
        
//         try {
//             // VirusTotal API Call
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

//                 // Agar API se malicious results milen toh unhein priority den
//                 if (malicious > 0 || suspicious > 0) {
//                     finalScore = Math.min((malicious * 20) + (suspicious * 10), 100);
//                 } else {
//                     // Agar API kahe "Safe", toh phir bhi aapka purana keyword check check karega
//                     finalScore = calculateRisk(url);
//                 }
//             }
//         } catch (Exception e) {
//             // Fallback: Agar API fail ho jaye (Internet ya Limit ka masla), toh purana logic chalayen
//             System.out.println("VT API Fallback: Using keyword logic.");
//             finalScore = calculateRisk(url);
//         }

//         String status = (finalScore > 60) ? "PHISHING" : (finalScore > 30 ? "SUSPICIOUS" : "SAFE");

//         // 3. Create & Save Result
//         ScanResult result = new ScanResult(url, finalScore, status, username, fetchedIp);
        
//         return scanRepository.save(result);
//     }

//     @GetMapping("/history")
//     public List<ScanResult> getScanHistory(@RequestParam String username) {
//         return scanRepository.findByUsernameOrderByScanTimestampDesc(username);
//     }

//     // Aapka Original Risk Logic (Keep it as it is)
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

// @RestController
// @RequestMapping("/api/threat")
// @CrossOrigin(origins = "*") 
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

//     @GetMapping("/download-report/{id}")
//     public void downloadReport(@PathVariable Long id, HttpServletResponse response) throws IOException {
//         ScanResult result = scanRepository.findById(id)
//                 .orElseThrow(() -> new RuntimeException("Scan record not found with id: " + id));

//         response.setContentType("application/pdf");
//         response.setHeader("Content-Disposition", "attachment; filename=CyberShield_Report_" + id + ".pdf");

//         // ✅ FIX: Using full package name to avoid "Abstract Class" error
//         com.lowagie.text.Document document = new com.lowagie.text.Document(PageSize.A4);
//         PdfWriter.getInstance(document, response.getOutputStream());

//         document.open();

//         // ✅ FIX: Using Font and FontFactory explicitly from com.lowagie
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
import org.springframework.http.*; // Isme sahi HttpHeaders maujood hain
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

// ... baaki PDF wale imports ...
// --- SAHI PDF IMPORTS (com.lowagie) ---
import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.awt.Color; 
// --------------------------------------

import java.net.InetAddress;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/threat")
// 🔥 UPDATED: Added allowedHeaders to fix Web/CORS issues
@CrossOrigin(origins = "*", allowedHeaders = "*") 
public class ThreatController {

    @Autowired
    private ScanRepository scanRepository;

    private final String VT_API_KEY = "26d96a67aeadfd316b0115a59b2664f87f1f747ec134888ce1cbb1ca67a23d90";
    private final String VT_URL = "https://www.virustotal.com/api/v3/domains/";

    @GetMapping("/scan")
    public ScanResult scanURL(
            @RequestParam String url, 
            @RequestParam(required = false, defaultValue = "Guest") String username) {
        
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
    public List<ScanResult> getScanHistory(@RequestParam String username) {
        return scanRepository.findByUsernameOrderByScanTimestampDesc(username);
    }

    @GetMapping("/download-report/{id}")
    public void downloadReport(@PathVariable Long id, HttpServletResponse response) throws IOException {
        ScanResult result = scanRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Scan record not found with id: " + id));

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=CyberShield_Report_" + id + ".pdf");

        com.lowagie.text.Document document = new com.lowagie.text.Document(PageSize.A4);
        PdfWriter.getInstance(document, response.getOutputStream());

        document.open();

        com.lowagie.text.Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 22, new Color(0, 51, 102));
        com.lowagie.text.Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12);
        com.lowagie.text.Font normalFont = FontFactory.getFont(FontFactory.HELVETICA, 12);

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

    private void addPdfCell(PdfPTable table, String text, com.lowagie.text.Font font) {
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