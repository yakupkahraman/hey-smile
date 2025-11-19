import 'dart:developer';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectionService {
  PoseDetector? _poseDetector;

  void initialize() {
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.base,
    );
    _poseDetector = PoseDetector(options: options);
  }

  Future<List<Pose>> processImage(InputImage inputImage) async {
    if (_poseDetector == null) return [];
    try {
      return await _poseDetector!.processImage(inputImage);
    } catch (e) {
      log("PoseDetector processImage hatası: $e");
      return [];
    }
  }

  void dispose() {
    _poseDetector?.close();
  }
}
