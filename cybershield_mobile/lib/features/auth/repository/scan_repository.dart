// import 'package:dio/dio.dart';
// import '../../../core/network/dio_client.dart';
// import '../../../core/constants/api_constants.dart';

// class ScanRepository {
//   final Dio _dio = DioClient().instance;

//   Future<Map<String, dynamic>> scanUrl(String url) async {
//     try {
//       // Dio Client automatically JWT token attach karega
//       // Backend GET expect kar raha hai isliye .get use kiya
//       final response = await _dio.get(
//         "${ApiConstants.threatBaseUrl}/scan",
//         queryParameters: {"url": url},
//       );

//       if (response.statusCode == 200) {
//         return response.data as Map<String, dynamic>;
//       } else {
//         throw Exception("Server returned status: ${response.statusCode}");
//       }
//   } on DioException catch (e) {
//   // 🛡️ Service Offline Handle Karna
//   if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
//     throw Exception("🛡️ CyberShield Service is currently offline. Please try again later.");
//   }

//   String errorMsg = e.response?.data?.toString() ?? e.message ?? "Unknown error";
//   throw Exception("Scan failed: $errorMsg");
// }
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_constants.dart';

class ScanRepository {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  // Helper function to get token and headers
  Future<Options> _getOptions() async {
    String? token = await _storage.read(key: "token");
    return Options(
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  /// 🔍 1. URL SCAN (Now using Token instead of username param)
  Future<Map<String, dynamic>> scanUrl(String url) async {
    try {
      final options = await _getOptions();
      final response = await _dio.get(
        "${ApiConstants.threatBaseUrl}/scan",
        queryParameters: {"url": url},
        options: options, // ✅ Token sent in Header
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      _handleDioError(e);
      return {}; // Unreachable due to exception
    }
  }

  /// 📊 2. FETCH STATS (For Pie Chart)
  Future<Map<String, dynamic>> getScanStats() async {
    try {
      final options = await _getOptions();
      final response = await _dio.get(
        "${ApiConstants.threatBaseUrl}/stats", // ✅ No more ?username=...
        options: options,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return {"safe": 0, "phishing": 0, "suspicious": 0, "total": 0};
    } catch (e) {
      print("🔥 Stats Error: $e");
      return {"safe": 0, "phishing": 0, "suspicious": 0, "total": 0};
    }
  }

  /// 📜 3. FETCH HISTORY (For Recent Scans List)
  Future<List<dynamic>> getScanHistory() async {
    try {
      final options = await _getOptions();
      final response = await _dio.get(
        "${ApiConstants.threatBaseUrl}/history", // ✅ No more ?username=...
        options: options,
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("🔥 History Error: $e");
      return [];
    }
  }

  /// 🛡️ Error Handling Utility
  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      throw Exception("🛡️ CyberShield Service is offline. Please try later.");
    }
    if (e.response?.statusCode == 403) {
      throw Exception("🚫 Session expired. Please login again.");
    }
    String errorMsg =
        e.response?.data?.toString() ?? e.message ?? "Unknown error";
    throw Exception("Scan failed: $errorMsg");
  }
}
