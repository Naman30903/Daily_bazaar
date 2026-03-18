import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/config.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/hive.dart';
import 'package:daily_bazaar_frontend/shared_feature/helper/api_exception.dart';
import 'package:daily_bazaar_frontend/shared_feature/utils/date_utils.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Please log in to view orders';
          _isLoading = false;
        });
        return;
      }

      final client = ApiClient(baseUrl: AppEnvironment.apiBaseUrl);
      final orders = await client.getJsonList(
        '/api/orders/my',
        headers: {'Authorization': 'Bearer $token'},
      );

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load orders';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Your Orders'),
        backgroundColor: cs.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(cs)
              : _orders.isEmpty
                  ? _buildEmpty(cs)
                  : _buildOrderList(cs),
    );
  }

  Widget _buildError(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.errorContainer.withValues(alpha: 0.3),
              ),
              child: Icon(Icons.error_outline, size: 36, color: cs.error),
            ),
            const SizedBox(height: 16),
            Text(_error!, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _fetchOrders,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme cs) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              child: Icon(Icons.shopping_bag_outlined, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),
            Text('No orders yet', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Your order history will appear here\nonce you place your first order',
              style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false),
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(ColorScheme cs) {
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _OrderCard(
            order: order,
            onTap: () {
              Navigator.of(context).pushNamed(
                '/order-detail',
                arguments: order,
              );
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, this.onTap});

  final Map<String, dynamic> order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final status = order['status'] as String? ?? 'pending';
    final totalCents = (order['total_cents'] as num?)?.toInt() ?? 0;
    final placedAt = order['placed_at'] as String? ?? '';
    final items = order['items'] as List<dynamic>? ?? [];
    final id = order['id'] as String? ?? '';

    final statusInfo = _getStatusInfo(status, cs);
    final formattedDate = ISTDateUtils.formatDateTime(placedAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusInfo.color.withValues(alpha: 0.15),
                    ),
                    child: Icon(statusInfo.icon, size: 20, color: statusInfo.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusInfo.label,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: statusInfo.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDate,
                          style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatRupees(totalCents),
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                        style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ID: ${id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase()}',
                      style: textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ...List.generate(4, (i) {
                    final active = _statusProgress(status) > i;
                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Container(
                        width: active ? 20 : 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: active ? statusInfo.color : cs.outlineVariant.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _statusProgress(String status) {
    switch (status) {
      case 'pending': return 1;
      case 'confirmed': return 2;
      case 'shipped': return 3;
      case 'delivered': return 4;
      case 'cancelled': return 0;
      default: return 1;
    }
  }

  _StatusInfo _getStatusInfo(String status, ColorScheme cs) {
    switch (status) {
      case 'pending':
        return _StatusInfo(icon: Icons.schedule, label: 'Order Placed', color: const Color(0xFFF59E0B));
      case 'confirmed':
        return _StatusInfo(icon: Icons.thumb_up_outlined, label: 'Confirmed', color: cs.primary);
      case 'shipped':
        return _StatusInfo(icon: Icons.local_shipping_outlined, label: 'On the Way', color: const Color(0xFF38BDF8));
      case 'delivered':
        return _StatusInfo(icon: Icons.check_circle_outline, label: 'Delivered', color: cs.primary);
      case 'cancelled':
        return _StatusInfo(icon: Icons.cancel_outlined, label: 'Cancelled', color: cs.error);
      default:
        return _StatusInfo(icon: Icons.info_outline, label: status, color: cs.onSurfaceVariant);
    }
  }
}

class _StatusInfo {
  const _StatusInfo({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
}
