import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class ReflectScreen extends StatefulWidget {
  const ReflectScreen({super.key});

  @override
  State<ReflectScreen> createState() => _ReflectScreenState();
}

class _ReflectScreenState extends State<ReflectScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  int cameraIndex = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();

    _controller = CameraController(
      cameras![cameraIndex],
      ResolutionPreset.medium,
    );

    await _controller!.initialize();

    if (mounted) setState(() {});
  }

  // 🔄 Switch front/back camera
  Future<void> _switchCamera() async {
    if (cameras == null || cameras!.isEmpty) return;

    cameraIndex = (cameraIndex + 1) % cameras!.length;

    _controller = CameraController(
      cameras![cameraIndex],
      ResolutionPreset.medium,
    );

    await _controller!.initialize();

    setState(() {});
  }

  // 📸 Capture + Send
  Future<void> _captureAndSend() async {
    try {
      setState(() {
        isLoading = true;
      });

      final image = await _controller!.takePicture();

      print("📸 IMAGE PATH: ${image.path}");

      File imageFile = File(image.path);

      var result = await ApiService.detectEmotion(imageFile);

      String emotion = result['emotion'];
      List<String> quotes = result['quotes'];

      print("🧠 EMOTION: $emotion");

      setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            emotion: emotion,
            quotes: quotes,
          ),
        ),
      );
    } catch (e) {
      print("❌ ERROR: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 📷 Camera Preview
                Positioned.fill(
                  child: CameraPreview(_controller!),
                ),

                // 🔄 Flip Camera Button
                Positioned(
                  top: 50,
                  right: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.flip_camera_ios,
                          color: Colors.white),
                      onPressed: _switchCamera,
                    ),
                  ),
                ),

                // ⏳ Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),

                // 🎯 Bottom Controls
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      const Text(
                        "Capture your emotion",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: isLoading ? null : _captureAndSend,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}