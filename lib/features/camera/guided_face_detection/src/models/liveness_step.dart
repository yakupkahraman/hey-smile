enum LivenessStep {
  straight,
  right,
  left,
  top,
  back,
  completed;

  String get displayName {
    switch (this) {
      case LivenessStep.straight:
        return 'Düz bakma';
      case LivenessStep.right:
        return 'Sağa bakma';
      case LivenessStep.left:
        return 'Sola bakma';
      case LivenessStep.top:
        return 'Kafanın tepe tarafını göster';
      case LivenessStep.back:
        return 'Kafanın ense tarafını göster';
      case LivenessStep.completed:
        return 'Tamamlandı';
    }
  }

  String get guidance {
    switch (this) {
      case LivenessStep.straight:
        return 'Lütfen yüzünüzü düz tutun';
      case LivenessStep.right:
        return 'Lütfen başınızı SAĞA çevirin';
      case LivenessStep.left:
        return 'Lütfen başınızı SOLA çevirin';
      case LivenessStep.top:
        return 'Lütfen başınızı AŞAĞI eğin (çeneyi göğse yaklaştırın)';
      case LivenessStep.back:
        return 'Başınızı tam ARKAYA çevirin (ense gösterin)';
      case LivenessStep.completed:
        return 'OK - Tüm adımlar tamamlandı! ✓';
    }
  }

  bool get isBackStep => this == LivenessStep.back;
}
