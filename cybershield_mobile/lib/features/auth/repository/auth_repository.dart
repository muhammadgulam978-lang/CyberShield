import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(validateStatus: (status) => status! < 500));
  final _storage = const FlutterSecureStorage();

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}/api/auth/login",
        data: {"username": username, "password": password},
      );

      if (response.statusCode == 200) {
        String token = "";

        // Agar response JSON Map hai: { "token": "ey..." }
        if (response.data is Map) {
          token = response.data['token']?.toString() ?? "";
        }
        // Agar response sirf plain text hai
        else {
          token = response.data.toString();
        }

        // Quotes aur extra spaces saaf karein
        token = token.replaceAll('"', '').trim();

        // Check karein ke ye valid JWT format hai (Dots mojood hon)
        if (token.contains(".") && token.length > 20) {
          await _storage.write(key: "token", value: token);
          print("✅ SUCCESS: Valid Token Saved!");
          return true;
        } else {
          print("❌ ERROR: Backend returned non-JWT data: $token");
          return false;
        }
      }
      print("❌ LOGIN FAILED: Status ${response.statusCode}");
      return false;
    } catch (e) {
      print("🔥 DIO EXCEPTION: $e");
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: "token");
    print("🗑️ DEBUG: Token Deleted from Storage");
  }

  Future<String?> getToken() async {
    return await _storage.read(key: "token");
  }
}
