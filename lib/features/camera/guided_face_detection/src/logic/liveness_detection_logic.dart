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
  static bool _countdownCompleted = false;
  // Countdown frames: 0-1->3, 2-3->2, 4-5->1, then verify position
  // Each number shown for 2 frames (~600-800ms each), total ~2 seconds per position

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
      _countdownCompleted = false;
      return LivenessState.initial(
        guidance: "Face not detected",
        currentStep: currentStep,
      );
    }

    if (imageSize == null) {
      _stepFrameCounter = 0;
      _countdownCompleted = false;
      return LivenessState.initial(
        guidance: "Waiting for image size...",
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
      _countdownCompleted = false;
      return LivenessState.initial(
        guidance: faceWidth < Constants.minFaceWidth
            ? "Please move closer"
            : "Please move back",
        currentStep: currentStep,
      );
    }

    if (!_isFaceCentered(faceCenter, imageCenter)) {
      _stepFrameCounter = 0;
      _countdownCompleted = false;
      return LivenessState.initial(
        guidance: "Please center your face",
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
          guidance: "Processing...",
          currentStep: currentStep,
        );
      case LivenessStep.completed:
        return const LivenessState(
          guidance: "OK - All steps completed! ✓",
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
      // Countdown tamamlanmadıysa sayım yap
      if (!_countdownCompleted) {
        _stepFrameCounter++;

        // Countdown: 0-1->3, 2-3->2, 4-5->1 (her sayı 2 frame)
        String countdownText;
        if (_stepFrameCounter <= 1) {
          countdownText = '3';
        } else if (_stepFrameCounter <= 3) {
          countdownText = '2';
        } else if (_stepFrameCounter <= 5) {
          countdownText = '1';
        } else {
          // Countdown tamamlandı, şimdi pozisyonu doğrula
          _countdownCompleted = true;
          _stepFrameCounter = 0;
          countdownText = 'Hold...';
        }

        return LivenessState(
          guidance: countdownText,
          borderColor: Colors.green,
          currentStep: currentStep,
        );
      } else {
        // Countdown tamamlandı, hızlıca pozisyonu kontrol et
        _stepFrameCounter++;

        // 2 frame daha bekle (hızlı kontrol)
        if (_stepFrameCounter >= 2) {
          _stepFrameCounter = 0;
          _countdownCompleted = false;
          final nextStep = config.getNextStep(currentStep);
          if (nextStep != null) {
            return LivenessState(
              guidance: "Great! Now ${_getNextStepGuidance(nextStep)}",
              borderColor: Colors.orange,
              currentStep: nextStep,
            );
          }
        }

        return LivenessState(
          guidance: 'Hold...',
          borderColor: Colors.green,
          currentStep: currentStep,
        );
      }
    }

    _stepFrameCounter = 0;
    _countdownCompleted = false;
    return LivenessState.initial(
      guidance: "Please keep your face straight",
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
      // Countdown tamamlanmadıysa sayım yap
      if (!_countdownCompleted) {
        _stepFrameCounter++;

        // Countdown: 0-1->3, 2-3->2, 4-5->1 (her sayı 2 frame)
        String countdownText;
        if (_stepFrameCounter <= 1) {
          countdownText = '3';
        } else if (_stepFrameCounter <= 3) {
          countdownText = '2';
        } else if (_stepFrameCounter <= 5) {
          countdownText = '1';
        } else {
          // Countdown tamamlandı, şimdi pozisyonu doğrula
          _countdownCompleted = true;
          _stepFrameCounter = 0;
          countdownText = 'Hold...';
        }

        return LivenessState(
          guidance: countdownText,
          borderColor: Colors.green,
          currentStep: currentStep,
        );
      } else {
        // Countdown tamamlandı, hızlıca pozisyonu kontrol et
        _stepFrameCounter++;

        // 2 frame daha bekle (hızlı kontrol)
        if (_stepFrameCounter >= 2) {
          _stepFrameCounter = 0;
          _countdownCompleted = false;
          final nextStep = config.getNextStep(currentStep);
          if (nextStep != null) {
            return LivenessState(
              guidance: "Perfect! Now ${_getNextStepGuidance(nextStep)}",
              borderColor: Colors.orange,
              currentStep: nextStep,
            );
          }
        }

        return LivenessState(
          guidance: 'Hold...',
          borderColor: Colors.green,
          currentStep: currentStep,
        );
      }
    }

    _stepFrameCounter = 0;
    _countdownCompleted = false;
    return LivenessState.initial(
      guidance: "TURN YOUR HEAD TO THE RIGHT",
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
      // Countdown tamamlanmadıysa sayım yap
      if (!_countdownCompleted) {
        _stepFrameCounter++;

        // Countdown: 0-1->3, 2-3->2, 4-5->1 (her sayı 2 frame)
        String countdownText;
        if (_stepFrameCounter <= 1) {
          countdownText = '3';
        } else if (_stepFrameCounter <= 3) {
          countdownText = '2';
        } else if (_stepFrameCounter <= 5) {
          countdownText = '1';
        } else {
          // Countdown tamamlandı, şimdi pozisyonu doğrula
          _countdownCompleted = true;
          _stepFrameCounter = 0;
          countdownText = 'Hold...';
        }

        return LivenessState(
          guidance: countdownText,
          borderColor: Colors.green,
          currentStep: currentStep,
        );
      } else {
        // Countdown tamamlandı, hızlıca pozisyonu kontrol et
        _stepFrameCounter++;

        // 2 frame daha bekle (hızlı kontrol)
        if (_stepFrameCounter >= 2) {
          _stepFrameCounter = 0;
          _countdownCompleted = false;
          final nextStep = config.getNextStep(currentStep);
          if (nextStep != null) {
            return LivenessState(
              guidance: "Excellent! Now ${_getNextStepGuidance(nextStep)}",
              borderColor: Colors.orange,
              currentStep: nextStep,
            );
          }
        }

        return LivenessState(
          guidance: 'Hold...',
          borderColor: Colors.green,
          currentStep: currentStep,
        );
      }
    }

    _stepFrameCounter = 0;
    _countdownCompleted = false;
    return LivenessState.initial(
      guidance: "TURN YOUR HEAD TO THE LEFT",
      currentStep: currentStep,
    );
  }

  static String _getNextStepGuidance(LivenessStep step) {
    switch (step) {
      case LivenessStep.right:
        return "turn your head to the RIGHT";
      case LivenessStep.left:
        return "turn your head to the LEFT";
      case LivenessStep.top:
        return "tilt your head DOWN (show top)";
      case LivenessStep.back:
        return "turn your head to the BACK";
      case LivenessStep.completed:
        return "completed";
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
      guidance: "Unexpected state",
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
        // Countdown tamamlanmadıysa sayım yap
        if (!_countdownCompleted) {
          _stepFrameCounter++;

          // Countdown: 0-1->3, 2-3->2, 4-5->1 (her sayı 2 frame)
          String countdownText;
          if (_stepFrameCounter <= 1) {
            countdownText = '3';
          } else if (_stepFrameCounter <= 3) {
            countdownText = '2';
          } else if (_stepFrameCounter <= 5) {
            countdownText = '1';
          } else {
            // Countdown tamamlandı, şimdi pozisyonu doğrula
            _countdownCompleted = true;
            _stepFrameCounter = 0;
            countdownText = 'Hold...';
          }

          return LivenessState(
            guidance: countdownText,
            borderColor: Colors.green,
            currentStep: currentStep,
          );
        } else {
          // Countdown tamamlandı, hızlıca pozisyonu kontrol et
          _stepFrameCounter++;

          // 2 frame daha bekle (hızlı kontrol)
          if (_stepFrameCounter >= 2) {
            _stepFrameCounter = 0;
            _countdownCompleted = false;
            final nextStep = config.getNextStep(currentStep);
            if (nextStep != null) {
              return LivenessState(
                guidance: "Perfect! Now ${_getNextStepGuidance(nextStep)}",
                borderColor: Colors.orange,
                currentStep: nextStep,
              );
            }
          }

          return LivenessState(
            guidance: 'Hold...',
            borderColor: Colors.green,
            currentStep: currentStep,
          );
        }
      }
    }

    _stepFrameCounter = 0;
    _countdownCompleted = false;
    return LivenessState.initial(
      guidance: "TILT YOUR HEAD DOWN",
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
        direction = " Turn more!";
      }

      _stepFrameCounter = 0;
      _countdownCompleted = false;
      return LivenessState.initial(
        guidance: "TURN YOUR HEAD TO THE BACK$direction",
        currentStep: currentStep,
      );
    }

    if (poses.isNotEmpty) {
      final pose = poses.first;
      final isShowingBack = _validateBackPose(pose);

      if (isShowingBack) {
        // Countdown tamamlanmadıysa sayım yap
        if (!_countdownCompleted) {
          _stepFrameCounter++;

          // Countdown: 0-1->3, 2-3->2, 4-5->1 (her sayı 2 frame)
          String countdownText;
          if (_stepFrameCounter <= 1) {
            countdownText = '3';
          } else if (_stepFrameCounter <= 3) {
            countdownText = '2';
          } else if (_stepFrameCounter <= 5) {
            countdownText = '1';
          } else {
            // Countdown tamamlandı, şimdi pozisyonu doğrula
            _countdownCompleted = true;
            _stepFrameCounter = 0;
            countdownText = 'Hold...';
          }

          return LivenessState(
            guidance: countdownText,
            borderColor: Colors.green,
            currentStep: currentStep,
          );
        } else {
          // Countdown tamamlandı, hızlıca pozisyonu kontrol et
          _stepFrameCounter++;

          // 2 frame daha bekle (hızlı kontrol)
          if (_stepFrameCounter >= 2) {
            _stepFrameCounter = 0;
            _countdownCompleted = false;
            final nextStep = config.getNextStep(currentStep);
            if (nextStep != null) {
              return LivenessState(
                guidance: "OK - All steps completed! ✓",
                borderColor: Colors.orange,
                currentStep: nextStep,
              );
            }
          }

          return LivenessState(
            guidance: 'Hold...',
            borderColor: Colors.green,
            currentStep: currentStep,
          );
        }
      }
    }

    _stepFrameCounter = 0;
    _countdownCompleted = false;
    return LivenessState.initial(
      guidance: poses.isEmpty
          ? "Keep your body in frame and turn your head BACK"
          : "Turn your head completely BACK (show neck)",
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
