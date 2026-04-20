import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/server.dart';

class AuthController extends GetxController {
  final Rx<String?> token = Rx<String?>(null);
  final Rx<Map<String, dynamic>?> user = Rx<Map<String, dynamic>?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;

  bool get isLoggedIn => token.value != null;

  /// Restore session from persisted token + cached user. Called once before runApp.
  Future<void> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    final savedUser = prefs.getString('auth_user');

    if (savedToken != null) {
      token.value = savedToken;

      // Restore cached user data immediately (no network needed)
      if (savedUser != null) {
        try {
          user.value = Map<String, dynamic>.from(jsonDecode(savedUser));
        } catch (_) {}
      }

      // Then try to refresh from the server (non-blocking for the UI)
      await fetchUser();
    }
    isInitialized.value = true;
  }

  /// Persist user data locally so it's available on next cold start.
  Future<void> _cacheUser(Map<String, dynamic> userData) async {
    user.value = userData;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user', jsonEncode(userData));
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token.value!);
        await _cacheUser(Map<String, dynamic>.from(data['user']));
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token.value!);
        await _cacheUser(Map<String, dynamic>.from(data['user']));
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
        await _cacheUser(Map<String, dynamic>.from(jsonDecode(res.body)));
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        // Token expired or revoked – force logout
        await logout();
      }
      // Other errors (500, etc.) – keep token + cached user data
    } catch (_) {
      // Network issue – keep token + cached user data
    }
  }

  /// Logout – clear token, user data, and all cached data.
  Future<void> logout() async {
    token.value = null;
    user.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
  }

  /// Update user profile (name and/or email).
  Future<bool> updateProfile({String? name, String? email}) async {
    isLoading.value = true;
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;

      final res = await http.put(
        Uri.parse(updateProfileUrl),
        headers: authHeaders,
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        await _cacheUser(Map<String, dynamic>.from(jsonDecode(res.body)));
        Get.snackbar('Success', 'Profile updated',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(12));
        return true;
      } else {
        final err = jsonDecode(res.body);
        Get.snackbar('Error', err['detail'] ?? 'Could not update profile');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Change password (requires current password for verification).
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    isLoading.value = true;
    try {
      final res = await http.put(
        Uri.parse(changePasswordUrl),
        headers: authHeaders,
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );
      if (res.statusCode == 200) {
        Get.snackbar('Success', 'Password changed',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(12));
        return true;
      } else {
        final err = jsonDecode(res.body);
        Get.snackbar('Error', err['detail'] ?? 'Could not change password');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
