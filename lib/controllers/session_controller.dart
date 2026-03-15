import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../utils/server.dart';
import 'auth_controller.dart';

class SessionController extends GetxController {
  final Rx<Map<String, dynamic>?> activeSession =
      Rx<Map<String, dynamic>?>(null);
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  final RxDouble cartTotal = 0.0.obs;
  final RxBool isLoading = false.obs;

  AuthController get _auth => Get.find<AuthController>();

  String? get sessionId => activeSession.value?['id'];

  bool get hasActiveSession => activeSession.value != null;

  /// Scan QR and enter the store.
  Future<bool> enterStore(String qrPayload) async {
    isLoading.value = true;
    try {
      final res = await http.post(
        Uri.parse(sessionEnterUrl),
        headers: _auth.authHeaders,
        body: jsonEncode({'qr_payload': qrPayload}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        activeSession.value =
            Map<String, dynamic>.from(data['session']);
        await fetchCart();
        return true;
      } else if (res.statusCode == 409) {
        // Already has an active session – load it
        await fetchActiveSession();
        return true;
      } else {
        final err = jsonDecode(res.body);
        Get.snackbar('Error', err['detail'] ?? 'Could not enter store');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch the current active session from backend.
  Future<void> fetchActiveSession() async {
    try {
      final res = await http.get(
        Uri.parse(sessionActiveUrl),
        headers: _auth.authHeaders,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        activeSession.value =
            Map<String, dynamic>.from(data['session']);
        cartItems.value = List<Map<String, dynamic>>.from(
          (data['cart_items'] as List).map((e) => Map<String, dynamic>.from(e)),
        );
        cartTotal.value = (data['total'] as num).toDouble();
      } else {
        activeSession.value = null;
        cartItems.clear();
        cartTotal.value = 0;
      }
    } catch (_) {}
  }

  /// Fetch cart items for the active session.
  Future<void> fetchCart() async {
    if (sessionId == null) return;
    try {
      final res = await http.get(
        Uri.parse(sessionCartUrl(sessionId!)),
        headers: _auth.authHeaders,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        cartItems.value = List<Map<String, dynamic>>.from(
          (data['cart_items'] as List).map((e) => Map<String, dynamic>.from(e)),
        );
        cartTotal.value = (data['total'] as num).toDouble();
      }
    } catch (_) {}
  }

  /// Add an item to the session cart.
  Future<void> addToCart(int productId, {int quantity = 1}) async {
    if (sessionId == null) return;
    try {
      await http.post(
        Uri.parse(sessionCartUrl(sessionId!)),
        headers: _auth.authHeaders,
        body: jsonEncode({'product_id': productId, 'quantity': quantity}),
      );
      await fetchCart();
    } catch (_) {}
  }

  /// Remove an item from the session cart.
  Future<void> removeFromCart(int productId) async {
    if (sessionId == null) return;
    try {
      await http.delete(
        Uri.parse('${sessionCartUrl(sessionId!)}/$productId'),
        headers: _auth.authHeaders,
      );
      await fetchCart();
    } catch (_) {}
  }

  /// Update quantity of a cart item.
  Future<void> updateCartItemQty(int productId, int quantity) async {
    if (sessionId == null) return;
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }
    try {
      await http.put(
        Uri.parse('${sessionCartUrl(sessionId!)}/$productId'),
        headers: _auth.authHeaders,
        body: jsonEncode({'quantity': quantity}),
      );
      await fetchCart();
    } catch (_) {}
  }

  /// Complete the shopping session.
  Future<void> completeSession() async {
    isLoading.value = true;
    try {
      final res = await http.post(
        Uri.parse(sessionCompleteUrl),
        headers: _auth.authHeaders,
      );
      if (res.statusCode == 200) {
        activeSession.value = null;
        cartItems.clear();
        cartTotal.value = 0;
        Get.snackbar('Done', 'Shopping session completed!');
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear local session state (e.g. on logout).
  void clearSession() {
    activeSession.value = null;
    cartItems.clear();
    cartTotal.value = 0;
  }
}
