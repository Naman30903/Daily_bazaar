import 'package:daily_bazaar_frontend/shared_feature/models/product_model.dart';

/// Represents an item in the shopping cart
class CartItem {
  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.priceCentsSnapshot,
    this.mrpCentsSnapshot,
  });

  final String id;
  final Product product;
  final int quantity;
  final int priceCentsSnapshot; // Price at time of adding to cart
  final int? mrpCentsSnapshot; // MRP at time of adding to cart

  int get totalPriceCents => priceCentsSnapshot * quantity;
  int? get totalMrpCents =>
      mrpCentsSnapshot != null ? mrpCentsSnapshot! * quantity : null;

  double get totalPriceInRupees => totalPriceCents / 100;
  double? get totalMrpInRupees =>
      totalMrpCents != null ? totalMrpCents! / 100 : null;

  String get formattedTotalPrice => '₹${totalPriceInRupees.toStringAsFixed(0)}';
  String? get formattedTotalMrp => totalMrpInRupees != null
      ? '₹${totalMrpInRupees!.toStringAsFixed(0)}'
      : null;

  int? get savingsPerItemCents {
    if (mrpCentsSnapshot == null ||
        mrpCentsSnapshot! <= priceCentsSnapshot) {
      return null;
    }
    return mrpCentsSnapshot! - priceCentsSnapshot;
  }

  int? get totalSavingsCents {
    final perItem = savingsPerItemCents;
    return perItem != null ? perItem * quantity : null;
  }

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    int? priceCentsSnapshot,
    int? mrpCentsSnapshot,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      priceCentsSnapshot: priceCentsSnapshot ?? this.priceCentsSnapshot,
      mrpCentsSnapshot: mrpCentsSnapshot ?? this.mrpCentsSnapshot,
    );
  }
}

/// Types of delivery instructions
enum DeliveryInstructionType {
  pressHereAndHold,
  avoidCalling,
  dontRingBell,
}

/// Represents a delivery instruction option
class DeliveryInstruction {
  const DeliveryInstruction({
    required this.type,
    required this.label,
    required this.enabled,
  });

  final DeliveryInstructionType type;
  final String label;
  final bool enabled;

  DeliveryInstruction copyWith({
    DeliveryInstructionType? type,
    String? label,
    bool? enabled,
  }) {
    return DeliveryInstruction(
      type: type ?? this.type,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// Bill details and charges
class BillDetails {
  const BillDetails({
    required this.itemsTotalCents,
    required this.savedAmountCents,
    required this.handlingChargeCents,
    this.surgeChargeCents,
    this.deliveryFeeCents = 0,
  });

  final int itemsTotalCents;
  final int savedAmountCents;
  final int handlingChargeCents;
  final int? surgeChargeCents;
  final int deliveryFeeCents;

  double get itemsTotalInRupees => itemsTotalCents / 100;
  double get savedAmountInRupees => savedAmountCents / 100;
  double get handlingChargeInRupees => handlingChargeCents / 100;
  double? get surgeChargeInRupees =>
      surgeChargeCents != null ? surgeChargeCents! / 100 : null;
  double get deliveryFeeInRupees => deliveryFeeCents / 100;

  int get grandTotalCents {
    return itemsTotalCents +
        handlingChargeCents +
        (surgeChargeCents ?? 0) +
        deliveryFeeCents;
  }

  double get grandTotalInRupees => grandTotalCents / 100;

  String get formattedItemsTotal => '₹${itemsTotalInRupees.toStringAsFixed(0)}';
  String get formattedSavedAmount => '₹${savedAmountInRupees.toStringAsFixed(0)}';
  String get formattedHandlingCharge =>
      '₹${handlingChargeInRupees.toStringAsFixed(0)}';
  String? get formattedSurgeCharge => surgeChargeInRupees != null
      ? '₹${surgeChargeInRupees!.toStringAsFixed(0)}'
      : null;
  String get formattedGrandTotal => '₹${grandTotalInRupees.toStringAsFixed(0)}';

  /// Returns true if surge charge should be waived (items total >= ₹499)
  bool get isSurgeChargeWaived => itemsTotalCents >= 49900;

  BillDetails copyWith({
    int? itemsTotalCents,
    int? savedAmountCents,
    int? handlingChargeCents,
    int? surgeChargeCents,
    bool clearSurgeCharge = false,
    int? deliveryFeeCents,
  }) {
    return BillDetails(
      itemsTotalCents: itemsTotalCents ?? this.itemsTotalCents,
      savedAmountCents: savedAmountCents ?? this.savedAmountCents,
      handlingChargeCents: handlingChargeCents ?? this.handlingChargeCents,
      surgeChargeCents:
          clearSurgeCharge ? null : (surgeChargeCents ?? this.surgeChargeCents),
      deliveryFeeCents: deliveryFeeCents ?? this.deliveryFeeCents,
    );
  }
}

/// Donation information
class DonationInfo {
  const DonationInfo({
    required this.title,
    required this.description,
    required this.defaultAmountCents,
    this.imageUrl,
  });

  final String title;
  final String description;
  final int defaultAmountCents;
  final String? imageUrl;

  double get defaultAmountInRupees => defaultAmountCents / 100;
  String get formattedDefaultAmount =>
      '₹${defaultAmountInRupees.toStringAsFixed(0)}';
}
