import '../helper/api_exception.dart';
import '../models/auth_model.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  /// Expected Go backend endpoint: POST /auth/login
  Future<AuthResponse> login(LoginRequest request) async {
    final json = await _client.postJson('/auth/login', body: request.toJson());
    return AuthResponse.fromJson(json);
  }

  /// Expected Go backend endpoint: POST /auth/register
  Future<AuthResponse> register(RegisterRequest request) async {
    final json = await _client.postJson(
      '/auth/register',
      body: request.toJson(),
    );
    return AuthResponse.fromJson(json);
  }
}
