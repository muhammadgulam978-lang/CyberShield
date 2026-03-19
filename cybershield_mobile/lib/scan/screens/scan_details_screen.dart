import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../model/scan_model.dart';

class ScanDetailsScreen extends StatelessWidget {
  final ScanResultModel scan;

  const ScanDetailsScreen({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    // Risk status ke mutabiq theme color
    Color statusColor = scan.riskScore > 60
        ? Colors.redAccent
        : (scan.riskScore > 30 ? Colors.orangeAccent : Colors.greenAccent);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21), // Dark Cyber Theme
      appBar: AppBar(
        title: const Text(
          "SECURITY ANALYSIS",
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🎯 Phase 1: The Radial Gauge Meter
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    scan.url.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    child: SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          minimum: 0,
                          maximum: 100,
                          showLabels: false,
                          showTicks: false,
                          axisLineStyle: const AxisLineStyle(
                            thickness: 0.2,
                            cornerStyle: CornerStyle.bothCurve,
                            color: Colors.white10,
                            thicknessUnit: GaugeSizeUnit.factor,
                          ),
                          pointers: <GaugePointer>[
                            // Needle (Sui)
                            NeedlePointer(
                              value: scan.riskScore.toDouble(),
                              needleColor: Colors.white,
                              knobStyle: const KnobStyle(
                                color: Colors.white,
                                knobRadius: 0.08,
                              ),
                              enableAnimation: true,
                              animationDuration: 1500,
                            ),
                            // Range Highlighter
                            RangePointer(
                              value: scan.riskScore.toDouble(),
                              width: 0.2,
                              sizeUnit: GaugeSizeUnit.factor,
                              color: statusColor,
                              enableAnimation: true,
                              animationDuration: 1500,
                              cornerStyle: CornerStyle.bothCurve,
                            ),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              positionFactor: 0.5,
                              angle: 90,
                              widget: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${scan.riskScore}%',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                  Text(
                                    scan.status,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: statusColor,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ℹ️ Phase 2: Technical Intelligence Cards
            _buildSectionTitle("TECHNICAL DETAILS"),
            const SizedBox(height: 10),

            _techTile(
              "IP Address",
              scan.ipAddress ?? "N/A",
              Icons.lan_outlined,
            ),
            _techTile(
              "Risk Factor",
              _getRiskMsg(scan.riskScore),
              Icons.warning_amber_rounded,
            ),
            _techTile(
              "Timestamp",
              scan.scanTimestamp?.replaceAll('T', ' ').split('.')[0] ??
                  "Just Now",
              Icons.timer_outlined,
            ),
            _techTile(
              "Scan Owner",
              scan.username ?? "Anonymous",
              Icons.account_circle_outlined,
            ),

            const SizedBox(height: 30),

            // 🔙 Phase 3: Action Button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 10,
                shadowColor: statusColor.withOpacity(0.5),
              ),
              child: const Text(
                "DISMISS REPORT",
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRiskMsg(int score) {
    if (score > 70) return "High chance of Phishing/Malware";
    if (score > 40) return "Suspicious TLD or Keywords detected";
    return "No significant threats found";
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.cyanAccent,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _techTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
