import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../controllers/dto.dart';
import '../controllers/session_controller.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool isLoading = false;
  bool hasResult = false;
  final DataBaseOperations _dbOps = Get.find();
  final SessionController _session = Get.find();
  final ImagePicker _picker = ImagePicker();
  http.Client? _httpClient;
  List<Map<String, dynamic>> _recognizedItems = [];
  num _total = 0;

  Future<void> _pickFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      await _processImage(pickedFile);
    }
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _processImage(pickedFile);
    }
  }

  Future<void> _processImage(XFile image) async {
    _httpClient = http.Client();
    setState(() {
      isLoading = true;
      hasResult = false;
    });
    try {
      final ext = image.path.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
      final bytes = await image.readAsBytes();

      final record = await _dbOps.uploadPhoto(
        bytes,
        _httpClient!,
        mime: mime,
      );
      if (record == null) return;

      if (record["recognized_items"] == null) {
        Get.snackbar("Error", "Unexpected response: $record");
        return;
      }

      final items = (record["recognized_items"] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final total = record["total"] as num;

      setState(() {
        hasResult = true;
        _recognizedItems = items;
        _total = total;
      });

      // Auto-add recognized items to session cart
      for (final item in items) {
        final productId = item['product_id'] as int?;
        final qty = item['quantity'] as int? ?? 1;
        if (productId != null) {
          await _session.addToCart(productId, quantity: qty);
        }
      }

      Get.snackbar(
        'Items Added',
        '${items.length} item(s) added to your cart',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
      );
    } finally {
      _httpClient?.close();
      _httpClient = null;
      setState(() => isLoading = false);
    }
  }

  void _cancelRecognition() {
    _httpClient?.close();
    _httpClient = null;
    setState(() {
      isLoading = false;
      hasResult = false;
    });
    Get.snackbar('Cancelled', 'Recognition stopped');
  }

  void _reset() {
    setState(() {
      hasResult = false;
      _recognizedItems = [];
      _total = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isLoading ? _buildLoadingView() : _buildMainView(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recognizing products...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a moment',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _cancelRecognition,
            icon: const Icon(Icons.close_rounded, color: Colors.red),
            label: const Text('Cancel',
                style: TextStyle(color: Colors.red, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    if (!hasResult) {
      return _buildScanPrompt();
    }
    return _buildResultView();
  }

  Widget _buildScanPrompt() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Scan Your Groceries',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Take a photo of your items and they\'ll\nbe automatically added to your cart',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _pickFromCamera,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Camera',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Gallery',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      side: BorderSide(color: Colors.orange.shade300, width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recognized Items',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.add_a_photo_rounded, size: 20),
              label: const Text('Scan More'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${_recognizedItems.length} item(s) added to cart',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: _recognizedItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final item = _recognizedItems[i];
              final name = item['name'] as String? ?? 'Unknown';
              final qty = item['quantity'] as int? ?? 1;
              final price = (item['price'] as num?)?.toDouble() ?? 0;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.check_rounded,
                          color: Colors.green.shade700),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          Text('x$qty',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    ),
                    Text(
                      '${(price * qty).toStringAsFixed(0)} ₸',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Total bar
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Items Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                '${_total.toStringAsFixed(0)} ₸',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
