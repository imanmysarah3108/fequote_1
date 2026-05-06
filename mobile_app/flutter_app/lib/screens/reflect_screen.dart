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
  bool isPressed = false; // For button animation

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
      setState(() => isLoading = true);

      final image = await _controller!.takePicture();
      File imageFile = File(image.path);
      var result = await ApiService.detectEmotion(imageFile);

      String emotion = result['emotion'];
      List<String> quotes = result['quotes'];

      setState(() => isLoading = false);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(emotion: emotion, quotes: quotes),
          ),
        );
      }
    } catch (e) {
      print("❌ ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: _controller == null || !_controller!.value.isInitialized
          ? Container(
              decoration: AppTheme.backgroundGradient,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            )
          : Stack(
              children: [
                Container(decoration: AppTheme.backgroundGradient),
                SafeArea(
                  child: Column(
                    children: [
                      // Top Right Toggle (Flip Camera)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 24.0, top: 10.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.toggle_on, color: Colors.white, size: 28),
                                  onPressed: _switchCamera,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Text("Moment of Reflection", style: textTheme.headlineMedium),
                      const SizedBox(height: 12),
                      Text(
                        "Position your face in the frame.\nRelax and breathe.",
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 40),

                      // Large Glass Camera Frame
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(48),
                                  child: AspectRatio(
                                    aspectRatio: 3 / 4,
                                    child: CameraPreview(_controller!),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Animated Glass Capture Button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: GestureDetector(
                          onTapDown: (_) => setState(() => isPressed = true),
                          onTapUp: (_) {
                            setState(() => isPressed = false);
                            if (!isLoading) _captureAndSend();
                          },
                          onTapCancel: () => setState(() => isPressed = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            transform: Matrix4.diagonal3Values(isPressed ? 0.9 : 1.0, isPressed ? 0.9 : 1.0, 1.0),
                            alignment: Alignment.center,
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.25),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Loading Overlay
                if (isLoading)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
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