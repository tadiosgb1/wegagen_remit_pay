import 'package:flutter/material.dart';

/// Widget that tracks meaningful user interactions within dashboard content
/// Note: Simplified to pass-through since SessionTimeoutWrapper now handles gesture detection
class ActivityTracker extends StatelessWidget {
  final Widget child;
  final String? interactionType;

  const ActivityTracker({
    super.key,
    required this.child,
    this.interactionType,
  });

  @override
  Widget build(BuildContext context) {
    // Simply return the child - SessionTimeoutWrapper handles all gesture detection
    return child;
  }
}