import '../helper/api_exception.dart';
import '../models/payment_model.dart';

class PaymentApi {
  PaymentApi(this._client);

  final ApiClient _client;

  /// POST /api/payments/initiate
  Future<PaymentInitResponse> initiatePayment({
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String authToken,
    required double amount,
  }) async {
    final json = await _client.postJson(
      '/api/payments/initiate',
      body: {
        'order_id': orderId,
        'customer_name': customerName,
        'customer_email': customerEmail,
        'amount': amount,
      },
      headers: {'Authorization': 'Bearer $authToken'},
    );
    return PaymentInitResponse.fromJson(json);
  }

  /// POST /api/payments/reference
  Future<void> submitReference({
    required String orderId,
    required String referenceNumber,
    required String authToken,
  }) async {
    await _client.postJson(
      '/api/payments/reference',
      body: {
        'order_id': orderId,
        'reference_number': referenceNumber,
      },
      headers: {'Authorization': 'Bearer $authToken'},
    );
  }

  /// GET /api/payments/status/:orderId
  Future<PaymentStatusResponse> getPaymentStatus({
    required String orderId,
    required String authToken,
  }) async {
    final json = await _client.getJson(
      '/api/payments/status/$orderId',
      headers: {'Authorization': 'Bearer $authToken'},
    );
    return PaymentStatusResponse.fromJson(json);
  }
}
