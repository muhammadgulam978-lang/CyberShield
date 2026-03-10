import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Storage se token uthana
    String? token = await _storage.read(key: "token");

    if (token != null) {
      // Har request ke header mein Token attach karna
      options.headers['Authorization'] = 'Bearer $token';
      print("🔑 INTERCEPTOR: Token added to request");
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
       print("⚠️ INTERCEPTOR: Unauthorized! Token might be deleted.");
       // Yahan hum user ko logout karwa sakte hain
    }
    return handler.next(err);
  }
}