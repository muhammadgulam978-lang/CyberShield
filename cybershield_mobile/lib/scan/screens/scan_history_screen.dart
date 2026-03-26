import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Token ke liye
import '../../../core/constants/api_constants.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  List _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  // ✅ Helper to get Secure Headers with Token
  Future<Options> _getOptions() async {
    String? token = await _storage.read(key: "token");
    return Options(
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  Future<void> _fetchHistory() async {
    try {
      final options = await _getOptions();

      // 🔥 FIX: Username param hata diya aur Token wala Header add kiya
      final response = await _dio.get(
        '${ApiConstants.threatBaseUrl}/history',
        options: options,
      );

      if (response.statusCode == 200) {
        setState(() {
          _history = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("🔥 History Fetch Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadReport(int scanId) async {
    // ✅ Note: Download ke liye token header bhejna parhta hai agar backend protected ho.
    // Filhal hum browser se open kar rahe hain.
    final String url = '${ApiConstants.threatBaseUrl}/download-report/$scanId';
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint("Download Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to download report")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          "SCAN HISTORY",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
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
                Color statusColor = scan['status'] == "SAFE"
                    ? Colors.greenAccent
                    : Colors.redAccent;

                return Card(
                  color: Colors.white.withOpacity(0.05),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: statusColor.withOpacity(0.2)),
                  ),
                  child: ListTile(
                    leading: Icon(
                      scan['status'] == "SAFE"
                          ? Icons.verified_user
                          : Icons.gpp_maybe,
                      color: statusColor,
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
