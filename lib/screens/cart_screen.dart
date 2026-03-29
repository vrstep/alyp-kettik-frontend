import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/session_controller.dart';
import 'thankyou.dart';

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

        // Bottom total + checkout
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
                          : () => _endShopping(session),
                      icon: session.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle_outline_rounded),
                      label: Text(
                        session.isLoading.value
                            ? 'Processing...'
                            : 'End Shopping',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
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

  void _endShopping(SessionController session) {
    Get.defaultDialog(
      title: 'End Shopping?',
      radius: 16,
      middleText:
          'Your payment will be processed automatically.\nYou can walk out of the store.',
      textCancel: 'Cancel',
      textConfirm: 'Yes, End',
      onConfirm: () async {
        Get.back(); // close dialog
        await session.completeSession();
        Get.to(() => const ThankyouPage());
      },
      confirmTextColor: Colors.white,
      buttonColor: Colors.green.shade600,
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
    final productId = item['product_id'] as int? ?? 0;

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
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Icon(Icons.shopping_bag_outlined, color: Colors.blue.shade600),
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
                        session.removeFromCart(productId);
                      } else {
                        session.updateCartItemQty(productId, qty - 1);
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
                        session.updateCartItemQty(productId, qty + 1),
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
