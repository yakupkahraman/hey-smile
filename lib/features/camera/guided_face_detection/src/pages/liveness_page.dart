import 'dart:developer';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

import 'package:hey_smile/features/camera/guided_face_detection/src/main/camera_image_converter.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/main/face_detection_service.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/logic/liveness_detection_logic.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/models/liveness_state.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/models/liveness_step.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/main/pose_detection_service.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/providers/liveness_provider.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/widgets/camera_preview_view.dart';

class LivenessPage extends StatefulWidget {
  const LivenessPage({super.key});

  @override
  State<LivenessPage> createState() => _LivenessPageState();
}

class _LivenessPageState extends State<LivenessPage> {
  CameraController? _cameraController;
  final FaceDetectionService _faceDetectionService = FaceDetectionService();
  final PoseDetectionService _poseDetectionService = PoseDetectionService();
  final FlutterTts _tts = FlutterTts();

  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  LivenessStep? _lastSpokenStep;
  String? _lastSpokenCountdown;
  LivenessStep? _lastCapturedStep;
  CameraImage? _lastCameraImage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await _initializeCamera();
      _initializeMLKit();
      await _initializeTTS();
      _startImageStream();
    } catch (e) {
      log("Initialization error: $e");
      _showError("Kamera başlatılamadı");
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    if (mounted) {
      setState(() => _isCameraInitialized = true);
    }
  }

  void _initializeMLKit() {
    _faceDetectionService.initialize();
    _poseDetectionService.initialize();
  }

  Future<void> _initializeTTS() async {
    await _tts.setLanguage('tr-TR');
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  void _startImageStream() {
    _cameraController?.startImageStream(_processCameraImage);
  }

  void _cleanupResources() {
    try {
      if (_cameraController?.value.isStreamingImages ?? false) {
        _cameraController?.stopImageStream();
      }
    } catch (e) {
      log("Error stopping image stream: $e");
    }
    _cameraController?.dispose();
    _faceDetectionService.dispose();
    _poseDetectionService.dispose();
    _tts.stop();
  }

  void _showError(String message) {
    if (mounted) {
      final provider = context.read<LivenessProvider>();
      provider.updateState(
        LivenessState(
          guidance: "Hata: $message",
          borderColor: Colors.red,
          currentStep: LivenessStep.straight,
        ),
      );
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    if (!mounted) return;

    _isProcessing = true;

    try {
      // Son kamera görüntüsünü sakla (fotoğraf çekmek için)
      _lastCameraImage = image;

      final inputImage = await CameraImageConverter.convert(
        image,
        _cameraController!.description,
      );

      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final faces = await _faceDetectionService.processImage(inputImage);
      final poses = await _poseDetectionService.processImage(inputImage);

      if (!mounted) return;

      final provider = context.read<LivenessProvider>();
      final currentStep = provider.state.currentStep;
      final config = provider.config;

      final newState = LivenessDetectionLogic.getState(
        faces,
        poses,
        inputImage.metadata?.size,
        currentStep,
        config,
      );

      if (provider.state != newState) {
        // If the step changed, reset countdown memory so next step can countdown
        if (newState.currentStep != currentStep) {
          _lastSpokenCountdown = null;

          // Adım değiştiğinde ve önceki adım config'te aktifse fotoğraf çek
          if (currentStep != LivenessStep.completed &&
              _lastCapturedStep != currentStep &&
              currentStep != newState.currentStep &&
              config.isStepEnabled(currentStep)) {
            await _captureImage(currentStep);
            _lastCapturedStep = currentStep;
          }
        }

        provider.updateState(newState);

        // Sadece adım değişikliklerinde TTS çalıştır
        if (newState.currentStep != currentStep) {
          await _speakStepChange(newState.currentStep);
        }

        // Eğer guidance sadece bir sayıysa (3/2/1), TTS ile geri say
        final guidance = newState.guidance.trim();
        if (guidance.length == 1 &&
            (guidance == '1' || guidance == '2' || guidance == '3')) {
          if (_lastSpokenCountdown != guidance) {
            _lastSpokenCountdown = guidance;
            try {
              await _tts.speak(guidance);
            } catch (e) {
              log("TTS countdown error: $e");
            }
          }
        }

        // Tüm adımlar tamamlandıysa fotoğrafları döndür
        if (newState.currentStep == LivenessStep.completed &&
            currentStep != LivenessStep.completed) {
          await _handleCompletion();
        }
      }

      provider.updatePoses(poses);
    } catch (e) {
      log("Image processing error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _captureImage(LivenessStep step) async {
    try {
      if (_lastCameraImage == null) {
        log("No camera image available for capture");
        return;
      }

      // CameraImage'i JPEG formatına dönüştür
      final imageBytes = await _convertCameraImageToJpeg(_lastCameraImage!);

      if (mounted && imageBytes != null) {
        final provider = context.read<LivenessProvider>();
        provider.addCapturedImage(step, imageBytes);
        log("Image captured for step: ${step.name}");
      }
    } catch (e) {
      log("Error capturing image: $e");
    }
  }

  Future<Uint8List?> _convertCameraImageToJpeg(CameraImage cameraImage) async {
    try {
      img.Image? image;

      if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        // YUV420 formatından dönüştürme
        final int width = cameraImage.width;
        final int height = cameraImage.height;

        final int uvRowStride = cameraImage.planes[1].bytesPerRow;
        final int uvPixelStride = cameraImage.planes[1].bytesPerPixel ?? 1;

        image = img.Image(width: width, height: height);

        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            final int uvIndex =
                uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
            final int index = y * width + x;

            final yp = cameraImage.planes[0].bytes[index];
            final up = cameraImage.planes[1].bytes[uvIndex];
            final vp = cameraImage.planes[2].bytes[uvIndex];

            int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
            int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
                .round()
                .clamp(0, 255);
            int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

            image.setPixelRgba(x, y, r, g, b, 255);
          }
        }
      } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
        // BGRA formatından dönüştürme
        image = img.Image.fromBytes(
          width: cameraImage.width,
          height: cameraImage.height,
          bytes: cameraImage.planes[0].bytes.buffer,
          format: img.Format.uint8,
          numChannels: 4,
        );
      }

      if (image == null) {
        log("Failed to create image");
        return null;
      }

      // Görüntüyü 90 derece saat yönünde döndür (saat yönünün tersindeki dönüşü düzelt)
      image = img.copyRotate(image, angle: 270);

      // Ön kamera için görüntüyü yatay olarak çevir (ayna etkisi)
      if (_cameraController?.description.lensDirection ==
          CameraLensDirection.front) {
        image = img.flipHorizontal(image);
      }

      // JPEG formatına kodla
      return Uint8List.fromList(img.encodeJpg(image, quality: 85));
    } catch (e) {
      log("Error converting camera image: $e");
      return null;
    }
  }

  Future<void> _handleCompletion() async {
    try {
      // Processing'i durdur ki yeni frame'ler işlenmesin
      _isProcessing = true;

      final provider = context.read<LivenessProvider>();
      final capturedImages = provider.getAllCapturedImages();

      log(
        "All steps completed! Total images captured: ${capturedImages.length}",
      );

      // Kamera stream'ini durdur
      if (_cameraController?.value.isStreamingImages ?? false) {
        await _cameraController?.stopImageStream();
      }

      // Biraz bekle ki tüm işlemler tamamlansın
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        // Fotoğrafları döndürerek sayfayı kapat
        Navigator.of(context).pop(capturedImages);
      }
    } catch (e) {
      log("Error handling completion: $e");
    }
  }

  Future<void> _speakStepChange(LivenessStep step) async {
    // Aynı adım için tekrar konuşma
    if (_lastSpokenStep == step) return;

    _lastSpokenStep = step;

    String message;
    switch (step) {
      case LivenessStep.straight:
        message = "Önü gösterin";
        break;
      case LivenessStep.right:
        message = "Sağı gösterin";
        break;
      case LivenessStep.left:
        message = "Solu gösterin";
        break;
      case LivenessStep.top:
        message = "Tepeyi gösterin";
        break;
      case LivenessStep.back:
        message = "Arkayı gösterin";
        break;
      case LivenessStep.completed:
        message = "Tamamlandı";
        break;
    }

    try {
      await _tts.speak(message);
    } catch (e) {
      log("TTS error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<LivenessProvider>(
      builder: (context, provider, child) {
        return CameraPreviewView(
          cameraController: _cameraController!,
          guidanceText: provider.state.guidance,
          borderColor: provider.state.borderColor,
          currentStep: provider.state.currentStep,
        );
      },
    );
  }
}
