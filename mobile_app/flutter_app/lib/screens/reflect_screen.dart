import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/reflect_provider.dart';
import '../providers/quote_provider.dart';
import '../providers/settings_provider.dart';
import '../app_routes.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'result_screen.dart';
import 'settings_screen.dart';

class ReflectScreen extends StatefulWidget {
  const ReflectScreen({super.key});

  @override
  State<ReflectScreen> createState() => _ReflectScreenState();
}

class _ReflectScreenState extends State<ReflectScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  int cameraIndex = 0;

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
    if (mounted) setState(() {});
  }

  Future<void> _captureAndSend() async {
    final reflectProvider = context.read<ReflectProvider>();
    final quoteProvider = context.read<QuoteProvider>();
    final settings = context.read<SettingsProvider>();

    if (settings.deviceId == null) {
      await settings.init();
    }

    final image = await _controller!.takePicture();
    final result = await reflectProvider.captureAndDetect(
      File(image.path),
      deviceId: settings.deviceId,
    );

    if (result != null && mounted) {
      reflectProvider.updateQuoteFromResult(quoteProvider, result);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    }
  }

  void _goToDashboard() {
    Navigator.pushNamed(context, AppRoutes.moodDashboard);
  }

  void _goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ReflectProvider>().isLoading;
    final textTheme = Theme.of(context).textTheme;
    final navHeight = appBottomNavTotalHeight(context);

    return Scaffold(
      body: _controller == null || !_controller!.value.isInitialized
          ? Container(
              decoration: AppTheme.backgroundGradient,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          : Stack(
              children: [
                Container(decoration: AppTheme.backgroundGradient),
                SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const SizedBox(height: AppTheme.spaceLg),
                      Text(
                        'Moment of Reflection',
                        style: textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl),
                        child: Text(
                          'Position your face in the frame.\nRelax and breathe.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppTheme.spaceLg,
                            0,
                            AppTheme.spaceLg,
                            navHeight * 0.12,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(48),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                      child: Container(
                                        width: double.infinity,
                                        constraints: BoxConstraints(
                                          maxHeight: constraints.maxHeight,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(48),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.45),
                                            width: 1,
                                          ),
                                          boxShadow: AppTheme.cardShadow,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(46),
                                          child: AspectRatio(
                                            aspectRatio: 3 / 4,
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                CameraPreview(_controller!),
                                                Positioned(
                                                  right: AppTheme.spaceMd,
                                                  bottom: AppTheme.spaceMd,
                                                  child: Semantics(
                                                    button: true,
                                                    label: 'Switch camera',
                                                    child: GestureDetector(
                                                    onTap: _switchCamera,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(24),
                                                      child: BackdropFilter(
                                                        filter: ImageFilter.blur(
                                                          sigmaX: 10,
                                                          sigmaY: 10,
                                                        ),
                                                        child: Container(
                                                          width: AppTheme.minTapTarget,
                                                          height: AppTheme.minTapTarget,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white
                                                                .withValues(alpha: 0.22),
                                                            shape: BoxShape.circle,
                                                            border: Border.all(
                                                              color: Colors.white
                                                                  .withValues(alpha: 0.5),
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.black
                                                                    .withValues(alpha: 0.1),
                                                                blurRadius: 8,
                                                              ),
                                                            ],
                                                          ),
                                                          child: const Icon(
                                                            Icons.cameraswitch_rounded,
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AppBottomNavBar(
                    activeTab: BottomNavTab.camera,
                    centerIsCapture: true,
                    isCaptureLoading: isLoading,
                    onCapture: _captureAndSend,
                    onDashboard: _goToDashboard,
                    onSettings: _goToSettings,
                  ),
                ),
                if (isLoading)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(color: Colors.white),
                              const SizedBox(height: AppTheme.spaceMd),
                              Text(
                                'Reading your expression…',
                                style: textTheme.bodyMedium,
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
