abstract class ScanEvent {}

/// 🔍 1. Jab user URL enter karke "Start Analysis" dabaye
class UrlScanRequested extends ScanEvent {
  final String url;
  UrlScanRequested(this.url);
}

/// 📊 2. Jab Dashboard load ho ya Pie Chart refresh karna ho
/// Ye event Backend se Token ke zariye history aur stats mangwayega
class FetchDashboardData extends ScanEvent {
  // Ismein username bhejney ki zaroorat nahi kyunki Backend Token se pehchan lega
}
