import 'package:daily_bazaar_frontend/shared_feature/api/auth_api.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/config.dart';
import 'package:daily_bazaar_frontend/shared_feature/helper/api_exception.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/auth_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authApiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(baseUrl: AppEnvironment.apiBaseUrl);
  ref.onDispose(client.close);
  return client;
});

final authApiProvider = Provider<AuthApi>((ref) {
  final client = ref.watch(authApiClientProvider);
  return AuthApi(client);
});

/// Holds the current auth request state (idle/loading/success/error) and exposes
/// imperative methods for login/register.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthResponse?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthResponse?> {
  @override
  Future<AuthResponse?> build() async {
    // idle state by default; screens can read `state` for loading/errors.
    return null;
  }

  Future<AuthResponse> login(LoginRequest request) async {
    state = const AsyncLoading();
    final api = ref.read(authApiProvider);

    try {
      final res = await api.login(request);
      state = AsyncData(res);
      return res;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    state = const AsyncLoading();
    final api = ref.read(authApiProvider);

    try {
      final res = await api.register(request);
      state = AsyncData(res);
      return res;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  void reset() {
    // Useful when you want to clear error messages on page open/back.
    state = const AsyncData(null);
  }
}
