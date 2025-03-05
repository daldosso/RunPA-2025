import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCameraInitialized = false;
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras.first, ResolutionPreset.medium);
      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scatta una Foto')),
      body: _isCameraInitialized
          ? RotatedBox(
              quarterTurns: _controller.description.sensorOrientation ~/ 90,
              child: CameraPreview(_controller),
            )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: _isCameraInitialized
          ? FloatingActionButton(
              child: Icon(Icons.camera),
              onPressed: () async {
                try {
                  final image = await _controller.takePicture();
                  if (!mounted) return;

                  setState(() {
                    imagePaths.add(image.path);
                  });

                  // ignore: use_build_context_synchronously
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          DisplayPictureScreen(imagePaths: imagePaths),
                    ),
                  );
                } catch (e) {
                  // ignore: avoid_print
                  print(e);
                }
              },
            )
          : null,
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final List<String> imagePaths;

  const DisplayPictureScreen({super.key, required this.imagePaths});

  void _sendPhotos() {
    // ignore: avoid_print
    print("Invio delle foto: $imagePaths");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Foto Scattate')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return Image.file(File(imagePaths[index]), fit: BoxFit.cover);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: _sendPhotos,
              child: Text('Invia Foto'),
            ),
          ),
        ],
      ),
    );
  }
}
