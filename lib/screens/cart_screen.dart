import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/session_controller.dart';
import '../controllers/payment_controller.dart';
import 'payment_methods_screen.dart';
import 'thankyou.dart';
import '../utils/product_images.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (!session.hasActiveSession) {
            return _buildNoSession();
          }
          if (session.cartItems.isEmpty) {
            return _buildEmptyCart();
          }
          return _buildCartView(session);
        }),
      ),
    );
  }

  Widget _buildNoSession() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No Active Session',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan a store QR code first to start shopping',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    final session = Get.find<SessionController>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan items with the camera to\nadd them to your cart',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _endShopping(session),
                icon: Icon(Icons.exit_to_app_rounded, color: Colors.red.shade400),
                label: Text(
                  'End Shopping',
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade200, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartView(SessionController session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shopping Cart',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Obx(() => Text(
                    '${session.cartItems.length} item(s)',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Cart items list
        Expanded(
          child: Obx(() => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: session.cartItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final item = session.cartItems[i];
                  return _CartItemCard(item: item, session: session);
                },
              )),
        ),

        // Bottom total + pay now
        Obx(() => Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${session.cartTotal.value.toStringAsFixed(0)} ₸',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: session.isLoading.value
                          ? null
                          : () => _showPaymentSheet(session),
                      icon: session.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.payment_rounded),
                      label: Text(
                        session.isLoading.value
                            ? 'Processing...'
                            : 'Pay Now',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  void _showPaymentSheet(SessionController session) {
    final paymentCtrl = Get.find<PaymentController>();
    paymentCtrl.fetchPaymentMethods();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
                  'Total: ${session.cartTotal.value.toStringAsFixed(0)} ₸',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                )),
            const SizedBox(height: 20),
            Obx(() {
              if (paymentCtrl.paymentMethods.isEmpty) {
                return _buildNoCards();
              }
              return _buildCardList(paymentCtrl, session);
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildNoCards() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.credit_card_off_rounded,
              size: 40, color: Colors.orange.shade300),
        ),
        const SizedBox(height: 16),
        Text(
          'No payment methods',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add a card to make a payment',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              Get.back();
              Get.to(() => const PaymentMethodsScreen());
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Payment Method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCardList(PaymentController paymentCtrl, SessionController session) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: paymentCtrl.paymentMethods.length,
            itemBuilder: (_, i) {
              final card = paymentCtrl.paymentMethods[i];
              final cardType = card['card_type'] as String? ?? 'visa';
              final lastFour = card['last_four'] as String? ?? '••••';
              final isDefault = card['is_default'] == true;
              final isVisa = cardType.toLowerCase() == 'visa';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isDefault ? Colors.blue.shade50 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => _confirmPayment(
                      session: session,
                      paymentCtrl: paymentCtrl,
                      card: card,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isVisa
                                    ? [const Color(0xFF1A237E), const Color(0xFF3949AB)]
                                    : [const Color(0xFFE65100), const Color(0xFFFF6D00)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                isVisa ? 'VISA' : 'MC',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '•••• •••• •••• $lastFour',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    letterSpacing: 1,
                                  ),
                                ),
                                if (isDefault)
                                  Text(
                                    'Default',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            Get.back();
            Get.to(() => const PaymentMethodsScreen());
          },
          icon: Icon(Icons.add_rounded, color: Colors.blue.shade600),
          label: Text('Add New Card',
              style: TextStyle(color: Colors.blue.shade600)),
        ),
      ],
    );
  }

  void _confirmPayment({
    required SessionController session,
    required PaymentController paymentCtrl,
    required Map<String, dynamic> card,
  }) {
    final lastFour = card['last_four'] as String? ?? '••••';
    final cardType = (card['card_type'] as String? ?? 'visa').toUpperCase();

    Get.back(); // Close payment sheet

    Get.defaultDialog(
      title: 'Confirm Payment',
      radius: 16,
      middleText:
          'Pay ${session.cartTotal.value.toStringAsFixed(0)} ₸\nwith $cardType ••••$lastFour?',
      textCancel: 'Cancel',
      textConfirm: 'Pay Now',
      onConfirm: () async {
        Get.back(); // Close dialog

        session.isLoading.value = true;
        final result = await paymentCtrl.pay(
          sessionId: session.sessionId!,
          paymentMethodId: card['id'] as int,
        );
        session.isLoading.value = false;

        if (result != null) {
          // Clear local session state
          session.activeSession.value = null;
          session.cartItems.clear();
          session.cartTotal.value = 0;
          await session.clearSession();

          Get.to(() => const ThankyouPage());
        }
      },
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue.shade600,
    );
  }

  void _endShopping(SessionController session) {
    Get.defaultDialog(
      title: 'End Shopping?',
      radius: 16,
      middleText:
          'You have no items in your cart.\nEnd this shopping session?',
      textCancel: 'Cancel',
      textConfirm: 'Yes, End',
      onConfirm: () async {
        Get.back(); // close dialog
        await session.completeSession();
        Get.to(() => const ThankyouPage());
      },
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade500,
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final SessionController session;

  const _CartItemCard({required this.item, required this.session});

  @override
  Widget build(BuildContext context) {
    final name = item['name'] as String? ?? 'Unknown';
    final _priceRaw = item['price'];
    final price = _priceRaw is num
        ? _priceRaw.toDouble()
        : double.tryParse(_priceRaw?.toString() ?? '0') ?? 0.0;
    final qty = item['quantity'] as int? ?? 1;
    final cartItemId = item['id'] as int? ?? 0;  // cart item PK for update/delete
    final localAsset = getProductImageAsset(name);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: localAsset != null ? Colors.white : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: localAsset != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset(localAsset, fit: BoxFit.contain),
                    ),
                  )
                : Icon(Icons.shopping_bag_outlined, color: Colors.blue.shade600),
          ),
          const SizedBox(width: 14),
          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '${price.toStringAsFixed(0)} ₸ each',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          // Quantity controls
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(price * qty).toStringAsFixed(0)} ₸',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQtyButton(
                    icon: qty <= 1
                        ? Icons.delete_outline_rounded
                        : Icons.remove_rounded,
                    color:
                        qty <= 1 ? Colors.red.shade400 : Colors.grey.shade600,
                    onTap: () {
                      if (qty <= 1) {
                        session.removeFromCart(cartItemId);
                      } else {
                        session.updateCartItemQty(cartItemId, qty - 1);
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '$qty',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                  _buildQtyButton(
                    icon: Icons.add_rounded,
                    color: Colors.blue.shade600,
                    onTap: () =>
                        session.updateCartItemQty(cartItemId, qty + 1),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
