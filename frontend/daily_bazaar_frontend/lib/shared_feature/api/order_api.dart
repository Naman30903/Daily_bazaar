import '../helper/api_exception.dart';

class OrderApi {
  OrderApi(this._client);

  final ApiClient _client;

  /// POST /api/orders - Create a new order
  Future<Map<String, dynamic>> createOrder({
    required Map<String, dynamic> shippingAddress,
    required List<Map<String, dynamic>> items,
    required String authToken,
  }) async {
    return await _client.postJson(
      '/api/orders',
      body: {
        'shipping_address': shippingAddress,
        'items': items,
      },
      headers: {'Authorization': 'Bearer $authToken'},
    );
  }
}
