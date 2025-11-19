import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraImageConverter {
  static Future<InputImage?> convert(
    CameraImage image,
    CameraDescription camera,
  ) async {
    try {
      // 1. Byte Verisi
      // Bu işlem 'compute' (isolate) ile ana thread'den dışarı taşınabilir.
      // Şimdilik 'await' ile asenkron yapıyoruz.
      final bytes = await _concatenatePlanes(image.planes);
      if (bytes == null) return null;

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final InputImageRotation imageRotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
              InputImageRotation.rotation0deg;

      // 2. Platforma Özel Format
      final InputImageFormatData formatData = _getFormatData(image);

      // 3. Metadata
      final inputImageMetadata = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: formatData.format,
        bytesPerRow: formatData.bytesPerRow,
      );

      // 4. InputImage
      return InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageMetadata,
      );
    } catch (e) {
      log("InputImage dönüştürme hatası: $e");
      return null;
    }
  }

  static Future<Uint8List?> _concatenatePlanes(List<Plane> planes) async {
    // Performans: WriteBuffer'ı asenkron bir 'compute' bloğunda
    // çalıştırmak UI'da donmayı (jank) engeller.
    return await compute((List<Plane> p) {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in p) {
        allBytes.putUint8List(plane.bytes);
      }
      return allBytes.done().buffer.asUint8List();
    }, planes);
  }

  static InputImageFormatData _getFormatData(CameraImage image) {
    if (Platform.isAndroid) {
      if (image.format.group == ImageFormatGroup.yuv420) {
        return InputImageFormatData(InputImageFormat.nv21, 0);
      }
    } else if (Platform.isIOS) {
      if (image.format.group == ImageFormatGroup.bgra8888) {
        return InputImageFormatData(
            InputImageFormat.bgra8888, image.planes.first.bytesPerRow);
      }
    }
    // Desteklenmeyen format
    throw Exception('Desteklenmeyen görüntü formatı: ${image.format.group}');
  }
}

class InputImageFormatData {
  final InputImageFormat format;
  final int bytesPerRow;
  InputImageFormatData(this.format, this.bytesPerRow);
}