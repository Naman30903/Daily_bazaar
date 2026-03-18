import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared_feature/api/payment_api.dart';
import '../../shared_feature/config/config.dart';
import '../../shared_feature/helper/api_exception.dart';
import '../../shared_feature/models/payment_model.dart';

/// Screen shown after order placement to handle UPI payment via UroPay.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.customerEmail,
    required this.authToken,
    required this.amountDisplay,
    required this.amountInRupees,
  });

  final String orderId;
  final String customerName;
  final String customerEmail;
  final String authToken;
  final String amountDisplay;
  final double amountInRupees;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late final PaymentApi _paymentApi;
  final _refController = TextEditingController();

  PaymentInitResponse? _initResponse;
  PaymentStatusResponse? _statusResponse;
  bool _isLoading = true;
  bool _isSubmittingRef = false;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    final client = ApiClient(baseUrl: AppEnvironment.apiBaseUrl);
    _paymentApi = PaymentApi(client);
    _initiatePayment();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _refController.dispose();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final resp = await _paymentApi.initiatePayment(
        orderId: widget.orderId,
        customerName: widget.customerName,
        customerEmail: widget.customerEmail,
        authToken: widget.authToken,
        amount: widget.amountInRupees,
      );
      setState(() {
        _initResponse = resp;
        _isLoading = false;
      });
      _startPolling();
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to initiate payment';
        _isLoading = false;
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final status = await _paymentApi.getPaymentStatus(
          orderId: widget.orderId,
          authToken: widget.authToken,
        );
        if (mounted) {
          setState(() => _statusResponse = status);
          if (status.isCompleted) {
            _pollTimer?.cancel();
            _showPaymentSuccess();
          }
        }
      } catch (_) {
        // Silently continue polling
      }
    });
  }

  Future<void> _submitReference() async {
    final ref = _refController.text.trim();
    if (ref.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter UPI Reference Number')),
      );
      return;
    }

    setState(() => _isSubmittingRef = true);
    try {
      await _paymentApi.submitReference(
        orderId: widget.orderId,
        referenceNumber: ref,
        authToken: widget.authToken,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reference submitted. Verifying payment...')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingRef = false);
    }
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Payment Successful'),
        content: const Text('Your payment has been confirmed. Your order is being processed.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Pop back to home or orders screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Future<void> _openUpiApp() async {
    if (_initResponse == null) return;
    final uri = Uri.parse(_initResponse!.upiString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No UPI app found. Please scan the QR code instead.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(cs, textTheme)
              : _buildPaymentContent(cs, textTheme),
    );
  }

  Widget _buildError(ColorScheme cs, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            const SizedBox(height: 16),
            Text(_error!, style: textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: _initiatePayment, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentContent(ColorScheme cs, TextTheme textTheme) {
    final resp = _initResponse!;
    final isCompleted = _statusResponse?.isCompleted ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('Amount to Pay', style: textTheme.labelLarge?.copyWith(color: cs.onPrimaryContainer)),
                const SizedBox(height: 4),
                Text(
                  widget.amountDisplay,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // QR Code
          if (resp.qrCode.isNotEmpty) ...[
            Text('Scan QR Code to Pay', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: _buildQrImage(resp.qrCode),
            ),
            const SizedBox(height: 16),
          ],

          // Open UPI App button
          OutlinedButton.icon(
            onPressed: _openUpiApp,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Pay with UPI App'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // UPI Reference Number input
          Text(
            'After payment, enter UPI Reference Number',
            style: textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You can find this in your UPI app\'s transaction history',
            style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _refController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'UPI Reference Number',
              hintText: 'e.g. 430686551035',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.receipt_long),
              suffixIcon: _isSubmittingRef
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),

          FilledButton(
            onPressed: isCompleted ? null : _submitReference,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(isCompleted ? 'Payment Verified' : 'Submit Reference'),
          ),

          const SizedBox(height: 24),

          // Payment status indicator
          _buildStatusIndicator(cs, textTheme),
        ],
      ),
    );
  }

  Widget _buildQrImage(String qrDataUri) {
    // qrCode is a data URI like "data:image/png;base64,..."
    try {
      final base64Str = qrDataUri.split(',').last;
      final bytes = base64Decode(base64Str);
      return Image.memory(bytes, width: 220, height: 220, fit: BoxFit.contain);
    } catch (_) {
      return const SizedBox(
        width: 220,
        height: 220,
        child: Center(child: Text('QR Code unavailable')),
      );
    }
  }

  Widget _buildStatusIndicator(ColorScheme cs, TextTheme textTheme) {
    final status = _statusResponse?.paymentStatus ?? _initResponse?.paymentStatus ?? '';

    IconData icon;
    Color color;
    String label;

    switch (status) {
      case 'payment_completed':
        icon = Icons.check_circle;
        color = Colors.green;
        label = 'Payment Confirmed';
      case 'payment_updated':
        icon = Icons.hourglass_top;
        color = Colors.orange;
        label = 'Verifying Payment...';
      case 'payment_created':
        icon = Icons.qr_code;
        color = cs.primary;
        label = 'Awaiting Payment';
      default:
        icon = Icons.pending;
        color = cs.onSurfaceVariant;
        label = 'Payment Pending';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
