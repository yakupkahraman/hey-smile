import 'dart:developer';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  FaceDetector? _faceDetector;

  void initialize() {
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableTracking: true,
      // Gelecekte göz kırpma/gülümseme eklemek isterseniz:
      // enableClassification: true, 
    );
    _faceDetector = FaceDetector(options: options);
  }

  Future<List<Face>> processImage(InputImage inputImage) async {
    if (_faceDetector == null) return [];
    try {
      return await _faceDetector!.processImage(inputImage);
    } catch (e) {
      log("FaceDetector processImage hatası: $e");
      return [];
    }
  }

  void dispose() {
    _faceDetector?.close();
  }
}