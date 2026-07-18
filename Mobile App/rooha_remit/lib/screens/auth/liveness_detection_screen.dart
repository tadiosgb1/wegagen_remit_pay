import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rooha_remit/constants/colors.dart';
import '../../constants/colors.dart';
enum LivenessStep { lookStraight, turnHeadLeft, turnHeadRight, smile, blink }

class LivenessDetectionScreen extends StatefulWidget {
  const LivenessDetectionScreen({super.key});

  @override
  State<LivenessDetectionScreen> createState() => _LivenessDetectionScreenState();
}

class _LivenessDetectionScreenState extends State<LivenessDetectionScreen> with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  LivenessStep _currentStep = LivenessStep.lookStraight;
  int _completedSteps = 0;
  final List<LivenessStep> _challenges = [
    LivenessStep.lookStraight,
    LivenessStep.turnHeadLeft,
    LivenessStep.turnHeadRight,
    LivenessStep.smile,
    LivenessStep.blink,
  ];

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _showError('Camera permission required');
        return;
      }

      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(frontCamera, ResolutionPreset.high, enableAudio: false);
      await _cameraController!.initialize();

      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      _showError('Failed to start camera');
    }
  }

  void _nextChallenge() {
    if (_completedSteps >= _challenges.length - 1) {
      _completeLiveness();
      return;
    }

    setState(() {
      _completedSteps++;
      _currentStep = _challenges[_completedSteps];
    });
    _animationController.forward(from: 0);
  }

  Future<void> _completeLiveness() async {
    setState(() => _isProcessing = true);

    try {
      final XFile image = await _cameraController!.takePicture();
      if (mounted) {
        Navigator.pop(context, image); // Return captured image
      }
    } catch (e) {
      _showError('Failed to capture final image');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  String _getInstruction() {
    switch (_currentStep) {
      case LivenessStep.lookStraight:
        return "Look straight at the camera";
      case LivenessStep.turnHeadLeft:
        return "Turn your head slowly to the LEFT";
      case LivenessStep.turnHeadRight:
        return "Turn your head slowly to the RIGHT";
      case LivenessStep.smile:
        return "Smile naturally";
      case LivenessStep.blink:
        return "Blink both eyes";
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Liveness Detection'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isCameraInitialized && _cameraController != null
            ? Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CameraPreview(_cameraController!),

                        // Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),

                        // Animated Challenge Circle
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  width: 4,
                                ),
                              ),
                            );
                          },
                        ),

                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            _getInstruction(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress & Button
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      children: [
                        // Progress Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_challenges.length, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 28,
                              height: 6,
                              decoration: BoxDecoration(
                                color: index <= _completedSteps ? const Color(0xFFF37021) : Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          "Step ${_completedSteps + 1} of ${_challenges.length}",
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _nextChallenge,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              _completedSteps >= _challenges.length - 1 ? "Complete Verification" : "Next Challenge",
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}