import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../controllers/session_controller.dart';
import '../controllers/auth_controller.dart';
import 'home.dart';
import 'login_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerCtrl = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerCtrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasScanned) return; // Prevent duplicate scans
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _hasScanned = true);
    _scannerCtrl.stop();

    final session = Get.find<SessionController>();
    final ok = await session.enterStore(barcode.rawValue!);

    if (ok) {
      Get.offAll(() => const HomePage());
    } else {
      // Let user scan again
      setState(() => _hasScanned = false);
      _scannerCtrl.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final session = Get.find<SessionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Store QR Code'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              session.clearSession();
              Get.offAll(() => const LoginScreen());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Scanner area
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24)),
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _scannerCtrl,
                    onDetect: _onDetect,
                  ),
                  // Overlay scan frame
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.blueAccent, width: 3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  // Loading overlay
                  Obx(() => session.isLoading.value
                      ? Container(
                          color: Colors.black45,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                    color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  'Entering store...',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            ),
          ),

          // Instructions
          Expanded(
            flex: 1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_scanner_rounded,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'Point your camera at the QR code\nat the store entrance',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
