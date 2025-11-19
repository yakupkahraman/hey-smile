import 'package:hey_smile/features/camera/guided_face_detection/src/models/liveness_step.dart';

/// Configuration for liveness detection steps
class LivenessConfig {
  final bool enableStraight;
  final bool enableRight;
  final bool enableLeft;
  final bool enableTop;
  final bool enableBack;

  const LivenessConfig({
    this.enableStraight = true,
    this.enableRight = true,
    this.enableLeft = true,
    this.enableTop = true,
    this.enableBack = true,
  });

  /// Default configuration with all steps enabled
  factory LivenessConfig.all() {
    return const LivenessConfig();
  }

  /// Only face rotation (straight, right, left)
  factory LivenessConfig.faceRotationOnly() {
    return const LivenessConfig(
      enableStraight: true,
      enableRight: true,
      enableLeft: true,
      enableTop: false,
      enableBack: false,
    );
  }

  /// Only basic check (straight look)
  factory LivenessConfig.basicOnly() {
    return const LivenessConfig(
      enableStraight: true,
      enableRight: false,
      enableLeft: false,
      enableTop: false,
      enableBack: false,
    );
  }

  /// Custom configuration
  factory LivenessConfig.custom({
    bool straight = true,
    bool right = false,
    bool left = false,
    bool top = false,
    bool back = false,
  }) {
    return LivenessConfig(
      enableStraight: straight,
      enableRight: right,
      enableLeft: left,
      enableTop: top,
      enableBack: back,
    );
  }

  /// Get enabled steps in order
  List<LivenessStep> getEnabledSteps() {
    final steps = <LivenessStep>[];

    if (enableStraight) steps.add(LivenessStep.straight);
    if (enableRight) steps.add(LivenessStep.right);
    if (enableLeft) steps.add(LivenessStep.left);
    if (enableTop) steps.add(LivenessStep.top);
    if (enableBack) steps.add(LivenessStep.back);

    steps.add(LivenessStep.completed);

    return steps;
  }

  /// Get next step after current step
  LivenessStep? getNextStep(LivenessStep currentStep) {
    final enabledSteps = getEnabledSteps();
    final currentIndex = enabledSteps.indexOf(currentStep);

    if (currentIndex == -1 || currentIndex >= enabledSteps.length - 1) {
      return null;
    }

    return enabledSteps[currentIndex + 1];
  }

  /// Get first step
  LivenessStep getFirstStep() {
    final steps = getEnabledSteps();
    return steps.isNotEmpty ? steps.first : LivenessStep.completed;
  }

  /// Check if a step is enabled
  bool isStepEnabled(LivenessStep step) {
    return getEnabledSteps().contains(step);
  }
}
