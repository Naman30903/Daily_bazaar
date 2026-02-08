// ...existing code...
import 'package:daily_bazaar_frontend/shared_feature/models/auth_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:daily_bazaar_frontend/shared_feature/helper/api_exception.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/config.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/hive.dart';
import 'package:daily_bazaar_frontend/shared_feature/api/user_api.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/address_model.dart';

part 'user_provider.g.dart';

class ProfileData {
  const ProfileData({required this.user, required this.addresses});
  final User user;
  final List<UserAddress> addresses;
}

@riverpod
class UserController extends _$UserController {
  ApiClient? _client;
  UserApi? _api;

  Future<String> _tokenOrThrow() async {
    final token = TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Not authenticated');
    }
    return token;
  }

  @override
  Future<ProfileData> build() async {
    if (_client == null) {
      _client = ApiClient(baseUrl: AppEnvironment.apiBaseUrl);
      ref.onDispose(_client!.close);
      _api = UserApi(_client!);
    }

    final token = await _tokenOrThrow();
    final user = await _api!.getMe(token);
    final addresses = await _api!.listAddresses(token);
    return ProfileData(user: user, addresses: addresses);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final data = await build();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<UserAddress> createAddress(CreateAddressRequest req) async {
    final token = await _tokenOrThrow();
    final addr = await _api!.createAddress(token, req);
    // refresh cached data
    await refresh();
    return addr;
  }

  Future<UserAddress> updateAddress(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final token = await _tokenOrThrow();
    final addr = await _api!.updateAddress(token, id, updates);
    await refresh();
    return addr;
  }

  Future<void> deleteAddress(String id) async {
    final token = await _tokenOrThrow();
    await _api!.deleteAddress(token, id);
    await refresh();
  }
}
// ...existing code...