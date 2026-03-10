abstract class ScanEvent {}

class UrlScanRequested extends ScanEvent {
  final String url;
  UrlScanRequested(this.url);
}