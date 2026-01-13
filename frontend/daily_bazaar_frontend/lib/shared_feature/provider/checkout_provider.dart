import 'package:daily_bazaar_frontend/shared_feature/models/address_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/checkout_models.dart';
import 'package:daily_bazaar_frontend/shared_feature/provider/cart_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'checkout_provider.g.dart';

/// Checkout screen state
class CheckoutState {
  const CheckoutState({
    required this.cartItems,
    required this.deliveryInstructions,
    this.donationAmountCents,
    this.deliveryAddress,
    required this.billDetails,
    this.isLoading = false,
    this.error,
  });

  final List<CartItem> cartItems;
  final List<DeliveryInstruction> deliveryInstructions;
  final int? donationAmountCents;
  final UserAddress? deliveryAddress;
  final BillDetails billDetails;
  final bool isLoading;
  final String? error;

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  int get deliveryMinutes => 17; // Mock value from screenshot

  int get grandTotalWithDonationCents {
    return billDetails.grandTotalCents + (donationAmountCents ?? 0);
  }

  double get grandTotalWithDonationInRupees =>
      grandTotalWithDonationCents / 100;

  String get formattedGrandTotalWithDonation =>
      '₹${grandTotalWithDonationInRupees.toStringAsFixed(0)}';

  CheckoutState copyWith({
    List<CartItem>? cartItems,
    List<DeliveryInstruction>? deliveryInstructions,
    int? donationAmountCents,
    bool clearDonation = false,
    UserAddress? deliveryAddress,
    BillDetails? billDetails,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CheckoutState(
      cartItems: cartItems ?? this.cartItems,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      donationAmountCents: clearDonation
          ? null
          : (donationAmountCents ?? this.donationAmountCents),
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      billDetails: billDetails ?? this.billDetails,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@riverpod
class CheckoutController extends _$CheckoutController {
  static const int _surgeChargeCents = 3000; // ₹30
  static const int _handlingChargeCents = 500; // ₹5
  static const int _surgeChargeWaiverThresholdCents = 49900; // ₹499

  @override
  CheckoutState build() {
    // Watch cart state and sync cart items
    final cartState = ref.watch(cartControllerProvider);
    final cartItems = cartState.cartItems;

    return CheckoutState(
      cartItems: cartItems,
      deliveryInstructions: _getInitialDeliveryInstructions(),
      deliveryAddress: null,
      billDetails: _calculateBillDetails(cartItems),
    );
  }

  /// Increment quantity of a cart item
  void incrementQuantity(String cartItemId) {
    final current = state;
    final updatedItems = current.cartItems.map((item) {
      if (item.id == cartItemId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();

    final newBillDetails = _calculateBillDetails(updatedItems);

    state = current.copyWith(
      cartItems: updatedItems,
      billDetails: newBillDetails,
    );
  }

  /// Decrement quantity of a cart item
  void decrementQuantity(String cartItemId) {
    final current = state;
    final updatedItems = current.cartItems.map((item) {
      if (item.id == cartItemId && item.quantity > 1) {
        return item.copyWith(quantity: item.quantity - 1);
      }
      return item;
    }).toList();

    final newBillDetails = _calculateBillDetails(updatedItems);

    state = current.copyWith(
      cartItems: updatedItems,
      billDetails: newBillDetails,
    );
  }

  /// Remove item from cart
  void removeItem(String cartItemId) {
    final current = state;
    final updatedItems = current.cartItems
        .where((item) => item.id != cartItemId)
        .toList();

    final newBillDetails = _calculateBillDetails(updatedItems);

    state = current.copyWith(
      cartItems: updatedItems,
      billDetails: newBillDetails,
    );
  }

  /// Toggle delivery instruction
  void toggleDeliveryInstruction(DeliveryInstructionType type) {
    final current = state;
    final updatedInstructions = current.deliveryInstructions.map((instruction) {
      if (instruction.type == type) {
        return instruction.copyWith(enabled: !instruction.enabled);
      }
      return instruction;
    }).toList();

    state = current.copyWith(deliveryInstructions: updatedInstructions);
  }

  /// Add donation
  void addDonation(int amountCents) {
    state = state.copyWith(donationAmountCents: amountCents);
  }

  /// Remove donation
  void removeDonation() {
    state = state.copyWith(clearDonation: true);
  }

  /// Calculate bill details based on cart items
  BillDetails _calculateBillDetails(List<CartItem> items) {
    // Calculate items total
    final itemsTotalCents = items.fold<int>(
      0,
      (sum, item) => sum + item.totalPriceCents,
    );

    // Calculate savings
    final savedAmountCents = items.fold<int>(
      0,
      (sum, item) => sum + (item.totalSavingsCents ?? 0),
    );

    // Determine surge charge
    final int? surgeChargeCents =
        itemsTotalCents >= _surgeChargeWaiverThresholdCents
        ? null
        : _surgeChargeCents;

    return BillDetails(
      itemsTotalCents: itemsTotalCents,
      savedAmountCents: savedAmountCents,
      handlingChargeCents: _handlingChargeCents,
      surgeChargeCents: surgeChargeCents,
      deliveryFeeCents: 0,
    );
  }

  /// Get initial delivery instructions (all disabled)
  static List<DeliveryInstruction> _getInitialDeliveryInstructions() {
    return [
      const DeliveryInstruction(
        type: DeliveryInstructionType.pressHereAndHold,
        label: 'Press here\nand hold',
        enabled: false,
      ),
      const DeliveryInstruction(
        type: DeliveryInstructionType.avoidCalling,
        label: 'Avoid calling',
        enabled: false,
      ),
      const DeliveryInstruction(
        type: DeliveryInstructionType.dontRingBell,
        label: "Don't ring the\nbell",
        enabled: false,
      ),
    ];
  }
}
