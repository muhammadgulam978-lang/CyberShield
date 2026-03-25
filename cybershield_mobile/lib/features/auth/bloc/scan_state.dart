// abstract class ScanState {}

// class ScanInitial extends ScanState {}

// class ScanLoading extends ScanState {}

// class ScanSuccess extends ScanState {
//   final Map<String, dynamic> result;
//   ScanSuccess(this.result);
// }

// class ScanFailure extends ScanState {
//   final String error;
//   ScanFailure(this.error);
// }

abstract class ScanState {}

// 1. Initial State (Jab app start ho)
class ScanInitial extends ScanState {}

// 2. Loading State (Jab scan ya refresh ho raha ho)
class ScanLoading extends ScanState {}

// 3. Scan Success (Sirf naye scan ka result dikhane ke liye)
class ScanSuccess extends ScanState {
  final Map<String, dynamic> result;
  ScanSuccess(this.result);
}

// 4. 🔥 DASHBOARD DATA LOADED (History aur Stats ke liye)
// Is state mein hum user ka personal data store karenge
class DashboardDataLoaded extends ScanState {
  final Map<String, dynamic> stats; // Pie chart data
  final List<dynamic> history; // Recent scans list

  DashboardDataLoaded({required this.stats, required this.history});
}

// 5. Failure State (Error handle karne ke liye)
class ScanFailure extends ScanState {
  final String error;
  ScanFailure(this.error);
}
