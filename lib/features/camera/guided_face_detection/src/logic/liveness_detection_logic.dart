import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/main/constants.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/models/liveness_config.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/models/liveness_state.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/models/liveness_step.dart';

/// Core logic for liveness detection validation
class LivenessDetectionLogic {
  static int _stepFrameCounter = 0;
  // Use 4 required increments so we can show a 3-2-1 countdown
  // (1..3 shown) and then advance on the 4th tick.
  static const int _requiredFrames = 4;

  static LivenessState getState(
    List<Face> faces,
    List<Pose> poses,
    Size? imageSize,
    LivenessStep currentStep,
    LivenessConfig config,
  ) {
    // Skip disabled steps
    if (!config.isStepEnabled(currentStep) &&
        currentStep != LivenessStep.completed) {
      final nextStep = config.getNextStep(currentStep);
      if (nextStep != null) {
        return LivenessState(
          guidance: nextStep.guidance,
          borderColor: Colors.orange,
          currentStep: nextStep,
        );
      }
    }

    if (faces.isEmpty &&
        currentStep != LivenessStep.top &&
        currentStep != LivenessStep.back) {
      _stepFrameCounter = 0;
      return LivenessState.initial(
        guidance: "Yüzünüz algılanamadı",
        currentStep: currentStep,
      );
    }

    if (imageSize == null) {
      _stepFrameCounter = 0;
      return LivenessState.initial(
        guidance: "Görüntü boyutu bekleniyor...",
        currentStep: currentStep,
      );
    }

    if (currentStep.isBackStep || currentStep == LivenessStep.top) {
      return _handleTopBackSteps(faces, poses, currentStep, config);
    }

    return _handleFaceSteps(faces, imageSize, currentStep, config);
  }

  static LivenessState _handleFaceSteps(
    List<Face> faces,
    Size imageSize,
    LivenessStep currentStep,
    LivenessConfig config,
  ) {
    final face = faces.first;
    final yaw = face.headEulerAngleY ?? 0.0;
    final faceWidth = face.boundingBox.width;
    final faceCenter = face.boundingBox.center;
    final imageCenter = Offset(imageSize.width / 2, imageSize.height / 2);

    if (!_isFaceSizeValid(faceWidth)) {
      _stepFrameCounter = 0;
      return LivenessState.initial(
        guidance: faceWidth < Constants.minFaceWidth
            ? "Lütfen biraz yaklaşın"
            : "Lütfen biraz uzaklaşın",
        currentStep: currentStep,
      );
    }

    if (!_isFaceCentered(faceCenter, imageCenter)) {
      _stepFrameCounter = 0;
      return LivenessState.initial(
        guidance: "Lütfen yüzünüzü ortalayın",
        currentStep: currentStep,
      );
    }

    return _checkCurrentStep(yaw, currentStep, config);
  }

  static bool _isFaceSizeValid(double faceWidth) {
    return faceWidth > Constants.minFaceWidth &&
        faceWidth < Constants.maxFaceWidth;
  }

  static bool _isFaceCentered(Offset faceCenter, Offset imageCenter) {
    return (faceCenter.dx - imageCenter.dx).abs() < Constants.centerThreshold &&
        (faceCenter.dy - imageCenter.dy).abs() < Constants.centerThreshold;
  }

  static LivenessState _checkCurrentStep(
    double yaw,
    LivenessStep currentStep,
    LivenessConfig config,
  ) {
    switch (currentStep) {
      case LivenessStep.straight:
        return _checkStraight(yaw, currentStep, config);
      case LivenessStep.right:
        return _checkRight(yaw, currentStep, config);
      case LivenessStep.left:
        return _checkLeft(yaw, currentStep, config);
      case LivenessStep.top:
      case LivenessStep.back:
        return LivenessState.initial(
          guidance: "İşleniyor...",
          currentStep: currentStep,
        );
      case LivenessStep.completed:
        return const LivenessState(
          guidance: "OK - Tüm adımlar tamamlandı! ✓",
          borderColor: Colors.blue,
          currentStep: LivenessStep.completed,
        );
    }
  }

  static LivenessState _checkStraight(
    double yaw,
    LivenessStep currentStep,
    LivenessConfig config,
  ) {
    final isStraight = yaw.abs() < Constants.straightThreshold;

    if (isStraight) {
      _stepFrameCounter++;
      if (_stepFrameCounter >= _requiredFrames) {
        _stepFrameCounter = 0;
        final nextStep = config.getNextStep(currentStep);
        if (nextStep != null) {
          return LivenessState(
            guidance: "Harika! Şimdi ${_getNextStepGuidance(nextStep)}",
            borderColor: Colors.orange,
            currentStep: nextStep,
          );
        }
      }
      // Compute remaining countdown number (3,2,1)
      final remaining = _requiredFrames - _stepFrameCounter;
      return LivenessState(
        // guidance carries the remaining number as a string so UI/TTS can
        // perform a spoken/countdown behavior like "3 2 1"
        guidance: remaining.toString(),
        borderColor: Colors.green,
        currentStep: currentStep,
      );
    }

    _stepFrameCounter = 0;
    return LivenessState.initial(
      guidance: "Lütfen yüzünüzü düz tutun",
      currentStep: currentStep,
    );
  }

  static LivenessState _checkRight(
    double yaw,
    LivenessStep currentStep,
    LivenessConfig config,
  ) {
    final isLookingRight = yaw < -Constants.turnThreshold;

    if (isLookingRight) {
      _stepFrameCounter++;
      if (_stepFrameCounter >= _requiredFrames) {
        _stepFrameCounter = 0;
        final nextStep = config.getNextStep(currentStep);
        if (nextStep != null) {
          return LivenessState(
            guidance: "Mükemmel! Şimdi ${_getNextStepGuidance(nextStep)}",
            borderColor: Colors.orange,
            currentStep: nextStep,
          );
        }
      }
      final remaining = _requiredFrames - _stepFrameCounter;
      return LivenessState(
        guidance: remaining.toString(),
        borderColor: Colors.green,
        currentStep: currentStep,
      );
    }

    _stepFrameCounter = 0;
    return LivenessState.initial(
      guidance: "BAŞINIZI SAĞA ÇEVİRİN",
      currentStep: currentStep,
    );
  }

  static LivenessState _checkLeft(
    double yaw,
    LivenessStep currentStep,
    LivenessConfig config,
  ) {
    final isLookingLeft = yaw > Constants.turnThreshold;

    if (isLookingLeft) {
      _stepFrameCounter++;
      if (_stepFrameCounter >= _requiredFrames) {
        _stepFrameCounter = 0;
        final nextStep = config.getNextStep(currentStep);
        if (nextStep != null) {
          return LivenessState(
            guidance: "Süper! Şimdi ${_getNextStepGuidance(nextStep)}",
            borderColor: Colors.orange,
            currentStep: nextStep,
          );
        }
      }
      final remaining = _requiredFrames - _stepFrameCounter;
      return LivenessState(
        guidance: remaining.toString(),
        borderColor: Colors.green,
        currentStep: currentStep,
      );
    }

    _stepFrameCounter = 0;
    return LivenessState.initial(
      guidance: "BAŞINIZI SOLA ÇEVİRİN",
      currentStep: currentStep,
    );
  }

  static String _getNextStepGuidance(LivenessStep step) {
    switch (step) {
      case LivenessStep.right:
        return "başınızı SAĞA çevirin";
      case LivenessStep.left:
        return "başınızı SOLA çevirin";
      case LivenessStep.top:
        return "başınızı AŞAĞI eğin (tepesini gösterin)";
      case LivenessStep.back:
        return "başınızı ARKAYA çevirin";
      case LivenessStep.completed:
        return "tamamlandı";
      default:
        return step.guidance;
    }
  }

  static LivenessState _handleTopBackSteps(
    List<Face> faces,
    List<Pose> poses,
    LivenessStep currentStep,
    LivenessConfig config,
  ) {
    if (currentStep == LivenessStep.top) {
      return _checkTop(faces, currentStep, config);
    } else if (currentStep == LivenessStep.back) {
      return _checkBack(faces, poses, currentStep, config);
    }

    return LivenessState.initial(
      guidance: "Beklenmeyen durum",
      currentStep: currentStep,
    );
  }

  static LivenessState _checkTop(
    List<Face> faces,
    LivenessStep currentStep,
    LivenessConfig config,
  ) {
    if (faces.isNotEmpty) {
      final face = faces.first;
      final pitch = face.headEulerAngleX ?? 0.0;
      final isShowingTop = pitch < -30.0;

      if (isShowingTop) {
        _stepFrameCounter++;
        if (_stepFrameCounter >= _requiredFrames) {
          _stepFrameCounter = 0;
          final nextStep = config.getNextStep(currentStep);
          if (nextStep != null) {
            return LivenessState(
              guidance: "Mükemmel! Şimdi ${_getNextStepGuidance(nextStep)}",
              borderColor: Colors.orange,
              currentStep: nextStep,
            );
          }
        }
        final remaining = _requiredFrames - _stepFrameCounter;
        return LivenessState(
          guidance: remaining.toString(),
          borderColor: Colors.green,
          currentStep: currentStep,
        );
      }
    }

    _stepFrameCounter = 0;
    return LivenessState.initial(
      guidance: "BAŞINIZI AŞAĞI EĞİN",
      currentStep: currentStep,
    );
  }

  static LivenessState _checkBack(
    List<Face> faces,
    List<Pose> poses,
    LivenessStep currentStep,
    LivenessConfig config,
  ) {
    if (faces.isNotEmpty) {
      final face = faces.first;
      final yaw = face.headEulerAngleY ?? 0.0;
      String direction = "";
      if (yaw.abs() < 60) {
        direction = " Daha fazla dönün!";
      }

      _stepFrameCounter = 0;
      return LivenessState.initial(
        guidance: "BAŞINIZI ARKAYA ÇEVİRİN $direction",
        currentStep: currentStep,
      );
    }

    if (poses.isNotEmpty) {
      final pose = poses.first;
      final isShowingBack = _validateBackPose(pose);

      if (isShowingBack) {
        _stepFrameCounter++;
        if (_stepFrameCounter >= _requiredFrames) {
          _stepFrameCounter = 0;
          final nextStep = config.getNextStep(currentStep);
          if (nextStep != null) {
            return LivenessState(
              guidance: "OK - Tüm adımlar tamamlandı! ✓",
              borderColor: Colors.orange,
              currentStep: nextStep,
            );
          }
        }
        final remaining = _requiredFrames - _stepFrameCounter;
        return LivenessState(
          guidance: remaining.toString(),
          borderColor: Colors.green,
          currentStep: currentStep,
        );
      }
    }

    _stepFrameCounter = 0;
    return LivenessState.initial(
      guidance: poses.isEmpty
          ? "Vücudunuzu çerçevede tutun ve başınızı ARKAYA çevirin"
          : "Başınızı tam ARKAYA çevirin (ense gösterin)",
      currentStep: currentStep,
    );
  }

  static bool _validateBackPose(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    // Sadece omuzların görünürlüğüne göre arka pozisyonu doğrula
    final shouldersVisible =
        (leftShoulder != null && leftShoulder.likelihood > 0.1) ||
        (rightShoulder != null && rightShoulder.likelihood > 0.1);

    return shouldersVisible;
  }
}
