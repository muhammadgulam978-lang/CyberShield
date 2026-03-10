import 'package:flutter_bloc/flutter_bloc.dart';
import 'scan_event.dart';
import 'scan_state.dart';
import '../repository/scan_repository.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ScanRepository scanRepository;

  ScanBloc({required this.scanRepository}) : super(ScanInitial()) {
    // Event handler for URL scanning
    on<UrlScanRequested>((event, emit) async {
      emit(ScanLoading());
      try {
        // Threat Service (Port 9091) se data mangwana
        final result = await scanRepository.scanUrl(event.url);
        emit(ScanSuccess(result));
      } catch (e) {
        emit(ScanFailure(e.toString()));
      }
    });
  }
}