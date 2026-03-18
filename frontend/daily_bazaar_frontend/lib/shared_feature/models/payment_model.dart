/// Response from initiating a payment via UroPay
class PaymentInitResponse {
  const PaymentInitResponse({
    required this.uroPayOrderId,
    required this.upiString,
    required this.qrCode,
    required this.amountInRupees,
    required this.paymentStatus,
  });

  final String uroPayOrderId;
  final String upiString;
  final String qrCode; // base64 data URI
  final String amountInRupees;
  final String paymentStatus;

  factory PaymentInitResponse.fromJson(Map<String, dynamic> json) {
    return PaymentInitResponse(
      uroPayOrderId: json['uropay_order_id'] as String? ?? '',
      upiString: json['upi_string'] as String? ?? '',
      qrCode: json['qr_code'] as String? ?? '',
      amountInRupees: json['amount_in_rupees'] as String? ?? '',
      paymentStatus: json['payment_status'] as String? ?? '',
    );
  }
}

/// Response from polling payment status
class PaymentStatusResponse {
  const PaymentStatusResponse({
    required this.orderId,
    required this.paymentStatus,
    this.uroPayOrderId,
    this.uroPayStatus,
  });

  final String orderId;
  final String paymentStatus;
  final String? uroPayOrderId;
  final String? uroPayStatus;

  bool get isCompleted => paymentStatus == 'payment_completed';
  bool get isPending =>
      paymentStatus == 'payment_pending' || paymentStatus == 'payment_created';
  bool get isUpdated => paymentStatus == 'payment_updated';
  bool get isFailed => paymentStatus == 'payment_failed';

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResponse(
      orderId: json['order_id'] as String? ?? '',
      paymentStatus: json['payment_status'] as String? ?? '',
      uroPayOrderId: json['uropay_order_id'] as String?,
      uroPayStatus: json['uropay_status'] as String?,
    );
  }
}
