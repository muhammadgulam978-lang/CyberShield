import 'package:cybershield_mobile/scan/model/scan_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ScanService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  final String baseUrl = "http://localhost:9091/api/threat";

  Future<ScanResultModel?> performScan(String url) async {
    try {
      String? username = await _storage.read(key: "username") ?? "Guest";

      final response = await _dio.get(
        '$baseUrl/scan',
        queryParameters: {'url': url, 'username': username},
      );

      if (response.statusCode == 200) {
        return ScanResultModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("Scan Error: $e");
      return null;
    }
  }

  // FIXED: Removed the unnecessary String s parameter
  Future<List<ScanResultModel>> getScanHistory() async {
    try {
      String? username = await _storage.read(key: "username") ?? "Guest";

      final response = await _dio.get(
        '$baseUrl/history',
        queryParameters: {'username': username},
      );

      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => ScanResultModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("History Error: $e");
      return [];
    }
  }
}
