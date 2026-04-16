import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/session_controller.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final session = Get.find<SessionController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // User avatar + info
              Obx(() {
                final user = auth.user.value;
                final name = user?['name'] as String? ?? 'User';
                final email = user?['email'] as String? ?? '';
                final initials = name.isNotEmpty
                    ? name
                        .split(' ')
                        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                        .take(2)
                        .join()
                    : 'U';

                return Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.purple.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 32),

              // Settings sections
              _buildSection(
                title: 'Account',
                items: [
                  _SettingsItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profile',
                    subtitle: 'Name, email, password',
                    onTap: () => Get.snackbar(
                      'Coming Soon',
                      'Profile editing will be available soon',
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(12),
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.credit_card_rounded,
                    title: 'Payment Methods',
                    subtitle: 'Manage your cards',
                    onTap: () => Get.snackbar(
                      'Coming Soon',
                      'Payment management will be available soon',
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),

              _buildSection(
                title: 'History',
                items: [
                  _SettingsItem(
                    icon: Icons.receipt_long_rounded,
                    title: 'Order History',
                    subtitle: 'View past purchases & receipts',
                    onTap: () => Get.snackbar(
                      'Coming Soon',
                      'Order history will be available soon',
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(12),
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.replay_rounded,
                    title: 'Refunds',
                    subtitle: 'Request and track refunds',
                    onTap: () => Get.snackbar(
                      'Coming Soon',
                      'Refund management will be available soon',
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),

              _buildSection(
                title: 'Other',
                items: [
                  _SettingsItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'FAQ, contact us',
                    onTap: () => Get.snackbar(
                      'Coming Soon',
                      'Support will be available soon',
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(12),
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    subtitle: 'App version, terms of service',
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'Alyp-Kettik',
                      applicationVersion: '1.0.0',
                      children: [
                        const Text(
                            'Computer Vision Cashierless Checkout App.'),
                      ],
                    ),
                  ),
                ],
              ),

              // Logout button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await auth.logout();
                      await session.clearSession();
                      Get.offAll(() => const LoginScreen());
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
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
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
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
            child: Column(
              children: items
                  .asMap()
                  .entries
                  .map((entry) {
                    final item = entry.value;
                    final isLast = entry.key == items.length - 1;
                    return Column(
                      children: [
                        ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.icon,
                                color: Colors.blue.shade600, size: 22),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right_rounded,
                              color: Colors.grey.shade400),
                          onTap: item.onTap,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            indent: 68,
                            color: Colors.grey.shade200,
                          ),
                      ],
                    );
                  })
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
