import 'package:daily_bazaar_frontend/shared_feature/models/address_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/checkout_models.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/product_model.dart';
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
    return CheckoutState(
      cartItems: _getMockCartItems(),
      deliveryInstructions: _getInitialDeliveryInstructions(),
      deliveryAddress: _getMockAddress(),
      billDetails: _calculateBillDetails(_getMockCartItems()),
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
    final updatedItems =
        current.cartItems.where((item) => item.id != cartItemId).toList();

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

  /// Get mock cart items matching the screenshot
  static List<CartItem> _getMockCartItems() {
    return [
      CartItem(
        id: 'cart-1',
        product: Product(
          id: 'prod-1',
          name: 'Kissan Tomato Ketchup',
          priceCents: 9300,
          mrpCents: 9300,
          stock: 100,
          active: true,
          weight: '850 g',
        ),
        quantity: 1,
        priceCentsSnapshot: 9300,
        mrpCentsSnapshot: 9300,
      ),
      CartItem(
        id: 'cart-2',
        product: Product(
          id: 'prod-2',
          name: 'Dr. Oetker FunFoods Veg Mayonnaise Original',
          priceCents: 4600,
          mrpCents: 4600,
          stock: 100,
          active: true,
          weight: '100 g',
        ),
        quantity: 1,
        priceCentsSnapshot: 4600,
        mrpCentsSnapshot: 4600,
      ),
      CartItem(
        id: 'cart-3',
        product: Product(
          id: 'prod-3',
          name: 'Harvest Gold White Bread',
          priceCents: 6000,
          mrpCents: 6000,
          stock: 100,
          active: true,
          weight: '700 g',
        ),
        quantity: 1,
        priceCentsSnapshot: 6000,
        mrpCentsSnapshot: 6000,
      ),
      CartItem(
        id: 'cart-4',
        product: Product(
          id: 'prod-4',
          name: 'Kissan Mixed Fruit Jam (200 g)',
          priceCents: 8000,
          mrpCents: 8000,
          stock: 100,
          active: true,
          weight: '200 g',
        ),
        quantity: 1,
        priceCentsSnapshot: 8000,
        mrpCentsSnapshot: 8000,
      ),
      CartItem(
        id: 'cart-5',
        product: Product(
          id: 'prod-5',
          name: "Ching's Secret Green Chilli Sauce",
          priceCents: 5000,
          mrpCents: 5600,
          stock: 100,
          active: true,
          weight: '190 g',
        ),
        quantity: 1,
        priceCentsSnapshot: 5000,
        mrpCentsSnapshot: 5600,
      ),
      CartItem(
        id: 'cart-6',
        product: Product(
          id: 'prod-6',
          name: 'Amul Salted Butter',
          priceCents: 5800,
          mrpCents: 5800,
          stock: 100,
          active: true,
          weight: '100 g',
        ),
        quantity: 1,
        priceCentsSnapshot: 5800,
        mrpCentsSnapshot: 5800,
      ),
      CartItem(
        id: 'cart-7',
        product: Product(
          id: 'prod-7',
          name: 'Rajdhani Besan',
          priceCents: 5900,
          mrpCents: 8100,
          stock: 100,
          active: true,
          weight: '500 g',
        ),
        quantity: 1,
        priceCentsSnapshot: 5900,
        mrpCentsSnapshot: 8100,
      ),
    ];
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

  /// Get mock delivery address
  static UserAddress _getMockAddress() {
    return const UserAddress(
      id: 'addr-1',
      userId: 'user-1',
      label: 'Home',
      fullName: 'Naman Jain',
      phone: '+919876543210',
      addressLine1: 'Vaishnav pg Milan boys hostel',
      city: 'The gra...',
      state: 'Maharashtra',
      pincode: '400001',
      isDefault: true,
    );
  }
}
