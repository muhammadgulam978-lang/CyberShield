// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'scan_event.dart';
// import 'scan_state.dart';
// import '../repository/scan_repository.dart';

// class ScanBloc extends Bloc<ScanEvent, ScanState> {
//   final ScanRepository scanRepository;

//   ScanBloc({required this.scanRepository}) : super(ScanInitial()) {
//     // Event handler for URL scanning
//     on<UrlScanRequested>((event, emit) async {
//       emit(ScanLoading());
//       try {
//         // Threat Service (Port 9091) se data mangwana
//         final result = await scanRepository.scanUrl(event.url);
//         emit(ScanSuccess(result));
//       } catch (e) {
//         emit(ScanFailure(e.toString()));
//       }
//     });
//   }
// }

import 'package:flutter_bloc/flutter_bloc.dart';
import 'scan_event.dart';
import 'scan_state.dart';
import '../repository/scan_repository.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ScanRepository scanRepository;

  ScanBloc({required this.scanRepository}) : super(ScanInitial()) {
    // 🔥 1. URL SCAN REQUEST
    on<UrlScanRequested>((event, emit) async {
      emit(ScanLoading());
      try {
        final result = await scanRepository.scanUrl(event.url);

        // Scan success hone ke baad hum dashboard data dobara fetch karenge
        // taaki Pie Chart aur History foran update ho jaye.
        add(FetchDashboardData());

        emit(ScanSuccess(result));
      } catch (e) {
        emit(ScanFailure(e.toString()));
      }
    });

    // 🔥 2. FETCH DASHBOARD DATA (History + Stats)
    on<FetchDashboardData>((event, emit) async {
      // Is event ka maqsad Dashboard ki list aur chart ko refresh karna hai
      try {
        final stats = await scanRepository.getScanStats();
        final history = await scanRepository.getScanHistory();

        // Yahan hum aik naya state emit kar sakte hain ya existing state ko update
        emit(DashboardDataLoaded(stats: stats, history: history));
      } catch (e) {
        print("🔥 Dashboard Refresh Error: $e");
      }
    });
  }
}
