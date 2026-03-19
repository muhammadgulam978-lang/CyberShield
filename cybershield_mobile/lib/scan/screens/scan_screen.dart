import 'dart:async'; // Timer ke liye zaroori hai
import 'package:cybershield_mobile/features/auth/bloc/scan_bloc.dart';
import 'package:cybershield_mobile/features/auth/bloc/scan_event.dart';
import 'package:cybershield_mobile/features/auth/bloc/scan_state.dart';
import 'package:cybershield_mobile/features/auth/repository/auth_repository.dart';
import 'package:cybershield_mobile/scan/services/scan_service.dart';
import 'package:cybershield_mobile/scan/model/scan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'scan_details_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final TextEditingController _urlController = TextEditingController();
  final ScanService _scanService = ScanService();
  List<ScanResultModel> _history = [];

  // --- Live Analysis Variables ---
  int _currentStep = 0;
  Timer? _analysisTimer;
  final List<String> _analysisSteps = [
    "🔍 Initializing Secure Connection...",
    "🌐 Fetching DNS & IP Metadata...",
    "🛡️ Checking Global Blacklists...",
    "📊 Analyzing Heuristic Risk Score...",
    "✅ Finalizing Security Report...",
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _startAnalysisAnimation() {
    setState(() => _currentStep = 0);
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (_currentStep < _analysisSteps.length - 1) {
        setState(() => _currentStep++);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _loadHistory() async {
    final results = await _scanService.getScanHistory();
    if (mounted) {
      setState(() => _history = results);
    }
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          "🛡️ CYBERSHIELD DASHBOARD",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
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
          if (state is ScanLoading) {
            _startAnalysisAnimation(); // Step-by-step animation shuru karein
          }
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
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
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Dynamic Loading Section ---
                if (state is ScanLoading)
                  _buildAnimatedLoader()
                else
                  _buildScanButton(),

                const SizedBox(height: 30),
                if (state is ScanSuccess) _buildResultCard(state.result),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24),
                _buildHistoryHeader(),
                _buildHistoryList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedLoader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: Colors.cyanAccent),
          const SizedBox(height: 25),
          // Ye loop ab tak ke saare steps dikhayega
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_currentStep + 1, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.cyanAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _analysisSteps[index],
                        style: TextStyle(
                          color: index == _currentStep
                              ? Colors.cyanAccent
                              : Colors.white54,
                          fontWeight: index == _currentStep
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 55),
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        if (_urlController.text.isNotEmpty) {
          context.read<ScanBloc>().add(UrlScanRequested(_urlController.text));
        }
      },
      child: const Text(
        "START DEEP ANALYSIS",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "RECENT SCANS",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return Expanded(
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
                return _buildHistoryItem(item);
              },
            ),
    );
  }

  Widget _buildHistoryItem(ScanResultModel item) {
    Color statusColor = item.status == "SAFE"
        ? Colors.greenAccent
        : Colors.redAccent;
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanDetailsScreen(scan: item),
          ),
        ),
        leading: Icon(Icons.shield_outlined, color: statusColor),
        title: Text(
          item.url,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        subtitle: Text(
          "Risk: ${item.riskScore}%",
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: Colors.white24,
        ),
      ),
    );
  }

  Widget _buildResultCard(dynamic result) {
    // Note: Iska logic hum pehle hi finalize kar chuke hain
    return Container();
  }
}
