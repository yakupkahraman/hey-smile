import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/models/liveness_step.dart';

/// Camera preview widget with face frame and guidance overlay
class CameraPreviewView extends StatelessWidget {
  final CameraController cameraController;
  final String guidanceText;
  final Color borderColor;
  final LivenessStep currentStep;

  const CameraPreviewView({
    super.key,
    required this.cameraController,
    required this.guidanceText,
    required this.borderColor,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const circleWidthRatio = 0.95;
    const circleHeightMultiplier = 1.2;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCameraPreview(),
            _buildOverlay(size, circleWidthRatio, circleHeightMultiplier),
            _buildFaceFrame(size, circleWidthRatio, circleHeightMultiplier),
            _buildGuidanceText(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: cameraController.value.previewSize!.height,
                height: cameraController.value.previewSize!.width,
                child: CameraPreview(cameraController),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(Size size, double widthRatio, double heightMultiplier) {
    final frameWidth = size.width * widthRatio;
    final frameHeight = size.width * widthRatio * heightMultiplier;

    return Positioned.fill(
      child: CustomPaint(
        painter: _OverlayPainter(
          frameWidth: frameWidth,
          frameHeight: frameHeight,
        ),
      ),
    );
  }

  Widget _buildFaceFrame(
    Size size,
    double widthRatio,
    double heightMultiplier,
  ) {
    return Positioned.fill(
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: size.width * widthRatio,
          height: size.width * widthRatio * heightMultiplier,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(
              Radius.elliptical(
                size.width * widthRatio,
                size.width * widthRatio * heightMultiplier,
              ),
            ),
            border: Border.all(color: borderColor, width: 6.0),
          ),
        ),
      ),
    );
  }

  Widget _buildGuidanceText() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          child: Text(
            guidanceText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Custom painter to create black overlay with elliptical cutout
class _OverlayPainter extends CustomPainter {
  final double frameWidth;
  final double frameHeight;

  _OverlayPainter({required this.frameWidth, required this.frameHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepOrange
      ..style = PaintingStyle.fill;

    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final center = Offset(size.width / 2, size.height / 2);
    final ovalRect = Rect.fromCenter(
      center: center,
      width: frameWidth,
      height: frameHeight,
    );

    final ovalPath = Path()..addOval(ovalRect);

    final combinedPath = Path.combine(PathOperation.difference, path, ovalPath);

    canvas.drawPath(combinedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return oldDelegate.frameWidth != frameWidth ||
        oldDelegate.frameHeight != frameHeight;
  }
}
