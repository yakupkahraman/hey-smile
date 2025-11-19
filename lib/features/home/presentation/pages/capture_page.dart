import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hey_smile/features/auth/presentation/widgets/my_button.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/models/liveness_step.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({super.key, this.capturedImages});

  final Map<LivenessStep, Uint8List>? capturedImages;

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  late Map<LivenessStep, Uint8List> _images;

  @override
  void initState() {
    super.initState();
    _images = widget.capturedImages ?? {};
  }

  bool get hasImages => _images.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: PhosphorIcon(PhosphorIcons.caretLeft()),
        ),
        title: const Text('Uploaded Photos'),
      ),
      body: SafeArea(
        child: hasImages
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      FaceContainer(
                        imagePath: null,
                        imageData: _images[LivenessStep.straight],
                        label: 'Front',
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FaceContainer(
                              imagePath: null,
                              imageData: _images[LivenessStep.left],
                              label: 'Left',
                            ),
                          ),
                          Expanded(
                            child: FaceContainer(
                              imagePath: null,
                              imageData: _images[LivenessStep.right],
                              label: 'Right',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FaceContainer(
                              imagePath: null,
                              imageData: _images[LivenessStep.top],
                              label: 'Top',
                            ),
                          ),
                          Expanded(
                            child: FaceContainer(
                              imagePath: null,
                              imageData: _images[LivenessStep.back],
                              label: 'Back',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Center(
                        child: PhosphorIcon(
                          PhosphorIcons.camera(PhosphorIconsStyle.regular),
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No photos uploaded yet.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: MyButton(
                      title: 'Capture Photos',
                      onPressed: () async {
                        final result = await context.push('/camera');
                        if (result != null &&
                            result is Map<LivenessStep, Uint8List>) {
                          setState(() {
                            _images = result;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class FaceContainer extends StatelessWidget {
  const FaceContainer({
    super.key,
    this.imagePath,
    this.imageData,
    required this.label,
  });

  final String? imagePath;
  final Uint8List? imageData;
  final String label;

  bool get hasImage => imagePath != null || imageData != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.grey[300],
          ),
          child: Stack(
            children: [
              if (hasImage)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: imageData != null
                        ? Image.memory(imageData!, fit: BoxFit.cover)
                        : Image.asset(imagePath!, fit: BoxFit.cover),
                  ),
                ),
              Center(
                child: PhosphorIcon(
                  hasImage
                      ? PhosphorIcons.pencilSimple(PhosphorIconsStyle.regular)
                      : PhosphorIcons.plus(PhosphorIconsStyle.regular),
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
