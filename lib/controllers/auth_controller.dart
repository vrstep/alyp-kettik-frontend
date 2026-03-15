import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/server.dart';

class AuthController extends GetxController {
  final Rx<String?> token = Rx<String?>(null);
  final Rx<Map<String, dynamic>?> user = Rx<Map<String, dynamic>?>(null);
  final RxBool isLoading = false.obs;

  bool get isLoggedIn => token.value != null;

  @override
  void onInit() {
    super.onInit();
    _loadToken();
  }

  /// Load saved token from SharedPreferences on app start.
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('auth_token');
    if (saved != null) {
      token.value = saved;
      await fetchUser();
    }
  }

  /// Common Authorization header.
  Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        if (token.value != null) 'Authorization': 'Bearer ${token.value}',
      };

  /// Register a new user (email + password).
  Future<bool> register(String email, String name, String password) async {
    isLoading.value = true;
    try {
      final res = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'name': name,
          'password': password,
        }),
      );
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        token.value = data['access_token'];
        user.value = Map<String, dynamic>.from(data['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token.value!);
        return true;
      } else {
        final err = jsonDecode(res.body);
        Get.snackbar('Registration failed', err['detail'] ?? 'Unknown error');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Login with email + password.
  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    try {
      final res = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        token.value = data['access_token'];
        user.value = Map<String, dynamic>.from(data['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token.value!);
        return true;
      } else {
        final err = jsonDecode(res.body);
        Get.snackbar('Login failed', err['detail'] ?? 'Invalid credentials');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch current user profile.
  Future<void> fetchUser() async {
    try {
      final res = await http.get(Uri.parse(meUrl), headers: authHeaders);
      if (res.statusCode == 200) {
        user.value = jsonDecode(res.body);
      } else {
        // Token invalid – force logout
        await logout();
      }
    } catch (_) {
      // Network issue – keep token, user can retry
    }
  }

  /// Logout – clear token and user data.
  Future<void> logout() async {
    token.value = null;
    user.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
