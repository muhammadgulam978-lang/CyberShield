class ScanResultModel {
  final int? id;
  final String url;
  final int riskScore;
  final String status;
  final String? scanTimestamp;
  final String? username;
  final String? ipAddress; // 👈 Yeh missing tha, isliye error aa raha tha

  ScanResultModel({
    this.id,
    required this.url,
    required this.riskScore,
    required this.status,
    this.scanTimestamp,
    this.username,
    this.ipAddress, // 👈 Constructor mein add kiya
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      id: json['id'],
      url: json['url'] ?? '',
      riskScore: json['riskScore'] ?? 0,
      status: json['status'] ?? 'UNKNOWN',
      scanTimestamp: json['scanTimestamp'],
      username: json['username'],
      ipAddress: json['ipAddress'] ?? 'N/A', // 👈 JSON se map kiya
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'riskScore': riskScore,
      'status': status,
      'scanTimestamp': scanTimestamp,
      'username': username,
      'ipAddress': ipAddress,
    };
  }
}
