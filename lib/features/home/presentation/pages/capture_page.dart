import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hey_smile/features/auth/presentation/widgets/my_button.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/models/liveness_step.dart';
import 'package:hey_smile/features/tracker/data/tracker_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({super.key, this.capturedImages});

  final Map<LivenessStep, Uint8List>? capturedImages;

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  late Map<LivenessStep, Uint8List> _images;
  final TextEditingController _notesController = TextEditingController();
  final TrackerService _trackerService = TrackerService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _images = widget.capturedImages ?? {};
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get hasImages => _images.isNotEmpty;

  Future<String> _saveImageToFile(Uint8List imageData, String filename) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);
    await file.writeAsBytes(imageData);
    return filePath;
  }

  Future<String> _getAssetImagePath(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final buffer = byteData.buffer;
    final directory = await getTemporaryDirectory();
    final filename = assetPath.split('/').last;
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);
    await file.writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
    return filePath;
  }

  Future<void> _submitHairCheckup() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture photos first!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Resimleri geçici dosyalara kaydet
      String? frontPath;
      String? backPath;
      String? leftPath;
      String? rightPath;
      String? topPath;

      if (_images[LivenessStep.straight] != null) {
        frontPath = await _saveImageToFile(
          _images[LivenessStep.straight]!,
          'front.jpg',
        );
      }

      if (_images[LivenessStep.back] != null) {
        backPath = await _saveImageToFile(
          _images[LivenessStep.back]!,
          'back.jpg',
        );
      }

      if (_images[LivenessStep.left] != null) {
        leftPath = await _saveImageToFile(
          _images[LivenessStep.left]!,
          'left.jpg',
        );
      }

      if (_images[LivenessStep.right] != null) {
        rightPath = await _saveImageToFile(
          _images[LivenessStep.right]!,
          'right.jpg',
        );
      }

      if (_images[LivenessStep.top] != null) {
        topPath = await _saveImageToFile(_images[LivenessStep.top]!, 'top.jpg');
      }

      // Null olanlar için placeholder path kullan (assets'ten geçici dosyaya kopyala)
      if (frontPath == null) {
        frontPath = await _getAssetImagePath('assets/images/front.jpeg');
      }
      if (backPath == null) {
        backPath = await _getAssetImagePath('assets/images/back.jpeg');
      }
      if (leftPath == null) {
        leftPath = await _getAssetImagePath('assets/images/left.jpeg');
      }
      if (rightPath == null) {
        rightPath = await _getAssetImagePath('assets/images/right.jpeg');
      }
      if (topPath == null) {
        topPath = await _getAssetImagePath('assets/images/top.jpeg');
      }

      await _trackerService.createHairCheckup(
        userNotes: _notesController.text.trim().isEmpty
            ? 'No notes'
            : _notesController.text.trim(),
        imageFrontPath: frontPath,
        imageBackPath: backPath,
        imageLeftPath: leftPath,
        imageRightPath: rightPath,
        imageTopPath: topPath,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hair checkup successfully created!'),
            backgroundColor: Colors.green,
          ),
        );
        // Başarılı olduktan sonra geri dön
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
                      const SizedBox(height: 20),
                      // Not alma alanı
                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          hintText: 'Add your notes here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),
                      // Bitir butonu
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : MyButton(
                              title: 'FINISH',
                              onPressed: _submitHairCheckup,
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
