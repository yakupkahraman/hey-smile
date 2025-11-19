class Constants {
  static const double turnThreshold = 45.0; // Sağa/sola dönme (Yaw) - 45 derece
  static const double tiltThreshold = 20.0; // Yukarı/aşağı eğme (Pitch)
  static const double straightThreshold = 10.0; // Düz bakma toleransı
  // --- YENİ SABİTLER: Çerçeve kontrolü için ---
// Yüzün 'boundingBox' genişliğinin (piksel) olması gereken min/max aralığı
static const double minFaceWidth = 100.0;  // Daha yakın yüzler için düşürüldü
static const double maxFaceWidth = 450.0;  // Daha büyük yüzler için artırıldı

// Yüz merkezinin, görüntü merkezinden maks. ne kadar
// uzakta (piksel) olabileceği
static const double centerThreshold = 200.0; // Daha toleranslı hizalama
}