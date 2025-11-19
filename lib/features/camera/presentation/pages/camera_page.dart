import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/models/liveness_config.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/pages/liveness_page.dart';
import 'package:hey_smile/features/camera/guided_face_detection/src/providers/liveness_provider.dart';
import 'package:provider/provider.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liveness Detection Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final provider = LivenessProvider();
            provider.setConfig(LivenessConfig.faceRotationOnly());

            final result = await Navigator.push<List<Uint8List>>(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: provider,
                  child: const LivenessPage(),
                ),
              ),
            );

            if (result != null && context.mounted) {
              // Get captured images map from provider
              final capturedImages = provider.capturedImages;

              // Navigate back with the captured images map
              Navigator.pop(context, capturedImages);
            }
          },
          child: const Text('Liveness Testi Başlat'),
        ),
      ),
    );
  }
}
