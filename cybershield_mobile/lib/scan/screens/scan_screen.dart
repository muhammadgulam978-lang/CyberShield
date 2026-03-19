// import 'dart:async';
// import 'package:cybershield_mobile/features/auth/bloc/scan_bloc.dart';
// import 'package:cybershield_mobile/features/auth/bloc/scan_event.dart';
// import 'package:cybershield_mobile/features/auth/bloc/scan_state.dart';
// import 'package:cybershield_mobile/features/auth/repository/auth_repository.dart';
// import 'package:cybershield_mobile/scan/services/scan_service.dart';
// import 'package:cybershield_mobile/scan/model/scan_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'scan_details_screen.dart';
// import 'scan_history_screen.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class ScanScreen extends StatefulWidget {
//   const ScanScreen({super.key});

//   @override
//   State<ScanScreen> createState() => _ScanScreenState();
// }

// class _ScanScreenState extends State<ScanScreen> {
//   final TextEditingController _urlController = TextEditingController();
//   final ScanService _scanService = ScanService();
//   List<ScanResultModel> _history = [];

//   // --- Live Analysis Variables ---
//   int _currentStep = 0;
//   Timer? _analysisTimer;
//   final List<String> _analysisSteps = [
//     "🔍 Initializing Secure Connection...",
//     "🌐 Fetching DNS & IP Metadata...",
//     "🛡️ Checking Global Blacklists...",
//     "📊 Analyzing Heuristic Risk Score...",
//     "✅ Finalizing Security Report...",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadHistory();
//   }

//   void _startAnalysisAnimation() {
//     setState(() => _currentStep = 0);
//     _analysisTimer?.cancel();
//     _analysisTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
//       if (_currentStep < _analysisSteps.length - 1) {
//         setState(() => _currentStep++);
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   Future<void> _loadHistory() async {
//     final results = await _scanService.getScanHistory();
//     if (mounted) {
//       setState(() => _history = results);
//     }
//   }

//   // 🔥 Helper function for Chart Data
//   List<ChartData> _getChartData() {
//     int safe = _history.where((s) => s.status == "SAFE").length;
//     int phishing = _history.where((s) => s.status == "PHISHING").length;
//     int suspicious = _history.where((s) => s.status == "SUSPICIOUS").length;

//     return [
//       ChartData('Safe', safe.toDouble(), Colors.greenAccent),
//       ChartData('Phishing', phishing.toDouble(), Colors.redAccent),
//       ChartData('Suspicious', suspicious.toDouble(), Colors.orangeAccent),
//     ];
//   }

//   @override
//   void dispose() {
//     _analysisTimer?.cancel();
//     _urlController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E21),
//       appBar: AppBar(
//         title: const Text(
//           "🛡️ CYBERSHIELD DASHBOARD",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.history, color: Colors.blueAccent),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const ScanHistoryScreen(),
//                 ),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.redAccent),
//             onPressed: () async {
//               final authRepo = AuthRepository();
//               await authRepo.logout();
//               if (mounted) {
//                 Navigator.pushNamedAndRemoveUntil(
//                   context,
//                   '/',
//                   (route) => false,
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       body: BlocConsumer<ScanBloc, ScanState>(
//         listener: (context, state) {
//           if (state is ScanLoading) _startAnalysisAnimation();
//           if (state is ScanFailure) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.error), backgroundColor: Colors.red),
//             );
//           }
//           if (state is ScanSuccess) _loadHistory();
//         },
//         builder: (context, state) {
//           return SingleChildScrollView(
//             // Added scroll for charts
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 children: [
//                   // --- Chart Section ---
//                   if (_history.isNotEmpty && state is! ScanLoading)
//                     _buildAnalyticsChart(),

//                   const Text(
//                     "Enter URL for Security Analysis",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white70,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextField(
//                     controller: _urlController,
//                     style: const TextStyle(color: Colors.white),
//                     decoration: InputDecoration(
//                       hintText: "example.com",
//                       hintStyle: const TextStyle(color: Colors.white38),
//                       prefixIcon: const Icon(
//                         Icons.link,
//                         color: Colors.cyanAccent,
//                       ),
//                       filled: true,
//                       fillColor: Colors.white.withOpacity(0.05),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   if (state is ScanLoading)
//                     _buildAnimatedLoader()
//                   else
//                     _buildScanButton(),
//                   const SizedBox(height: 30),
//                   if (state is ScanSuccess) _buildResultCard(state.result),
//                   const SizedBox(height: 20),
//                   const Divider(color: Colors.white24),
//                   _buildHistoryHeader(),
//                   Container(
//                     height: 300, // Fixed height for list in scrollview
//                     child: _buildHistoryList(),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // 🔥 NAYA WIDGET: Analytics Pie Chart
//   Widget _buildAnalyticsChart() {
//     return Container(
//       height: 200,
//       margin: const EdgeInsets.only(bottom: 30),
//       child: SfCircularChart(
//         legend: Legend(
//           isVisible: true,
//           textStyle: const TextStyle(color: Colors.white70, fontSize: 10),
//         ),
//         series: <CircularSeries>[
//           PieSeries<ChartData, String>(
//             dataSource: _getChartData(),
//             xValueMapper: (ChartData data, _) => data.x,
//             yValueMapper: (ChartData data, _) => data.y,
//             pointColorMapper: (ChartData data, _) => data.color,
//             dataLabelSettings: const DataLabelSettings(isVisible: true),
//             radius: '80%',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnimatedLoader() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const CircularProgressIndicator(color: Colors.cyanAccent),
//           const SizedBox(height: 30),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: List.generate(_currentStep + 1, (index) {
//               return AnimatedOpacity(
//                 duration: const Duration(milliseconds: 500),
//                 opacity: 1.0,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 6),
//                   child: Row(
//                     children: [
//                       Icon(
//                         index < _currentStep
//                             ? Icons.check_circle
//                             : Icons.chevron_right,
//                         color: index < _currentStep
//                             ? Colors.greenAccent
//                             : Colors.cyanAccent,
//                         size: 18,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           _analysisSteps[index],
//                           style: TextStyle(
//                             color: index == _currentStep
//                                 ? Colors.cyanAccent
//                                 : Colors.white38,
//                             fontWeight: index == _currentStep
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildScanButton() {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         minimumSize: const Size(double.infinity, 55),
//         backgroundColor: Colors.cyanAccent,
//         foregroundColor: Colors.black,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       onPressed: () {
//         if (_urlController.text.isNotEmpty) {
//           context.read<ScanBloc>().add(UrlScanRequested(_urlController.text));
//         }
//       },
//       child: const Text(
//         "START DEEP ANALYSIS",
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _buildHistoryHeader() {
//     return const Padding(
//       padding: EdgeInsets.symmetric(vertical: 10),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: Text(
//           "RECENT SCANS",
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: Colors.cyanAccent,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHistoryList() {
//     return _history.isEmpty
//         ? const Center(
//             child: Text(
//               "No history available",
//               style: TextStyle(color: Colors.white38),
//             ),
//           )
//         : ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: _history.length,
//             itemBuilder: (context, index) => _buildHistoryItem(_history[index]),
//           );
//   }

//   Widget _buildHistoryItem(ScanResultModel item) {
//     Color statusColor = item.status == "SAFE"
//         ? Colors.greenAccent
//         : Colors.redAccent;
//     return Card(
//       color: Colors.white.withOpacity(0.05),
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ScanDetailsScreen(scan: item),
//           ),
//         ),
//         leading: Icon(Icons.shield_outlined, color: statusColor),
//         title: Text(
//           item.url,
//           style: const TextStyle(color: Colors.white, fontSize: 13),
//         ),
//         subtitle: Text(
//           "Risk: ${item.riskScore}%",
//           style: const TextStyle(color: Colors.white38, fontSize: 11),
//         ),
//         trailing: const Icon(
//           Icons.arrow_forward_ios,
//           size: 12,
//           color: Colors.white24,
//         ),
//       ),
//     );
//   }

//   Widget _buildResultCard(dynamic result) {
//     return Container();
//   }
// }

// // 🔥 Helper Class for Chart
// class ChartData {
//   ChartData(this.x, this.y, this.color);
//   final String x;
//   final double y;
//   final Color color;
// }

// import 'dart:async';
// import 'package:cybershield_mobile/features/auth/bloc/scan_bloc.dart';
// import 'package:cybershield_mobile/features/auth/bloc/scan_event.dart';
// import 'package:cybershield_mobile/features/auth/bloc/scan_state.dart';
// import 'package:cybershield_mobile/features/auth/repository/auth_repository.dart';
// import 'package:cybershield_mobile/scan/services/scan_service.dart';
// import 'package:cybershield_mobile/scan/model/scan_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'scan_details_screen.dart';
// import 'scan_history_screen.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class ScanScreen extends StatefulWidget {
//   const ScanScreen({super.key});

//   @override
//   State<ScanScreen> createState() => _ScanScreenState();
// }

// class _ScanScreenState extends State<ScanScreen> {
//   final TextEditingController _urlController = TextEditingController();
//   final ScanService _scanService = ScanService();
//   List<ScanResultModel> _history = [];

//   // --- Live Analysis Variables ---
//   int _currentStep = 0;
//   Timer? _analysisTimer;
//   final List<String> _analysisSteps = [
//     "🔍 Initializing Secure Connection...",
//     "🌐 Fetching DNS & IP Metadata...",
//     "🛡️ Checking Global Blacklists...",
//     "📊 Analyzing Heuristic Risk Score...",
//     "✅ Finalizing Security Report...",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadHistory();
//   }

//   void _startAnalysisAnimation() {
//     setState(() => _currentStep = 0);
//     _analysisTimer?.cancel();
//     _analysisTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
//       if (_currentStep < _analysisSteps.length - 1) {
//         setState(() => _currentStep++);
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   Future<void> _loadHistory() async {
//     final results = await _scanService.getScanHistory();
//     if (mounted) {
//       setState(() => _history = results);
//     }
//   }

//   // 🔥 Helper function for Chart Data
//   List<ChartData> _getChartData() {
//     int safe = _history.where((s) => s.status == "SAFE").length;
//     int phishing = _history.where((s) => s.status == "PHISHING").length;
//     int suspicious = _history.where((s) => s.status == "SUSPICIOUS").length;

//     return [
//       ChartData('Safe', safe.toDouble(), Colors.greenAccent),
//       ChartData('Phishing', phishing.toDouble(), Colors.redAccent),
//       ChartData('Suspicious', suspicious.toDouble(), Colors.orangeAccent),
//     ];
//   }

//   @override
//   void dispose() {
//     _analysisTimer?.cancel();
//     _urlController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E21),
//       appBar: AppBar(
//         title: const Text(
//           "🛡️ CYBERSHIELD DASHBOARD",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.history, color: Colors.blueAccent),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const ScanHistoryScreen(),
//                 ),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.redAccent),
//             onPressed: () async {
//               final authRepo = AuthRepository();
//               await authRepo.logout();
//               if (mounted) {
//                 Navigator.pushNamedAndRemoveUntil(
//                   context,
//                   '/',
//                   (route) => false,
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       body: BlocConsumer<ScanBloc, ScanState>(
//         listener: (context, state) {
//           if (state is ScanLoading) _startAnalysisAnimation();
//           if (state is ScanFailure) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.error), backgroundColor: Colors.red),
//             );
//           }
//           if (state is ScanSuccess) _loadHistory();
//         },
//         builder: (context, state) {
//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start, // Left alignment ke liye
//                 children: [
//                   // 🔥 PIE CHART IN CARD (TOP LEFT CORNER)
//                   if (_history.isNotEmpty && state is! ScanLoading)
//                     Align(
//                       alignment: Alignment.topLeft,
//                       child: Container(
//                         width:
//                             MediaQuery.of(context).size.width *
//                             0.5, // Chhota size taaki corner mein rahe
//                         margin: const EdgeInsets.only(bottom: 24),
//                         child: Card(
//                           color: Colors.white.withOpacity(0.05),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                             side: BorderSide(
//                               color: Colors.cyanAccent.withOpacity(0.2),
//                             ),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: _buildAnalyticsChart(),
//                           ),
//                         ),
//                       ),
//                     ),

//                   const Center(
//                     child: Text(
//                       "Enter URL for Security Analysis",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextField(
//                     controller: _urlController,
//                     style: const TextStyle(color: Colors.white),
//                     decoration: InputDecoration(
//                       hintText: "example.com",
//                       hintStyle: const TextStyle(color: Colors.white38),
//                       prefixIcon: const Icon(
//                         Icons.link,
//                         color: Colors.cyanAccent,
//                       ),
//                       filled: true,
//                       fillColor: Colors.white.withOpacity(0.05),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   if (state is ScanLoading)
//                     _buildAnimatedLoader()
//                   else
//                     _buildScanButton(),
//                   const SizedBox(height: 30),
//                   if (state is ScanSuccess) _buildResultCard(state.result),
//                   const SizedBox(height: 20),
//                   const Divider(color: Colors.white24),
//                   _buildHistoryHeader(),
//                   Container(height: 300, child: _buildHistoryList()),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // 🔥 NAYA WIDGET: Analytics Pie Chart
//   Widget _buildAnalyticsChart() {
//     return SfCircularChart(
//       margin: EdgeInsets.zero,
//       legend: Legend(
//         isVisible: true,
//         position: LegendPosition
//             .bottom, // Legend ko niche rakha taaki card chhota rahe
//         textStyle: const TextStyle(color: Colors.white70, fontSize: 8),
//       ),
//       series: <CircularSeries>[
//         PieSeries<ChartData, String>(
//           dataSource: _getChartData(),
//           xValueMapper: (ChartData data, _) => data.x,
//           yValueMapper: (ChartData data, _) => data.y,
//           pointColorMapper: (ChartData data, _) => data.color,
//           dataLabelSettings: const DataLabelSettings(
//             isVisible: true,
//             textStyle: TextStyle(fontSize: 8, color: Colors.white),
//           ),
//           radius: '100%',
//         ),
//       ],
//     );
//   }

//   Widget _buildAnimatedLoader() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const CircularProgressIndicator(color: Colors.cyanAccent),
//           const SizedBox(height: 30),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: List.generate(_currentStep + 1, (index) {
//               return AnimatedOpacity(
//                 duration: const Duration(milliseconds: 500),
//                 opacity: 1.0,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 6),
//                   child: Row(
//                     children: [
//                       Icon(
//                         index < _currentStep
//                             ? Icons.check_circle
//                             : Icons.chevron_right,
//                         color: index < _currentStep
//                             ? Colors.greenAccent
//                             : Colors.cyanAccent,
//                         size: 18,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           _analysisSteps[index],
//                           style: TextStyle(
//                             color: index == _currentStep
//                                 ? Colors.cyanAccent
//                                 : Colors.white38,
//                             fontWeight: index == _currentStep
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildScanButton() {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         minimumSize: const Size(double.infinity, 55),
//         backgroundColor: Colors.cyanAccent,
//         foregroundColor: Colors.black,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       onPressed: () {
//         if (_urlController.text.isNotEmpty) {
//           context.read<ScanBloc>().add(UrlScanRequested(_urlController.text));
//         }
//       },
//       child: const Text(
//         "START DEEP ANALYSIS",
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _buildHistoryHeader() {
//     return const Padding(
//       padding: EdgeInsets.symmetric(vertical: 10),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: Text(
//           "RECENT SCANS",
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: Colors.cyanAccent,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHistoryList() {
//     return _history.isEmpty
//         ? const Center(
//             child: Text(
//               "No history available",
//               style: TextStyle(color: Colors.white38),
//             ),
//           )
//         : ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: _history.length,
//             itemBuilder: (context, index) => _buildHistoryItem(_history[index]),
//           );
//   }

//   Widget _buildHistoryItem(ScanResultModel item) {
//     Color statusColor = item.status == "SAFE"
//         ? Colors.greenAccent
//         : Colors.redAccent;
//     return Card(
//       color: Colors.white.withOpacity(0.05),
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ScanDetailsScreen(scan: item),
//           ),
//         ),
//         leading: Icon(Icons.shield_outlined, color: statusColor),
//         title: Text(
//           item.url,
//           style: const TextStyle(color: Colors.white, fontSize: 13),
//         ),
//         subtitle: Text(
//           "Risk: ${item.riskScore}%",
//           style: const TextStyle(color: Colors.white38, fontSize: 11),
//         ),
//         trailing: const Icon(
//           Icons.arrow_forward_ios,
//           size: 12,
//           color: Colors.white24,
//         ),
//       ),
//     );
//   }

//   Widget _buildResultCard(dynamic result) {
//     return Container();
//   }
// }

// class ChartData {
//   ChartData(this.x, this.y, this.color);
//   final String x;
//   final double y;
//   final Color color;
// }

import 'dart:async';
import 'package:cybershield_mobile/features/auth/bloc/scan_bloc.dart';
import 'package:cybershield_mobile/features/auth/bloc/scan_event.dart';
import 'package:cybershield_mobile/features/auth/bloc/scan_state.dart';
import 'package:cybershield_mobile/features/auth/repository/auth_repository.dart';
import 'package:cybershield_mobile/scan/services/scan_service.dart';
import 'package:cybershield_mobile/scan/model/scan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'scan_details_screen.dart';
import 'scan_history_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final TextEditingController _urlController = TextEditingController();
  final ScanService _scanService = ScanService();
  List<ScanResultModel> _history = [];

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

  List<ChartData> _getChartData() {
    int safe = _history.where((s) => s.status == "SAFE").length;
    int phishing = _history.where((s) => s.status == "PHISHING").length;
    int suspicious = _history.where((s) => s.status == "SUSPICIOUS").length;

    return [
      ChartData('Safe', safe.toDouble(), Colors.greenAccent),
      ChartData('Phishing', phishing.toDouble(), Colors.redAccent),
      ChartData('Suspicious', suspicious.toDouble(), Colors.orangeAccent),
    ];
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
      body: BlocConsumer<ScanBloc, ScanState>(
        listener: (context, state) {
          if (state is ScanLoading) _startAnalysisAnimation();
          if (state is ScanFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
          if (state is ScanSuccess) _loadHistory();
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // 🔥 TOP SECTION: SPLIT LAYOUT (Chart Left, Recent Scans Right)
                const SizedBox(height: 10),
                SizedBox(
                  height: 220, // Dono side ki fix height
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT SIDE: PIE CHART CARD
                      Expanded(
                        flex: 5,
                        child: _history.isNotEmpty && state is! ScanLoading
                            ? Card(
                                color: Colors.white.withOpacity(0.05),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(
                                    color: Colors.cyanAccent.withOpacity(0.2),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _buildAnalyticsChart(),
                                ),
                              )
                            : Container(),
                      ),
                      const SizedBox(width: 12),
                      // RIGHT SIDE: SCROLLABLE RECENT SCANS
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
                              child: _buildHistoryList(
                                isMini: true,
                              ), // Mini version for split view
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // CENTER: SCANNER SECTION
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    "Enter URL for Security Analysis",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
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
                if (state is ScanLoading)
                  _buildAnimatedLoader()
                else
                  _buildScanButton(),
                const SizedBox(height: 30),
                if (state is ScanSuccess) _buildResultCard(state.result),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsChart() {
    return SfCircularChart(
      margin: EdgeInsets.zero,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        textStyle: const TextStyle(color: Colors.white70, fontSize: 8),
      ),
      series: <CircularSeries>[
        PieSeries<ChartData, String>(
          dataSource: _getChartData(),
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          pointColorMapper: (ChartData data, _) => data.color,
          radius: '100%',
        ),
      ],
    );
  }

  Widget _buildAnimatedLoader() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.cyanAccent),
          const SizedBox(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_currentStep + 1, (index) {
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: 1.0,
                child: Padding(
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
                      Expanded(
                        child: Text(
                          _analysisSteps[index],
                          style: TextStyle(
                            color: index == _currentStep
                                ? Colors.cyanAccent
                                : Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildHistoryList({bool isMini = false}) {
    return _history.isEmpty
        ? const Center(
            child: Text(
              "No records",
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            itemCount: _history.length,
            itemBuilder: (context, index) =>
                _buildHistoryItem(_history[index], isMini: isMini),
          );
  }

  Widget _buildHistoryItem(ScanResultModel item, {bool isMini = false}) {
    Color statusColor = item.status == "SAFE"
        ? Colors.greenAccent
        : Colors.redAccent;
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: isMini,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanDetailsScreen(scan: item),
          ),
        ),
        leading: Icon(
          Icons.shield_outlined,
          color: statusColor,
          size: isMini ? 16 : 24,
        ),
        title: Text(
          item.url,
          style: TextStyle(color: Colors.white, fontSize: isMini ? 10 : 13),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 10,
          color: Colors.white24,
        ),
      ),
    );
  }

  Widget _buildResultCard(dynamic result) => Container();
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
