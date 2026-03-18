import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:daily_bazaar_frontend/shared_feature/utils/date_utils.dart';

/// Detailed order view screen.
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final id = order['id'] as String? ?? '';
    final status = order['status'] as String? ?? 'pending';
    final totalCents = (order['total_cents'] as num?)?.toInt() ?? 0;
    final subtotalCents = (order['subtotal_cents'] as num?)?.toInt() ?? 0;
    final shippingCents = (order['shipping_cents'] as num?)?.toInt() ?? 0;
    final taxCents = (order['tax_cents'] as num?)?.toInt() ?? 0;
    final placedAt = order['placed_at'] as String? ?? '';
    final items = order['items'] as List<dynamic>? ?? [];
    final shippingAddress = order['shipping_address'] as Map<String, dynamic>? ?? {};
    final paymentMeta = order['payment_metadata'] as Map<String, dynamic>? ?? {};

    final statusInfo = _getStatusInfo(status, cs);
    final paymentStatus = paymentMeta['payment_status'] as String? ?? '';

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            backgroundColor: cs.surface,
            title: const Text('Order Details'),
            elevation: 0,
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Status hero card
                _StatusHeroCard(
                  status: status,
                  statusInfo: statusInfo,
                  placedAt: placedAt,
                ),

                const SizedBox(height: 16),

                // Order ID
                _InfoCard(
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, size: 20, color: cs.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order ID', style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                            const SizedBox(height: 2),
                            Text(
                              id.toUpperCase(),
                              style: textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, size: 18, color: cs.onSurfaceVariant),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Order ID copied'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Items
                _SectionLabel(title: 'Items (${items.length})'),
                const SizedBox(height: 8),
                _InfoCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0)
                          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.25)),
                        _OrderItemTile(item: items[i] as Map<String, dynamic>),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Bill details
                _SectionLabel(title: 'Bill Details'),
                const SizedBox(height: 8),
                _InfoCard(
                  child: Column(
                    children: [
                      _BillRow(label: 'Subtotal', amountCents: subtotalCents),
                      const SizedBox(height: 8),
                      _BillRow(label: 'Shipping', amountCents: shippingCents),
                      const SizedBox(height: 8),
                      _BillRow(label: 'Tax', amountCents: taxCents),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                          Text(
                            formatRupees(totalCents),
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Payment info
                if (paymentMeta.isNotEmpty) ...[
                  _SectionLabel(title: 'Payment'),
                  const SizedBox(height: 8),
                  _InfoCard(
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.payment,
                          label: 'Method',
                          value: 'UPI',
                        ),
                        if (paymentStatus.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _DetailRow(
                            icon: _paymentStatusIcon(paymentStatus),
                            label: 'Status',
                            value: _paymentStatusLabel(paymentStatus),
                            valueColor: _paymentStatusColor(paymentStatus, cs),
                          ),
                        ],
                        if (paymentMeta['reference_number'] != null) ...[
                          const SizedBox(height: 10),
                          _DetailRow(
                            icon: Icons.tag,
                            label: 'UPI Ref',
                            value: paymentMeta['reference_number'].toString(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Delivery address
                if (shippingAddress.isNotEmpty) ...[
                  _SectionLabel(title: 'Delivery Address'),
                  const SizedBox(height: 8),
                  _InfoCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.primary.withValues(alpha: 0.1),
                          ),
                          child: Icon(Icons.location_on_outlined, size: 18, color: cs.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (shippingAddress['full_name'] != null)
                                Text(
                                  shippingAddress['full_name'].toString(),
                                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                _formatAddress(shippingAddress),
                                style: textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                              if (shippingAddress['phone'] != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.phone_outlined, size: 14, color: cs.onSurfaceVariant),
                                    const SizedBox(width: 6),
                                    Text(
                                      shippingAddress['phone'].toString(),
                                      style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Order timeline
                _SectionLabel(title: 'Timeline'),
                const SizedBox(height: 8),
                _InfoCard(
                  child: _OrderTimeline(status: status, placedAt: placedAt),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAddress(Map<String, dynamic> addr) {
    final parts = <String>[];
    if (addr['address_line1'] != null) parts.add(addr['address_line1'].toString());
    if (addr['address_line2'] != null && addr['address_line2'].toString().isNotEmpty) {
      parts.add(addr['address_line2'].toString());
    }
    if (addr['city'] != null) parts.add(addr['city'].toString());
    if (addr['state'] != null) parts.add(addr['state'].toString());
    if (addr['pincode'] != null) parts.add(addr['pincode'].toString());
    return parts.join(', ');
  }

  IconData _paymentStatusIcon(String status) {
    switch (status) {
      case 'payment_completed': return Icons.check_circle;
      case 'payment_updated': return Icons.hourglass_top;
      case 'payment_created': return Icons.qr_code;
      case 'payment_failed': return Icons.error;
      default: return Icons.pending;
    }
  }

  String _paymentStatusLabel(String status) {
    switch (status) {
      case 'payment_completed': return 'Paid';
      case 'payment_updated': return 'Verifying';
      case 'payment_created': return 'Awaiting Payment';
      case 'payment_failed': return 'Failed';
      default: return 'Pending';
    }
  }

  Color _paymentStatusColor(String status, ColorScheme cs) {
    switch (status) {
      case 'payment_completed': return cs.primary;
      case 'payment_updated': return const Color(0xFFF59E0B);
      case 'payment_failed': return cs.error;
      default: return cs.onSurfaceVariant;
    }
  }

  _StatusInfo _getStatusInfo(String status, ColorScheme cs) {
    switch (status) {
      case 'pending':
        return _StatusInfo(icon: Icons.schedule, label: 'Order Placed', color: const Color(0xFFF59E0B));
      case 'confirmed':
        return _StatusInfo(icon: Icons.thumb_up_outlined, label: 'Order Confirmed', color: cs.primary);
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

// --- Reusable widgets ---

class _StatusHeroCard extends StatelessWidget {
  const _StatusHeroCard({required this.status, required this.statusInfo, required this.placedAt});

  final String status;
  final _StatusInfo statusInfo;
  final String placedAt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusInfo.color.withValues(alpha: 0.12),
            statusInfo.color.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusInfo.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusInfo.color.withValues(alpha: 0.15),
            ),
            child: Icon(statusInfo.icon, size: 28, color: statusInfo.color),
          ),
          const SizedBox(height: 12),
          Text(
            statusInfo.label,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: statusInfo.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ISTDateUtils.formatDateTime(placedAt),
            style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final productName = item['product_name'] as String? ?? '';
    final productId = item['product_id'] as String? ?? '';
    final productImage = item['product_image'] as String? ?? '';
    final qty = (item['quantity'] as num?)?.toInt() ?? 1;
    final unitPriceCents = (item['unit_price_cents'] as num?)?.toInt() ?? 0;
    final totalCents = unitPriceCents * qty;

    final displayName = productName.isNotEmpty
        ? productName
        : 'Product ${productId.length > 8 ? productId.substring(0, 8) : productId}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: productImage.isNotEmpty
                ? Image.network(
                    productImage,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 44,
                      height: 44,
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                      child: Icon(Icons.inventory_2_outlined, size: 20, color: cs.onSurfaceVariant),
                    ),
                  )
                : Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.inventory_2_outlined, size: 20, color: cs.onSurfaceVariant),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatRupees(unitPriceCents)} x $qty',
                  style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            formatRupees(totalCents),
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({required this.label, required this.amountCents});
  final String label;
  final int amountCents;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        Text(
          amountCents == 0 ? 'FREE' : formatRupees(amountCents),
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: amountCents == 0 ? cs.primary : null,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value, this.valueColor});
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 10),
        Text(label, style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        const Spacer(),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.status, required this.placedAt});
  final String status;
  final String placedAt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final steps = [
      _TimelineStep('Order Placed', Icons.shopping_cart_outlined, true, placedAt),
      _TimelineStep('Confirmed', Icons.thumb_up_outlined, _isAtLeast('confirmed'), ''),
      _TimelineStep('Shipped', Icons.local_shipping_outlined, _isAtLeast('shipped'), ''),
      _TimelineStep('Delivered', Icons.check_circle_outline, _isAtLeast('delivered'), ''),
    ];

    if (status == 'cancelled') {
      return Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.error.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.cancel, size: 18, color: cs.error),
          ),
          const SizedBox(width: 12),
          Text('Order Cancelled', style: textTheme.bodyMedium?.copyWith(color: cs.error, fontWeight: FontWeight.w600)),
        ],
      );
    }

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _TimelineRow(step: steps[i], isLast: i == steps.length - 1),
        ],
      ],
    );
  }

  bool _isAtLeast(String target) {
    const order = ['pending', 'confirmed', 'shipped', 'delivered'];
    final current = order.indexOf(status);
    final targetIdx = order.indexOf(target);
    return current >= targetIdx;
  }
}

class _TimelineStep {
  const _TimelineStep(this.label, this.icon, this.completed, this.time);
  final String label;
  final IconData icon;
  final bool completed;
  final String time;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step, this.isLast = false});
  final _TimelineStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = step.completed ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.3);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.completed ? color.withValues(alpha: 0.15) : Colors.transparent,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: step.completed
                      ? Icon(step.icon, size: 14, color: color)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: step.completed ? FontWeight.w700 : FontWeight.w400,
                      color: step.completed ? cs.onSurface : cs.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  if (step.time.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      ISTDateUtils.formatDateTime(step.time),
                      style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusInfo {
  const _StatusInfo({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
}
