import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/models/liveness_config.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/models/liveness_state.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/models/liveness_step.dart';

/// Provider for managing liveness detection state
class LivenessProvider extends ChangeNotifier {
  LivenessState _state = LivenessState.initial();
  List<Pose> _currentPoses = [];
  LivenessConfig _config = LivenessConfig.all();
  Map<LivenessStep, Uint8List> _capturedImages = {};

  LivenessState get state => _state;
  List<Pose> get currentPoses => _currentPoses;
  LivenessConfig get config => _config;
  Map<LivenessStep, Uint8List> get capturedImages => _capturedImages;

  /// Set configuration for enabled/disabled steps
  void setConfig(LivenessConfig config) {
    _config = config;
    _state = LivenessState.initial(currentStep: config.getFirstStep());
    notifyListeners();
  }

  void updateState(LivenessState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void updatePoses(List<Pose> poses) {
    _currentPoses = poses;
    notifyListeners();
  }

  /// Add captured image for a step
  void addCapturedImage(LivenessStep step, Uint8List imageData) {
    _capturedImages[step] = imageData;
    notifyListeners();
  }

  /// Get all captured images as a list
  List<Uint8List> getAllCapturedImages() {
    return _capturedImages.values.toList();
  }

  /// Check if all steps are completed and images captured
  bool areAllStepsCompleted() {
    return _state.currentStep == LivenessStep.completed;
  }

  /// Move to next enabled step
  void moveToNextStep() {
    final nextStep = _config.getNextStep(_state.currentStep);
    if (nextStep != null) {
      _state = _state.copyWith(currentStep: nextStep);
      notifyListeners();
    }
  }

  void reset() {
    _state = LivenessState.initial(currentStep: _config.getFirstStep());
    _currentPoses = [];
    _capturedImages = {};
    notifyListeners();
  }
}
