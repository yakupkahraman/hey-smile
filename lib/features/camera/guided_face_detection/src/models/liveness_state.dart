import 'package:flutter/material.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/models/liveness_step.dart';

class LivenessState {
  final String guidance;
  final Color borderColor;
  final LivenessStep currentStep;

  const LivenessState({
    required this.guidance,
    required this.borderColor,
    required this.currentStep,
  });

  factory LivenessState.initial({
    String guidance = "KAMERAYA DOĞRU BAKIN",
    Color borderColor = Colors.red,
    LivenessStep currentStep = LivenessStep.straight,
  }) {
    return LivenessState(
      guidance: guidance,
      borderColor: borderColor,
      currentStep: currentStep,
    );
  }

  LivenessState copyWith({
    String? guidance,
    Color? borderColor,
    LivenessStep? currentStep,
  }) {
    return LivenessState(
      guidance: guidance ?? this.guidance,
      borderColor: borderColor ?? this.borderColor,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LivenessState &&
        other.guidance == guidance &&
        other.borderColor == borderColor &&
        other.currentStep == currentStep;
  }

  @override
  int get hashCode => Object.hash(guidance, borderColor, currentStep);
}
