import '../../core/utils/responsive.dart';
import 'package:daily_bazaar_frontend/shared_feature/api/order_api.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/config.dart';
import 'package:daily_bazaar_frontend/shared_feature/helper/api_exception.dart';
import 'package:daily_bazaar_frontend/shared_feature/provider/checkout_provider.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/checkout/bill_details_section.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/checkout/bottom_payment_bar.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/checkout/cart_items_section.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/checkout/delivery_address_section.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/checkout/delivery_eta_section.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/checkout/delivery_instructions_section.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/checkout/donation_section.dart';
import 'package:daily_bazaar_frontend/screens/payment/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/hive.dart';

/// Unified checkout screen
class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutControllerProvider);
    final controller = ref.read(checkoutControllerProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Checkout'),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: cs.primary),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildMobileLayout(context, checkoutState, controller),
        tablet: _buildDesktopLayout(context, checkoutState, controller),
        desktop: _buildDesktopLayout(context, checkoutState, controller),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    CheckoutState checkoutState,
    CheckoutController controller,
  ) {
    return Stack(
      children: [
        // Scrollable content
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery ETA Section
              DeliveryETASection(
                deliveryMinutes: checkoutState.deliveryMinutes,
                itemCount: checkoutState.totalItems,
              ),

              // Cart Items Section
              CartItemsSection(
                cartItems: checkoutState.cartItems,
                onIncrementQuantity: controller.incrementQuantity,
                onDecrementQuantity: controller.decrementQuantity,
              ),

              const SizedBox(height: 8),

              // Bill Details Section
              // Bill Details Section
              BillDetailsSection(billDetails: checkoutState.billDetails),

              const SizedBox(height: 8),

              // Delivery Instructions Section
              DeliveryInstructionsSection(
                instructions: checkoutState.deliveryInstructions,
                onToggle: controller.toggleDeliveryInstruction,
              ),

              const SizedBox(height: 8),

              // Donation Section
              DonationSection(
                title: 'Donate to Feeding India ❤️',
                description:
                    'Your continued support will help us serve daily meals to children',
                donationAmount: checkoutState.donationAmountCents,
                defaultAmount: 500, // ₹5
                onAddDonation: () => controller.addDonation(500),
                onRemoveDonation: controller.removeDonation,
              ),

              const SizedBox(height: 8),

              // Delivery Address Section
              if (checkoutState.deliveryAddress != null)
                DeliveryAddressSection(
                  address: checkoutState.deliveryAddress!,
                  onChangeAddress: () {
                    // TODO: Navigate to address selection
                  },
                ),

              // Bottom padding to account for payment bar
              const SizedBox(height: 120),
            ],
          ),
        ),

        // Pinned Bottom Payment Bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: BottomPaymentBar(
            totalAmount: checkoutState.formattedGrandTotalWithDonation,
            paymentMethod: 'BHIM UPI',
            onPlaceOrder: () => _placeOrder(context, checkoutState),
          ),
        ),
      ],
    );
  }

  Future<void> _placeOrder(BuildContext context, CheckoutState checkoutState) async {
    try {
      // Get auth token using TokenStorage (typed Box<String>)
      final token = TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to place an order')),
        );
        return;
      }

      if (checkoutState.deliveryAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a delivery address')),
        );
        return;
      }

      if (checkoutState.cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your cart is empty')),
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final client = ApiClient(baseUrl: AppEnvironment.apiBaseUrl);
      final orderApi = OrderApi(client);

      final addr = checkoutState.deliveryAddress!;
      final orderResp = await orderApi.createOrder(
        shippingAddress: {
          'full_name': addr.fullName,
          'phone': addr.phone,
          'address_line1': addr.addressLine1,
          'address_line2': addr.addressLine2,
          'city': addr.city,
          'state': addr.state,
          'pincode': addr.pincode,
        },
        items: checkoutState.cartItems
            .map((item) => {
                  'product_id': item.product.id,
                  'quantity': item.quantity,
                })
            .toList(),
        authToken: token,
      );

      final orderId = orderResp['id'] as String? ?? '';

      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      // Navigate to payment screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            orderId: orderId,
            customerName: addr.fullName,
            customerEmail: '', // email not stored in Hive currently
            authToken: token,
            amountDisplay: checkoutState.formattedGrandTotalWithDonation,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    }
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    CheckoutState checkoutState,
    CheckoutController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Cart Items & ETA
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DeliveryETASection(
                  deliveryMinutes: checkoutState.deliveryMinutes,
                  itemCount: checkoutState.totalItems,
                ),
                const SizedBox(height: 16),
                CartItemsSection(
                  cartItems: checkoutState.cartItems,
                  onIncrementQuantity: controller.incrementQuantity,
                  onDecrementQuantity: controller.decrementQuantity,
                ),
              ],
            ),
          ),
        ),
        // Right Column: Bill, Instructions, Donation, Payment
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        BillDetailsSection(
                          billDetails: checkoutState.billDetails,
                        ),
                        const SizedBox(height: 16),
                        DeliveryInstructionsSection(
                          instructions: checkoutState.deliveryInstructions,
                          onToggle: controller.toggleDeliveryInstruction,
                        ),
                        const SizedBox(height: 16),
                        DonationSection(
                          title: 'Donate to Feeding India ❤️',
                          description:
                              'Your continued support will help us serve daily meals to children',
                          donationAmount: checkoutState.donationAmountCents,
                          defaultAmount: 500, // ₹5
                          onAddDonation: () => controller.addDonation(500),
                          onRemoveDonation: controller.removeDonation,
                        ),
                        const SizedBox(height: 16),
                        if (checkoutState.deliveryAddress != null)
                          DeliveryAddressSection(
                            address: checkoutState.deliveryAddress!,
                            onChangeAddress: () {},
                          ),
                      ],
                    ),
                  ),
                ),
                // Payment Bar at bottom of Right Column
                BottomPaymentBar(
                  totalAmount: checkoutState.formattedGrandTotalWithDonation,
                  paymentMethod: 'BHIM UPI',
                  onPlaceOrder: () => _placeOrder(context, checkoutState),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
