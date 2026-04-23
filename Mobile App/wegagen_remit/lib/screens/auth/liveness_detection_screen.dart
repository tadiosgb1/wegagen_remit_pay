import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import '../../models/kyc_data.dart';

class LivenessDetectionScreen extends StatefulWidget {
  const LivenessDetectionScreen({super.key});

  @override
  State<LivenessDetectionScreen> createState() =>
      _LivenessDetectionScreenState();
}

class _LivenessDetectionScreenState extends State<LivenessDetectionScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  // Liveness detection state
  List<LivenessChallenge> _challenges = [];
  int _currentChallengeIndex = 0;
  bool _challengeCompleted = false;
  Timer? _challengeTimer;
  Timer? _countdownTimer;
  int _countdown = 3;
  bool _showCountdown = true;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  // Face detection simulation
  bool _faceDetected = false;
  Timer? _faceDetectionTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateChallenges();
    _initializeCamera();
    _startCountdown();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  void _generateChallenges() {
    _challenges = LivenessChallenge.getRandomChallenges();
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _showErrorDialog(
          'Camera permission is required for liveness detection',
        );
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();

      // Find front camera
      CameraDescription? frontCamera;
      for (var camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      if (frontCamera == null) {
        _showErrorDialog('Front camera not found');
        return;
      }

      // Initialize camera controller
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });

        // Start face detection simulation
        _startFaceDetectionSimulation();
      }
    } catch (e) {
      _showErrorDialog('Failed to initialize camera: $e');
    }
  }

  void _startFaceDetectionSimulation() {
    // TODO: Replace with real ML face detection
    // For now, simulate face detection with better logic
    _faceDetectionTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      if (mounted) {
        setState(() {
          // Simulate more realistic face detection (80% success rate)
          _faceDetected = Random().nextDouble() > 0.2;
        });
      }
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _showCountdown = false;
        });
        _startCurrentChallenge();
      }
    });
  }

  void _startCurrentChallenge() {
    if (_currentChallengeIndex >= _challenges.length) {
      _completeLivenessDetection();
      return;
    }

    final challenge = _challenges[_currentChallengeIndex];

    // Reset challenge state
    setState(() {
      _challengeCompleted = false;
      _isProcessing = false;
    });

    // Start challenge timer
    _challengeTimer = Timer(challenge.timeout, () {
      if (!_challengeCompleted) {
        _simulateChallengeCompletion();
      }
    });

    // Simulate challenge completion after a random delay
    Timer(Duration(milliseconds: 2000 + Random().nextInt(2000)), () {
      if (!_challengeCompleted && mounted) {
        _simulateChallengeCompletion();
      }
    });
  }

  void _simulateChallengeCompletion() {
    if (!mounted) return;

    setState(() {
      _challengeCompleted = true;
      _isProcessing = true;
    });

    _progressController.forward().then((_) {
      Timer(const Duration(milliseconds: 500), () {
        _nextChallenge();
      });
    });
  }

  void _nextChallenge() {
    _challengeTimer?.cancel();
    _progressController.reset();

    setState(() {
      _currentChallengeIndex++;
    });

    if (_currentChallengeIndex < _challenges.length) {
      Timer(const Duration(milliseconds: 500), () {
        _startCurrentChallenge();
      });
    } else {
      _completeLivenessDetection();
    }
  }

  void _completeLivenessDetection() {
    // Take a selfie photo
    _takeSelfiePhoto();
  }

  Future<void> _takeSelfiePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();

      // Show success dialog and return the selfie XFile
      _showSuccessDialog(photo);
    } catch (e) {
      _showErrorDialog('Failed to take selfie: $e');
    }
  }

  void _showSuccessDialog(XFile selfieFile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Liveness Verification Complete'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text(
              'Your liveness verification has been completed successfully!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, selfieFile); // Return the selfie XFile
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, false); // Return failure
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _challengeTimer?.cancel();
    _countdownTimer?.cancel();
    _faceDetectionTimer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Liveness Detection'),
      ),
      body: Stack(
        children: [
          // Camera Preview
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(child: CameraPreview(_cameraController!)),

          // Loading indicator when camera is not ready
          if (!_isCameraInitialized)
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Face detection overlay
          if (_isCameraInitialized)
            Positioned.fill(
              child: CustomPaint(
                painter: FaceOverlayPainter(
                  faceDetected: _faceDetected,
                  pulseAnimation: _pulseAnimation,
                ),
              ),
            ),

          // Countdown overlay
          if (_showCountdown)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Get Ready',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _countdown.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Challenge instructions
          if (!_showCountdown && _currentChallengeIndex < _challenges.length)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      _challenges[_currentChallengeIndex].instruction,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    _buildChallengeIcon(
                      _challenges[_currentChallengeIndex].action,
                    ),
                  ],
                ),
              ),
            ),

          // Progress indicator
          if (!_showCountdown)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  // Progress bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: List.generate(_challenges.length, (index) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                              right: index < _challenges.length - 1 ? 4 : 0,
                            ),
                            decoration: BoxDecoration(
                              color: index < _currentChallengeIndex
                                  ? Colors.green
                                  : index == _currentChallengeIndex &&
                                        _challengeCompleted
                                  ? Colors.green
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Challenge status
                  if (_currentChallengeIndex < _challenges.length)
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _challengeCompleted
                                ? Colors.green.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Icon(
                            _challengeCompleted ? Icons.check : Icons.face,
                            color: Colors.white,
                            size: 40,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChallengeIcon(LivenessAction action) {
    IconData icon;
    switch (action) {
      case LivenessAction.blinkEyes:
        icon = Icons.visibility;
        break;
      case LivenessAction.turnLeft:
        icon = Icons.arrow_back;
        break;
      case LivenessAction.turnRight:
        icon = Icons.arrow_forward;
        break;
      case LivenessAction.smile:
        icon = Icons.sentiment_very_satisfied;
        break;
      case LivenessAction.openMouth:
        icon = Icons.record_voice_over;
        break;
    }

    return Icon(icon, color: Colors.white, size: 48);
  }
}

class FaceOverlayPainter extends CustomPainter {
  final bool faceDetected;
  final Animation<double> pulseAnimation;

  FaceOverlayPainter({required this.faceDetected, required this.pulseAnimation})
    : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = faceDetected ? Colors.green : Colors.red;

    // Draw face detection oval
    final center = Offset(size.width / 2, size.height / 2 - 50);
    final radiusX = 120.0 * pulseAnimation.value;
    final radiusY = 150.0 * pulseAnimation.value;

    final rect = Rect.fromCenter(
      center: center,
      width: radiusX * 2,
      height: radiusY * 2,
    );

    canvas.drawOval(rect, paint);

    // Draw corner guides
    final cornerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.white.withValues(alpha: 0.8);

    final cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom - cornerLength),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
