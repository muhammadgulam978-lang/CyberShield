import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final Dio _dio = Dio();
  List _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      // ✅ Using localhost for Web testing
      final response = await _dio.get(
        'http://localhost:9091/api/threat/history?username=tester',
      );
      if (response.statusCode == 200) {
        setState(() {
          _history = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadReport(int scanId) async {
    final String url =
        'http://localhost:9091/api/threat/download-report/$scanId';
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Download Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF0A0E21,
      ), // Dashboard se match karta dark theme
      appBar: AppBar(
        title: const Text(
          "SCAN HISTORY",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : _history.isEmpty
          ? const Center(
              child: Text(
                "No history found",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final scan = _history[index];
                return Card(
                  color: const Color(0xFF1D1E33),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: Icon(
                      scan['status'] == "SAFE"
                          ? Icons.verified_user
                          : Icons.gpp_maybe,
                      color: scan['status'] == "SAFE"
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                    title: Text(
                      scan['url'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      "Score: ${scan['riskScore']} | Status: ${scan['status']}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _downloadReport(scan['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
