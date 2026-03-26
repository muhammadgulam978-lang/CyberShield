import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../features/auth/bloc/scan_bloc.dart';
import '../../features/auth/bloc/scan_event.dart';
import '../../features/auth/bloc/scan_state.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../model/scan_model.dart';
import 'scan_details_screen.dart';
import 'scan_history_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final TextEditingController _urlController = TextEditingController();

  // 🔥 Live Analysis Animation Logic
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
    // ✅ STEP 1: Screen load hote hi user ka apna data mangwana
    context.read<ScanBloc>().add(FetchDashboardData());
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
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.blueAccent),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ScanHistoryScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await AuthRepository().logout();
              if (mounted)
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
            },
          ),
        ],
      ),
      // ✅ STEP 2: BlocConsumer use karke states handle karna
      body: BlocConsumer<ScanBloc, ScanState>(
        listener: (context, state) {
          if (state is ScanLoading) _startAnalysisAnimation();
          if (state is ScanFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
          // Scan success hote hi dashboard data dobara refresh karna
          if (state is ScanSuccess) {
            _urlController.clear();
            context.read<ScanBloc>().add(FetchDashboardData());
          }
        },
        builder: (context, state) {
          // Dashboard ka data nikalna
          Map<String, dynamic> stats = {
            "safe": 0,
            "phishing": 0,
            "suspicious": 0,
          };
          List<dynamic> history = [];

          if (state is DashboardDataLoaded) {
            stats = state.stats;
            history = state.history;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // 🔥 TOP SECTION: SPLIT LAYOUT (Chart & Recent Scans)
                  SizedBox(
                    height: 220,
                    child: Row(
                      children: [
                        // LEFT: Real-time Pie Chart
                        Expanded(
                          flex: 5,
                          child: Card(
                            color: Colors.white.withOpacity(0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: Colors.cyanAccent.withOpacity(0.2),
                              ),
                            ),
                            child: _buildAnalyticsChart(stats),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // RIGHT: Mini History List
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "RECENT SCANS",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyanAccent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: _buildHistoryList(history, isMini: true),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CENTER: SCANNER SECTION
                  const SizedBox(height: 30),
                  const Text(
                    "Enter URL for Security Analysis",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
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

                  if (state is ScanLoading)
                    _buildAnimatedLoader()
                  else
                    _buildScanButton(),

                  const SizedBox(height: 30),
                  // Last Scan Result (Optional)
                  if (state is ScanSuccess)
                    Text(
                      "✅ Last Scan: ${state.result['status']}",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔥 Chart ko Real Data pass karna
  Widget _buildAnalyticsChart(Map<String, dynamic> stats) {
    final List<ChartData> chartData = [
      ChartData('Safe', (stats['safe'] ?? 0).toDouble(), Colors.greenAccent),
      ChartData(
        'Phishing',
        (stats['phishing'] ?? 0).toDouble(),
        Colors.redAccent,
      ),
      ChartData(
        'Suspicious',
        (stats['suspicious'] ?? 0).toDouble(),
        Colors.orangeAccent,
      ),
    ];

    return SfCircularChart(
      margin: EdgeInsets.zero,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        textStyle: const TextStyle(color: Colors.white70, fontSize: 8),
      ),
      series: <CircularSeries>[
        PieSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          pointColorMapper: (ChartData data, _) => data.color,
          radius: '100%',
        ),
      ],
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

  Widget _buildHistoryList(List<dynamic> history, {bool isMini = false}) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          "No records",
          style: TextStyle(color: Colors.white38, fontSize: 10),
        ),
      );
    }
    return ListView.builder(
      itemCount: history.length > 5
          ? 5
          : history.length, // Dashboard par sirf top 5
      itemBuilder: (context, index) {
        final item = history[index];
        return Card(
          color: Colors.white.withOpacity(0.05),
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            dense: isMini,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Icon(
              Icons.shield_outlined,
              color: item['status'] == "SAFE"
                  ? Colors.greenAccent
                  : Colors.redAccent,
              size: 16,
            ),
            title: Text(
              item['url'] ?? "URL",
              style: const TextStyle(color: Colors.white, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 10,
              color: Colors.white24,
            ),
            onTap: () {
              // Convert Map to Model for Details Screen
              final model = ScanResultModel.fromJson(item);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScanDetailsScreen(scan: model),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLoader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: Colors.cyanAccent),
          const SizedBox(height: 20),
          ...List.generate(
            _currentStep + 1,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    index < _currentStep
                        ? Icons.check_circle
                        : Icons.chevron_right,
                    color: index < _currentStep
                        ? Colors.greenAccent
                        : Colors.cyanAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _analysisSteps[index],
                    style: TextStyle(
                      color: index == _currentStep
                          ? Colors.cyanAccent
                          : Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
