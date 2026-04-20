import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'onboarding_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.slideshow_rounded, color: Colors.blueAccent),
            title: const Text('Replay Onboarding Tour'),
            subtitle: const Text('Learn how to use the app'),
            trailing: const Icon(Icons.chevron_right_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.grey.shade50,
            onTap: () {
              Get.to(() => const OnboardingScreen());
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.question_answer_rounded, color: Colors.blueAccent),
            title: const Text('FAQ'),
            subtitle: const Text('Frequently Asked Questions'),
            trailing: const Icon(Icons.chevron_right_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.grey.shade50,
            onTap: () {
              Get.snackbar(
                'Coming Soon',
                'FAQ will be available soon',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(12),
              );
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.contact_support_rounded, color: Colors.blueAccent),
            title: const Text('Contact Us'),
            subtitle: const Text('Get in touch with support'),
            trailing: const Icon(Icons.chevron_right_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.grey.shade50,
            onTap: () {
              Get.snackbar(
                'Coming Soon',
                'Contact options will be available soon',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(12),
              );
            },
          ),
        ],
      ),
    );
  }
}
