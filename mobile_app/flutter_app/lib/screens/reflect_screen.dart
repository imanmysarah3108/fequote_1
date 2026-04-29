import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/app_theme.dart';
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
      backgroundColor: AppTheme.lightBg,
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Stack(
              children: [
                // Background Gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFF9F6), Color(0xFFFFE5D9)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        "Moment of Reflection",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Position your face in the frame. Relax and breathe.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 40),

                      // Framed Camera Preview
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 3 / 4,
                                    child: CameraPreview(_controller!),
                                  ),
                                ),
                              ),
                              // Glassmorphic Flip Button overlay
                              Positioned(
                                top: 20,
                                right: 20,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      child: IconButton(
                                        icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                                        onPressed: _switchCamera,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Controls
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: GestureDetector(
                          onTap: isLoading ? null : _captureAndSend,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.5),
                              border: Border.all(
                                color: AppTheme.primary,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.2),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Glassmorphic Loading Overlay
                if (isLoading)
                  Positioned.fill(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          color: Colors.white.withValues(alpha: 0.4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(color: AppTheme.primary),
                              const SizedBox(height: 20),
                              Text(
                                "Analyzing emotion...",
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
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