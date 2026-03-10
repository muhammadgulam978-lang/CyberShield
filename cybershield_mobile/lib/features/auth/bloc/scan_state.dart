abstract class ScanState {}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {}

class ScanSuccess extends ScanState {
  final Map<String, dynamic> result;
  ScanSuccess(this.result);
}

class ScanFailure extends ScanState {
  final String error;
  ScanFailure(this.error);
}