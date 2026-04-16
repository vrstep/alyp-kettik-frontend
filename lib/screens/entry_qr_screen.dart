import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

import '../controllers/auth_controller.dart';
import '../controllers/session_controller.dart';
import '../utils/server.dart';

/// Screen that generates and displays a one-time entry QR code
/// for the turnstile scanner to read.
class EntryQrScreen extends StatefulWidget {
  const EntryQrScreen({super.key});

  @override
  State<EntryQrScreen> createState() => _EntryQrScreenState();
}

class _EntryQrScreenState extends State<EntryQrScreen> {
  String? _entryToken;
  bool _isLoading = true;
  String? _error;
  Timer? _expiryTimer;
  Timer? _pollTimer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _generateToken();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateToken() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Stop any previous timers
    _pollTimer?.cancel();
    _expiryTimer?.cancel();

    try {
      final auth = Get.find<AuthController>();
      final res = await http.post(
        Uri.parse(entryQrUrl),
        headers: auth.authHeaders,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['entry_token'] as String;
        final expiresIn = data['expires_in_seconds'] as int;

        setState(() {
          _entryToken = token;
          _isLoading = false;
          _secondsLeft = expiresIn;
        });

        // Start countdown timer
        _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_secondsLeft <= 1) {
            timer.cancel();
            _generateToken();
          } else {
            setState(() => _secondsLeft--);
          }
        });

        // Poll for session creation by the turnstile.
        // This screen is only reachable when there's NO active session,
        // so any session that appears means the turnstile just created it.
        _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
          final session = Get.find<SessionController>();
          await session.fetchActiveSession();
          if (session.hasActiveSession) {
            _pollTimer?.cancel();
            _expiryTimer?.cancel();
            if (mounted) {
              Get.back(result: true);
            }
          }
        });
      } else {
        final err = jsonDecode(res.body);
        setState(() {
          _error = err['detail'] ?? 'Failed to generate QR code';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Entry'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _isLoading
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Generating entry code...'),
                    ],
                  )
                : _error != null
                    ? _buildErrorView()
                    : _buildQrView(),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade400),
        const SizedBox(height: 16),
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _generateToken,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try Again'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQrView() {
    final isExpiring = _secondsLeft <= 30;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // QR Code
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: QrImageView(
            data: _entryToken!,
            version: QrVersions.auto,
            size: 250,
            backgroundColor: Colors.white,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.blue.shade800,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.blue.shade900,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Timer
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isExpiring ? Colors.red.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExpiring ? Colors.red.shade200 : Colors.green.shade200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 20,
                color: isExpiring ? Colors.red.shade600 : Colors.green.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Expires in ${_formatTime(_secondsLeft)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isExpiring ? Colors.red.shade700 : Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Instructions
        Text(
          'Show this QR code to the\nstore entrance scanner',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // Refresh button
        TextButton.icon(
          onPressed: _generateToken,
          icon: const Icon(Icons.refresh_rounded, size: 20),
          label: const Text('Generate New Code'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue.shade600,
          ),
        ),
      ],
    );
  }
}
