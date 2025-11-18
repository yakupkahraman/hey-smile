import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hey_smile/features/auth/presentation/widgets/my_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CapturePage extends StatelessWidget {
  const CapturePage({super.key});

  static const bool isCaptured = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: PhosphorIcon(PhosphorIcons.caretLeft()),
        ),
        title: const Text('Uploaded Photos'),
      ),
      body: SafeArea(
        child: isCaptured
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      FaceContainer(imagePath: 'assets/images/front.jpeg'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FaceContainer(
                              imagePath: 'assets/images/left.jpeg',
                            ),
                          ),
                          Expanded(
                            child: FaceContainer(
                              imagePath: 'assets/images/right.jpeg',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FaceContainer(
                              imagePath: 'assets/images/top.jpeg',
                            ),
                          ),
                          Expanded(
                            child: FaceContainer(
                              imagePath: 'assets/images/back.jpeg',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Center(
                        child: PhosphorIcon(
                          PhosphorIcons.camera(PhosphorIconsStyle.regular),
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No photos uploaded yet.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: MyButton(
                      title: 'Capture Photos',
                      onPressed: () => context.push('/camera'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class FaceContainer extends StatelessWidget {
  const FaceContainer({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.grey[300],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
              ),
              Center(
                child: PhosphorIcon(
                  PhosphorIcons.plus(PhosphorIconsStyle.regular),
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
