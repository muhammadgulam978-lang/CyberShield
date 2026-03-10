class ScanResultModel {
  final int? id;
  final String url;
  final int riskScore;
  final String status;
  final String? scanTimestamp;
  final String? username;

  ScanResultModel({
    this.id,
    required this.url,
    required this.riskScore,
    required this.status,
    this.scanTimestamp,
    this.username,
  });

  // Backend (JSON) se Flutter object banane ke liye
  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      id: json['id'],
      url: json['url'] ?? '',
      riskScore: json['riskScore'] ?? 0,
      status: json['status'] ?? 'UNKNOWN',
      scanTimestamp: json['scanTimestamp'],
      username: json['username'],
    );
  }

  // Flutter object ko JSON mein badalne ke liye (optional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'riskScore': riskScore,
      'status': status,
      'scanTimestamp': scanTimestamp,
      'username': username,
    };
  }
}