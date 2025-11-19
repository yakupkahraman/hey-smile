import 'package:hey_smile/features/camera/guided_face_detection/src/models/liveness_config.dart';

/// Bu dosya LivenessConfig'in nasıl kullanılacağını gösterir
///
/// main.dart içinde kullanım:
/// ```dart
/// final provider = LivenessProvider();
/// provider.setConfig(ConfigExamples.sadeceDuzBakma);
/// ```

class ConfigExamples {
  // ============================================
  // HAZIR KONFİGÜRASYONLAR
  // ============================================

  /// Tüm adımlar aktif (varsayılan)
  /// Sıra: Düz -> Sağ -> Sol -> Yukarı -> Ense -> Tamamlandı
  static final allSteps = LivenessConfig.all();

  /// Sadece yüz rotasyonu (düz, sağ, sol)
  /// Sıra: Düz -> Sağ -> Sol -> Tamamlandı
  static final faceRotationOnly = LivenessConfig.faceRotationOnly();

  /// Sadece düz bakma kontrolü
  /// Sıra: Düz -> Tamamlandı
  static final basicOnly = LivenessConfig.basicOnly();

  // ============================================
  // ÖZEL KONFİGÜRASYONLAR
  // ============================================

  /// Sadece düz bakma
  /// Kullanım: Hızlı doğrulama için
  static final sadeceDuzBakma = LivenessConfig.custom(
    straight: true,
    right: false,
    left: false,
    top: false,
    back: false,
  );

  /// Sadece sağa bakma
  /// Kullanım: Tek yön kontrolü
  static final sadeceSaga = LivenessConfig.custom(
    straight: false,
    right: true,
    left: false,
    top: false,
    back: false,
  );

  /// Sadece sola bakma
  /// Kullanım: Tek yön kontrolü
  static final sadeceSola = LivenessConfig.custom(
    straight: false,
    right: false,
    left: true,
    top: false,
    back: false,
  );

  /// Düz + Sağ + Sol (yukarı ve ense yok)
  /// Kullanım: Hızlı 3 adımlı doğrulama
  static final ucAdim = LivenessConfig.custom(
    straight: true,
    right: true,
    left: true,
    top: false,
    back: false,
  );

  /// Düz + Yukarı (yan yönler yok)
  /// Kullanım: Basit yukarı/aşağı kontrolü
  static final duzVeYukari = LivenessConfig.custom(
    straight: true,
    right: false,
    left: false,
    top: true,
    back: false,
  );

  /// Sadece ense kontrolü
  /// Kullanım: Arka taraf doğrulaması
  static final sadecaEnse = LivenessConfig.custom(
    straight: false,
    right: false,
    left: false,
    top: false,
    back: true,
  );

  /// Sadece yan bakışlar (sağ + sol)
  /// Kullanım: Hızlı yan profil kontrolü
  static final sadceYanBakislar = LivenessConfig.custom(
    straight: false,
    right: true,
    left: true,
    top: false,
    back: false,
  );

  /// Tam kontrol (tüm yönler)
  /// Kullanım: Maksimum güvenlik
  static final tamKontrol = LivenessConfig.custom(
    straight: true,
    right: true,
    left: true,
    top: true,
    back: true,
  );

  /// Düz + Sağ (sol yok)
  /// Kullanım: İki adımlı hızlı doğrulama
  static final duzVeSag = LivenessConfig.custom(
    straight: true,
    right: true,
    left: false,
    top: false,
    back: false,
  );

  /// Düz + Sol (sağ yok)
  /// Kullanım: İki adımlı hızlı doğrulama
  static final duzVeSol = LivenessConfig.custom(
    straight: true,
    right: false,
    left: true,
    top: false,
    back: false,
  );
}

/// KULLANIM ÖRNEKLERİ:
/// 
/// main.dart içinde:
/// ```dart
/// void main() {
///   runApp(const MyApp());
/// }
/// 
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return ChangeNotifierProvider(
///       create: (_) {
///         final provider = LivenessProvider();
///         
///         // ÖRN 1: Sadece düz bakma
///         provider.setConfig(ConfigExamples.sadeceDuzBakma);
///         
///         // ÖRN 2: Sadece sağa bakma
///         // provider.setConfig(ConfigExamples.sadeceSaga);
///         
///         // ÖRN 3: Üç adımlı (düz, sağ, sol)
///         // provider.setConfig(ConfigExamples.ucAdim);
///         
///         // ÖRN 4: Tam kontrol
///         // provider.setConfig(ConfigExamples.tamKontrol);
///         
///         // ÖRN 5: Özel konfigürasyon
///         // provider.setConfig(LivenessConfig.custom(
///         //   straight: true,
///         //   right: true,
///         //   left: false,  // Sola bakmayı kapat
///         //   top: false,
///         //   back: false,
///         // ));
///         
///         return provider;
///       },
///       child: MaterialApp(
///         home: const LivenessPage(),
///       ),
///     );
///   }
/// }
/// ```
/// 
/// TEK SATIRDA AYARLAMA:
/// ```dart
/// // main.dart'ta istediğiniz konfigürasyonu tek satırda değiştirin:
/// provider.setConfig(ConfigExamples.sadeceDuzBakma);  // Sadece düz bakma
/// provider.setConfig(ConfigExamples.sadeceSaga);       // Sadece sağa bakma
/// provider.setConfig(ConfigExamples.ucAdim);           // Düz + Sağ + Sol
/// provider.setConfig(ConfigExamples.tamKontrol);       // Tüm adımlar
/// ```
