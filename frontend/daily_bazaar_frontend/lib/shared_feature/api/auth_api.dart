import '../helper/api_exception.dart';
import '../models/auth_model.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  /// Go backend endpoint: POST /api/auth/login
  Future<AuthResponse> login(LoginRequest request) async {
    final json = await _client.postJson(
      '/api/auth/login',
      body: request.toJson(),
    );
    return AuthResponse.fromJson(json);
  }

  /// Go backend endpoint: POST /api/auth/register
  Future<AuthResponse> register(RegisterRequest request) async {
    final json = await _client.postJson(
      '/api/auth/register',
      body: request.toJson(),
    );
    return AuthResponse.fromJson(json);
  }

  /// Go backend endpoint: POST /api/auth/forgot-password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await _client.postJson(
      '/api/auth/forgot-password',
      body: {'email': email},
    );
  }

  /// Go backend endpoint: POST /api/auth/reset-password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    return await _client.postJson(
      '/api/auth/reset-password',
      body: {
        'email': email,
        'otp': otp,
        'new_password': newPassword,
      },
    );
  }
}
