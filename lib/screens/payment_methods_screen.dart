import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/payment_controller.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final payment = Get.find<PaymentController>();

  @override
  void initState() {
    super.initState();
    payment.fetchPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Payment Methods'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        if (payment.paymentMethods.isEmpty) {
          return _buildEmpty();
        }
        return _buildList();
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCardSheet(context),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Card', style: TextStyle(fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.credit_card_off_rounded,
                  size: 48, color: Colors.blue.shade300),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Cards Yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a payment card to start\nmaking purchases',
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

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: payment.paymentMethods.length,
      itemBuilder: (_, i) {
        final card = payment.paymentMethods[i];
        return _CreditCardWidget(
          card: card,
          onSetDefault: () => payment.setDefaultMethod(card['id'] as int),
          onDelete: () => _confirmDelete(card),
        );
      },
    );
  }

  void _confirmDelete(Map<String, dynamic> card) {
    Get.defaultDialog(
      title: 'Remove Card?',
      radius: 16,
      middleText:
          'Remove card ending in ${card['last_four']}?',
      textCancel: 'Cancel',
      textConfirm: 'Remove',
      onConfirm: () {
        Get.back();
        payment.deletePaymentMethod(card['id'] as int);
      },
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade500,
    );
  }

  void _showAddCardSheet(BuildContext context) {
    final numberController = TextEditingController();
    final nameController = TextEditingController();
    final expiryController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add New Card',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: numberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '•••• •••• •••• 4242',
                  prefixIcon: const Icon(Icons.credit_card_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                validator: (v) {
                  if (v == null || v.length < 4) return 'Enter at least 4 digits';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Cardholder Name',
                  hintText: 'JOHN DOE',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter cardholder name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: expiryController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  prefixIcon: const Icon(Icons.calendar_month_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d/]')),
                  LengthLimitingTextInputFormatter(5),
                ],
                validator: (v) {
                  if (v == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) {
                    return 'Enter MM/YY format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Obx(() => ElevatedButton.icon(
                      onPressed: payment.isLoading.value
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              final number = numberController.text;
                              final lastFour = number.substring(number.length - 4);
                              final cardType =
                                  number.startsWith('4') ? 'visa' : 'mastercard';
                              final ok = await payment.addPaymentMethod(
                                cardType: cardType,
                                lastFour: lastFour,
                                holderName: nameController.text.trim(),
                                expiry: expiryController.text.trim(),
                              );
                              if (ok) {
                                if (ctx.mounted) Navigator.pop(ctx);
                                Get.snackbar('Success', 'Card added',
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: const EdgeInsets.all(12));
                              }
                            },
                      icon: payment.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.add_rounded),
                      label: Text(
                        payment.isLoading.value ? 'Adding...' : 'Add Card',
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
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditCardWidget extends StatelessWidget {
  final Map<String, dynamic> card;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _CreditCardWidget({
    required this.card,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cardType = card['card_type'] as String? ?? 'visa';
    final lastFour = card['last_four'] as String? ?? '••••';
    final holderName = card['holder_name'] as String? ?? '';
    final expiry = card['expiry'] as String? ?? '';
    final isDefault = card['is_default'] == true;

    final isVisa = cardType.toLowerCase() == 'visa';
    final gradientColors = isVisa
        ? [const Color(0xFF1A237E), const Color(0xFF3949AB)]
        : [const Color(0xFFE65100), const Color(0xFFFF6D00)];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Card visual
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: chip + type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chip icon
                    Container(
                      width: 45,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.memory_rounded,
                          color: Colors.white70, size: 20),
                    ),
                    Row(
                      children: [
                        if (isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'DEFAULT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          isVisa ? 'VISA' : 'MC',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Card number
                Text(
                  '•••• •••• •••• $lastFour',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3,
                  ),
                ),
                // Bottom row: holder + expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARD HOLDER',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          holderName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'EXPIRES',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          expiry,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isDefault)
                  TextButton.icon(
                    onPressed: onSetDefault,
                    icon: Icon(Icons.star_outline_rounded,
                        size: 18, color: Colors.blue.shade600),
                    label: Text('Set Default',
                        style: TextStyle(color: Colors.blue.shade600)),
                  ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 18, color: Colors.red.shade400),
                  label: Text('Remove',
                      style: TextStyle(color: Colors.red.shade400)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
