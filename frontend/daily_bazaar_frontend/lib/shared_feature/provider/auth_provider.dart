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

final loginProvider = FutureProvider.family<AuthResponse, LoginRequest>((
  ref,
  req,
) async {
  final api = ref.watch(authApiProvider);
  return api.login(req);
});

final registerProvider = FutureProvider.family<AuthResponse, RegisterRequest>((
  ref,
  req,
) async {
  final api = ref.watch(authApiProvider);
  return api.register(req);
});
