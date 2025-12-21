import 'package:daily_bazaar_frontend/shared_feature/models/address_model.dart';
import 'package:http/http.dart';

import '../helper/api_exception.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';

class UserApi {
  UserApi(this._client);

  final ApiClient _client;

  /// Get current user profile: GET /api/user/me
  Future<User> getMe(String token) async {
    final json = await _client.getJson(
      '/api/user/me',
      headers: {'Authorization': 'Bearer $token'},
    );
    return User.fromJson(json);
  }

  /// List user addresses: GET /api/user/addresses
  Future<List<UserAddress>> listAddresses(String token) async {
    final json = await _client.getJsonList(
      '/api/user/addresses',
      headers: {'Authorization': 'Bearer $token'},
    );
    return json.map((item) => UserAddress.fromJson(item)).toList();
  }

  /// Create address: POST /api/user/addresses
  Future<UserAddress> createAddress(
    String token,
    CreateAddressRequest request,
  ) async {
    final json = await _client.postJson(
      '/api/user/addresses',
      body: request.toJson(),
      headers: {'Authorization': 'Bearer $token'},
    );
    return UserAddress.fromJson(json);
  }

  /// Update address: PUT /api/user/addresses/{id}
  Future<UserAddress> updateAddress(
    String token,
    String addressId,
    Map<String, dynamic> updates,
  ) async {
    final json = await _client.putJson(
      '/api/user/addresses/$addressId',
      body: updates,
      headers: {'Authorization': 'Bearer $token'},
    );
    return UserAddress.fromJson(json);
  }

  /// Delete address: DELETE /api/user/addresses/{id}
  Future<void> deleteAddress(String token, String addressId) async {
    await _client.delete(
      '/api/user/addresses/$addressId',
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
