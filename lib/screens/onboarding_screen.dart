import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildPanel1(),
                  _buildImagePanel('assets/images/panel2.jpg', 'Use your app to enter the store, swipe to continue', true),
                  _buildImagePanel('assets/images/panel3.png', 'Scan what you want to buy using our AI-powered scanner. Our model identifies your items instantly.', false),
                  _buildImagePanel('assets/images/panel4.png', 'Want to add more or remove an item? Use the shopping cart to adjust quantities at any time.', false),
                  _buildImagePanel('assets/images/panel5.png', 'When you’re done, just press Pay Now and you’re good to go. No lines, no checkout counters, just Alyp kettik!', false),
                  _buildImagePanel('assets/images/panel6.png', 'We’ll notify you once your card is charged. You can view your full receipt anytime in the app\'s dedicated menu.', false),
                  _buildFinalPanel(),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel1() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to Alyp Kettik, we can\'t wait for you to use our services',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.3),
          ),
          const SizedBox(height: 32),
          const Text(
            'First a quick introduction',
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 64),
          InkWell(
            onTap: () {
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 48),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImagePanel(String imagePath, String text, bool isGreyText) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Expanded(
            flex: 4,
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 32),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: isGreyText ? Colors.grey.shade600 : Colors.black87,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFinalPanel() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Expanded(
            flex: 4,
            child: Image.asset('assets/images/finalpanel.png', fit: BoxFit.contain),
          ),
          const SizedBox(height: 32),
          const Text(
            'Seriously alyp kete ber!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Get.offAll(() => const MainShell());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: Colors.orange.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Got it! Let\'s shop.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (index) => _buildDot(index)),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.orange : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
