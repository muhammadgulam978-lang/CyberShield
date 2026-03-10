import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class ScanRepository {
  final Dio _dio = DioClient().instance;

  Future<Map<String, dynamic>> scanUrl(String url) async {
    try {
      // Dio Client automatically JWT token attach karega
      // Backend GET expect kar raha hai isliye .get use kiya
      final response = await _dio.get(
        "${ApiConstants.threatBaseUrl}/scan", 
        queryParameters: {"url": url},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Server returned status: ${response.statusCode}");
      }
  } on DioException catch (e) {
  // 🛡️ Service Offline Handle Karna
  if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
    throw Exception("🛡️ CyberShield Service is currently offline. Please try again later.");
  }
  
  String errorMsg = e.response?.data?.toString() ?? e.message ?? "Unknown error";
  throw Exception("Scan failed: $errorMsg");
}
  }
}