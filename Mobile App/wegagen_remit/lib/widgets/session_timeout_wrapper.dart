import 'package:flutter/material.dart';
import '../services/session_timeout_service.dart';

class SessionTimeoutWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTimeout;
  final VoidCallback? onWarning;

  const SessionTimeoutWrapper({
    super.key,
    required this.child,
    required this.onTimeout,
    this.onWarning,
  });

  @override
  State<SessionTimeoutWrapper> createState() => _SessionTimeoutWrapperState();
}

class _SessionTimeoutWrapperState extends State<SessionTimeoutWrapper> {
  final SessionTimeoutService _sessionService = SessionTimeoutService();

  @override
  void initState() {
    super.initState();
    _sessionService.startSession(
      onTimeout: widget.onTimeout,
      onWarning: widget.onWarning,
    );
  }

  @override
  void dispose() {
    _sessionService.stopSession();
    super.dispose();
  }

  void _onMeaningfulUserActivity() {
    // Only reset timer for meaningful interactions within dashboard content
    _sessionService.resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Only detect meaningful gestures within dashboard content
      onTap: _onMeaningfulUserActivity,
      onScaleStart: (_) => _onMeaningfulUserActivity,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}