import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class DioClient {
  static final DioClient _singleton = DioClient._internal();
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  factory DioClient() => _singleton;

  DioClient._internal() {
    // 1. Default base URL Auth Service (9090) rakha hai
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);

    // 2. Interceptor: Request bhejne se pehle Token attach karega
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: "token");
        
        if (token != null) {
          // 🛡️ Format: "Bearer <token>" (Roadmap Phase 3.5: JWT Security)
          options.headers["Authorization"] = "Bearer $token";
          print("===> DEBUG: Attaching Token to: ${options.path}"); // Debugging ke liye
        }
        
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Agar 403 error aaye (Token expire), toh yahan handle ho sakta hai
        print("===> DIO ERROR: ${e.response?.statusCode} - ${e.message}");
        return handler.next(e);
      },
    ));
  }

  Dio get instance => _dio;
}