import 'package:flutter/material.dart';
import '../model/scan_model.dart'; // Ensure karein path sahi ho

class ScanDetailsScreen extends StatelessWidget {
  final ScanResultModel scan;

  const ScanDetailsScreen({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    // Risk score ke mutabiq color (High = Red, Low = Green)
    Color riskColor = scan.riskScore > 40
        ? Colors.redAccent
        : Colors.greenAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          "Security Report",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🎯 Animated Risk Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: riskColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    scan.url,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: CircularProgressIndicator(
                          value: scan.riskScore / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "${scan.riskScore}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "RISK SCORE",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "VERDICT: ${scan.status}",
                    style: TextStyle(
                      color: riskColor,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ℹ️ Detailed Information Cards
            _infoTile(
              "Server IP Address",
              scan.ipAddress ?? "Fetching...",
              Icons.lan,
            ),
            _infoTile(
              "Scan Date",
              scan.scanTimestamp?.split('T')[0] ?? "Recently",
              Icons.calendar_today,
            ),
            _infoTile(
              "Analyzed By",
              scan.username ?? "Guest User",
              Icons.person_outline,
            ),

            const SizedBox(height: 40),

            // 🔙 Back Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 20),
                label: const Text(
                  "BACK TO DASHBOARD",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value, IconData icon) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.cyanAccent),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
