import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../utils/server.dart';
import 'auth_controller.dart';

class PaymentController extends GetxController {
  final RxList<Map<String, dynamic>> paymentMethods =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  AuthController get _auth => Get.find<AuthController>();

  // ── Payment Methods ───────────────────────────────────────────────────────

  Future<void> fetchPaymentMethods() async {
    try {
      final res = await http.get(
        Uri.parse(paymentMethodsUrl),
        headers: _auth.authHeaders,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        paymentMethods.value = List<Map<String, dynamic>>.from(
          (data['methods'] as List)
              .map((e) => Map<String, dynamic>.from(e)),
        );
      }
    } catch (_) {}
  }

  Future<bool> addPaymentMethod({
    required String cardType,
    required String lastFour,
    required String holderName,
    required String expiry,
  }) async {
    isLoading.value = true;
    try {
      final res = await http.post(
        Uri.parse(paymentMethodsUrl),
        headers: _auth.authHeaders,
        body: jsonEncode({
          'card_type': cardType,
          'last_four': lastFour,
          'holder_name': holderName,
          'expiry': expiry,
        }),
      );
      if (res.statusCode == 201) {
        await fetchPaymentMethods();
        return true;
      } else {
        final err = jsonDecode(res.body);
        Get.snackbar('Error', err['detail'] ?? 'Could not add card');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deletePaymentMethod(int methodId) async {
    try {
      final res = await http.delete(
        Uri.parse(paymentMethodDeleteUrl(methodId)),
        headers: _auth.authHeaders,
      );
      if (res.statusCode == 200) {
        await fetchPaymentMethods();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setDefaultMethod(int methodId) async {
    try {
      final res = await http.put(
        Uri.parse(paymentMethodDefaultUrl(methodId)),
        headers: _auth.authHeaders,
      );
      if (res.statusCode == 200) {
        await fetchPaymentMethods();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── Payment (checkout) ────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> pay({
    required String sessionId,
    required int paymentMethodId,
  }) async {
    isLoading.value = true;
    try {
      final res = await http.post(
        Uri.parse(paymentPayUrl),
        headers: _auth.authHeaders,
        body: jsonEncode({
          'session_id': sessionId,
          'payment_method_id': paymentMethodId,
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return Map<String, dynamic>.from(data['order']);
      } else {
        final err = jsonDecode(res.body);
        Get.snackbar('Payment Failed', err['detail'] ?? 'Unknown error');
        return null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Order History ─────────────────────────────────────────────────────────

  Future<void> fetchOrders() async {
    try {
      final res = await http.get(
        Uri.parse(paymentOrdersUrl),
        headers: _auth.authHeaders,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        orders.value = List<Map<String, dynamic>>.from(
          (data['orders'] as List)
              .map((e) => Map<String, dynamic>.from(e)),
        );
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> fetchOrderDetail(String orderId) async {
    try {
      final res = await http.get(
        Uri.parse(paymentOrderDetailUrl(orderId)),
        headers: _auth.authHeaders,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return Map<String, dynamic>.from(data['order']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
