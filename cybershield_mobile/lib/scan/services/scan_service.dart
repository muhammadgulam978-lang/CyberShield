import 'package:cybershield_mobile/scan/model/scan_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ScanService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  final String baseUrl = "http://localhost:9091/api/threat"; 

  ScanService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await _storage.read(key: "token");
          
          if (token != null && token.isNotEmpty) {
            // Force clean the token again just in case
            String cleanToken = token.trim().replaceAll('"', '');
            options.headers['Authorization'] = 'Bearer $cleanToken';
            print("🚀 SENDING JWT: Bearer $cleanToken"); 
          } else {
            print("⚠️ DEBUG: No token found for request!");
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
            print("❌ SECURITY ERROR: 403 Forbidden - Check JWT Secret/Filter");
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<ScanResultModel?> performScan(String url) async {
    try {
      final response = await _dio.get('$baseUrl/scan', queryParameters: {'url': url});
      if (response.statusCode == 200) {
        return ScanResultModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("Scan Error: $e");
      return null;
    }
  }

  Future<List<ScanResultModel>> getScanHistory(String username) async {
    try {
      final response = await _dio.get('$baseUrl/history', queryParameters: {'username': username});
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