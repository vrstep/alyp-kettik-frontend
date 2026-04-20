import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Full-screen camera scanner with a guided frame overlay.
/// Opens as a pushed route; pops back with recognized items.
class ProductScannerScreen extends StatefulWidget {
  const ProductScannerScreen({super.key});

  @override
  State<ProductScannerScreen> createState() => _ProductScannerScreenState();
}

class _ProductScannerScreenState extends State<ProductScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'No cameras available');
        return;
      }

      // Prefer back camera
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Camera error: $e');
    }
  }

  Future<void> _captureAndRecognize() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final xFile = await _controller!.takePicture();
      final bytes = await xFile.readAsBytes();

      // Pop back with the captured bytes
      if (mounted) {
        Navigator.of(context).pop(bytes);
      }
    } catch (e) {
      setState(() => _isCapturing = false);
      Get.snackbar('Error', 'Failed to capture image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_isInitialized && _controller != null)
            _buildCameraPreview()
          else if (_errorMessage != null)
            _buildError()
          else
            _buildLoading(),

          // Dimmed overlay with cutout frame
          if (_isInitialized) _ScanOverlay(isCapturing: _isCapturing),

          // Top bar
          _buildTopBar(),

          // Bottom controls
          if (_isInitialized) _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final size = MediaQuery.of(context).size;
    final controller = _controller!;

    // 1. Fetch the raw aspect ratio from the camera
    double cameraAspectRatio = controller.value.aspectRatio;

    // 2. Correct the aspect ratio for portrait vs landscape
    // If we are holding the phone in portrait mode, we must invert the landscape ratio.
    final isPortrait = size.height > size.width;
    if (isPortrait && cameraAspectRatio > 1) {
      cameraAspectRatio = 1 / cameraAspectRatio;
    }

    // SizedBox.expand forces the preview to fill the entire screen bounds
    return SizedBox.expand(
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            // 3. Create a box with the exact correct aspect ratio
            width: size.width,
            height: size.width / cameraAspectRatio,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Starting camera...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Go Back',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black38,
                  shape: const CircleBorder(),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'YOLO Scanner',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Flash toggle
              IconButton(
                onPressed: () async {
                  if (_controller == null) return;
                  final mode = _controller!.value.flashMode;
                  await _controller!.setFlashMode(
                    mode == FlashMode.off ? FlashMode.torch : FlashMode.off,
                  );
                  setState(() {});
                },
                icon: Icon(
                  _controller?.value.flashMode == FlashMode.torch
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black38,
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
                Colors.black.withValues(alpha: 0.85),
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Position items inside the frame',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery button
                  _buildCircleButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () => Navigator.of(context).pop('gallery'),
                  ),
                  // Capture button
                  GestureDetector(
                    onTap: _isCapturing ? null : _captureAndRecognize,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isCapturing ? Colors.grey : Colors.white,
                        ),
                        child: _isCapturing
                            ? const Padding(
                                padding: EdgeInsets.all(18),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.black54,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  // Placeholder for symmetry
                  const SizedBox(width: 56),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dimmed overlay with a clear scanning frame cutout.
class _ScanOverlay extends StatelessWidget {
  final bool isCapturing;

  const _ScanOverlay({required this.isCapturing});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = constraints.maxWidth;
        final screenH = constraints.maxHeight;
        // Frame: centered, 85% width, 4:3 aspect ratio
        final frameW = screenW * 0.85;
        final frameH = frameW * (4 / 3);
        final left = (screenW - frameW) / 2;
        final top = (screenH - frameH) / 2 - 30; // shift up slightly

        return Stack(
          children: [
            // Dimmed background with cutout
            ClipPath(
              clipper: _FrameCutout(
                Rect.fromLTWH(left, top, frameW, frameH),
                borderRadius: 20,
              ),
              child: Container(color: Colors.black.withValues(alpha: 0.55)),
            ),

            // Animated corner brackets
            Positioned(
              left: left,
              top: top,
              child: _AnimatedFrame(
                width: frameW,
                height: frameH,
                isCapturing: isCapturing,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Clips everything except the given rectangle (creates a "window" cutout).
class _FrameCutout extends CustomClipper<Path> {
  final Rect cutout;
  final double borderRadius;

  _FrameCutout(this.cutout, {this.borderRadius = 0});

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cutout, Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(_FrameCutout oldClipper) =>
      cutout != oldClipper.cutout || borderRadius != oldClipper.borderRadius;
}

/// Animated corner brackets around the scan frame.
class _AnimatedFrame extends StatefulWidget {
  final double width;
  final double height;
  final bool isCapturing;

  const _AnimatedFrame({
    required this.width,
    required this.height,
    required this.isCapturing,
  });

  @override
  State<_AnimatedFrame> createState() => _AnimatedFrameState();
}

class _AnimatedFrameState extends State<_AnimatedFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isCapturing ? Colors.amber : Colors.white;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _CornerBracketPainter(
            color: color.withValues(alpha: _pulseAnim.value),
            strokeWidth: 3,
            cornerLength: 32,
            borderRadius: 20,
          ),
        );
      },
    );
  }
}

/// Paints only the four corner brackets of a rounded rectangle.
class _CornerBracketPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double borderRadius;

  _CornerBracketPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final r = borderRadius;
    final cl = cornerLength;
    final w = size.width;
    final h = size.height;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, cl)
        ..lineTo(0, r)
        ..quadraticBezierTo(0, 0, r, 0)
        ..lineTo(cl, 0),
      paint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(w - cl, 0)
        ..lineTo(w - r, 0)
        ..quadraticBezierTo(w, 0, w, r)
        ..lineTo(w, cl),
      paint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, h - cl)
        ..lineTo(0, h - r)
        ..quadraticBezierTo(0, h, r, h)
        ..lineTo(cl, h),
      paint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(w - cl, h)
        ..lineTo(w - r, h)
        ..quadraticBezierTo(w, h, w, h - r)
        ..lineTo(w, h - cl),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CornerBracketPainter old) =>
      color != old.color || strokeWidth != old.strokeWidth;
}
