import 'package:cybershield_mobile/features/auth/bloc/scan_bloc.dart';
import 'package:cybershield_mobile/features/auth/bloc/scan_event.dart';
import 'package:cybershield_mobile/features/auth/bloc/scan_state.dart';
import 'package:cybershield_mobile/features/auth/repository/auth_repository.dart';
import 'package:cybershield_mobile/scan/services/scan_service.dart';
import 'package:cybershield_mobile/scan/model/scan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'scan_details_screen.dart'; // 👈 Detail screen ka import zaroori hai

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final TextEditingController _urlController = TextEditingController();
  final ScanService _scanService = ScanService();
  List<ScanResultModel> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // Note: Yahan "tester" ki jagah baad mein logged-in username use kar sakte hain
    final results = await _scanService.getScanHistory("tester");
    if (mounted) {
      setState(() {
        _history = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🛡️ CYBERSHIELD DASHBOARD"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              final authRepo = AuthRepository();
              await authRepo.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<ScanBloc, ScanState>(
        listener: (context, state) {
          if (state is ScanFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
          if (state is ScanSuccess) {
            _loadHistory();
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  "Enter URL for Security Analysis",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _urlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "example.com",
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(
                      Icons.link,
                      color: Colors.cyanAccent,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                if (state is ScanLoading)
                  const CircularProgressIndicator(color: Colors.cyanAccent)
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      if (_urlController.text.isNotEmpty) {
                        context.read<ScanBloc>().add(
                          UrlScanRequested(_urlController.text),
                        );
                      }
                    },
                    child: const Text(
                      "START ANALYSIS",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                const SizedBox(height: 30),

                if (state is ScanSuccess) _buildResultCard(state.result),

                const SizedBox(height: 20),
                const Divider(color: Colors.white24),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "RECENT SCANS",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: _history.isEmpty
                      ? const Center(
                          child: Text(
                            "No history available",
                            style: TextStyle(color: Colors.white38),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final item = _history[index];
                            Color statusColor = item.status == "PHISHING"
                                ? Colors.redAccent
                                : (item.status == "SUSPICIOUS"
                                      ? Colors.orangeAccent
                                      : Colors.greenAccent);

                            return ListTile(
                              onTap: () {
                                // 🎯 Task 1 Complete: Detail Screen Navigation
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ScanDetailsScreen(scan: item),
                                  ),
                                );
                              },
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.history,
                                color: statusColor.withOpacity(0.7),
                              ),
                              title: Text(
                                item.url,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                "Score: ${item.riskScore}%",
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.white24,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final String status = result['status'] ?? 'UNKNOWN';
    final int score = result['riskScore'] ?? 0;

    Color mainColor;
    IconData statusIcon;
    String statusText;
    Color bgColor;

    if (status == "PHISHING") {
      mainColor = Colors.redAccent;
      statusIcon = Icons.gpp_maybe;
      statusText = "⚠️ DANGER: PHISHING";
      bgColor = Colors.red.withOpacity(0.15);
    } else if (status == "SUSPICIOUS") {
      mainColor = Colors.orangeAccent;
      statusIcon = Icons.report_problem_outlined;
      statusText = "🔍 ALERT: SUSPICIOUS";
      bgColor = Colors.orange.withOpacity(0.15);
    } else {
      mainColor = Colors.greenAccent;
      statusIcon = Icons.verified_user;
      statusText = "🛡️ STATUS: SAFE";
      bgColor = const Color(0xFF1D1E33);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: mainColor.withOpacity(0.5), width: 2),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: mainColor, size: 50),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Risk Score: $score/100",
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                if (status == "PHISHING")
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "This link is dangerous. Do not enter personal data.",
                      style: TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ),
                if (status == "SUSPICIOUS")
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Long URL or unusual domain detected. Proceed with caution.",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
