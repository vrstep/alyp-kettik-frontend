import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../utils/server.dart';
import 'auth_controller.dart';

class ProductController extends GetxController {
  final RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredProducts =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxList<String> categories = <String>[].obs;

  AuthController get _auth => Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  /// Fetch all products from the backend.
  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final res = await http.get(
        Uri.parse(productsUrl),
        headers: _auth.authHeaders,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> items = data is List ? data : (data['products'] ?? []);
        products.value = items
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        // Extract unique categories
        final cats = <String>{};
        for (final p in products) {
          final cat = p['category'] as String?;
          if (cat != null && cat.isNotEmpty) {
            cats.add(cat);
          }
        }
        categories.value = cats.toList()..sort();

        _applyFilters();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Set search query and re-filter.
  void search(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  /// Set category filter and re-filter.
  void filterByCategory(String category) {
    if (selectedCategory.value == category) {
      selectedCategory.value = '';
    } else {
      selectedCategory.value = category;
    }
    _applyFilters();
  }

  void _applyFilters() {
    var result = List<Map<String, dynamic>>.from(products);

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((p) {
        final name = (p['name'] as String? ?? '').toLowerCase();
        final desc = (p['description'] as String? ?? '').toLowerCase();
        return name.contains(q) || desc.contains(q);
      }).toList();
    }

    if (selectedCategory.value.isNotEmpty) {
      result = result
          .where((p) => p['category'] == selectedCategory.value)
          .toList();
    }

    filteredProducts.value = result;
  }
}
