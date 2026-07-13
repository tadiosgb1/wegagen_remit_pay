import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfessionalPinField extends StatefulWidget {
  final Function(String) onCompleted;
  final Function(String)? onChanged;
  final int length;
  final bool obscureText;
  final String? errorMessage;
  final VoidCallback? onClear;
  final bool autofocus;
  final String? title;
  final String? subtitle;
  final bool showToggleButton;
  final VoidCallback? onToggleVisibility;

  const ProfessionalPinField({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.length = 4,
    this.obscureText = true,
    this.errorMessage,
    this.onClear,
    this.autofocus = false,
    this.title,
    this.subtitle,
    this.showToggleButton = true,
    this.onToggleVisibility,
  });

  @override
  State<ProfessionalPinField> createState() => _ProfessionalPinFieldState();
}

class _ProfessionalPinFieldState extends State<ProfessionalPinField>
    with TickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late AnimationController _shakeController;
  late AnimationController _successController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _successAnimation;

  String _currentPin = '';
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _successAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.bounceIn,
    ));

    if (widget.autofocus && _focusNodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes.first.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _shakeController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void shake() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
    
    // Clear all fields and focus first field
    for (var controller in _controllers) {
      controller.clear();
    }
    _currentPin = '';
    _isCompleted = false;
    _focusNodes.first.requestFocus();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    _currentPin = _controllers.map((c) => c.text).join();
    
    if (_currentPin.length == widget.length && !_isCompleted) {
      _isCompleted = true;
      _successController.forward();
      
      // Haptic feedback for completion
      HapticFeedback.lightImpact();
      
      widget.onCompleted(_currentPin);
    } else if (_currentPin.length < widget.length) {
      _isCompleted = false;
      _successController.reverse();
    }
    
    widget.onChanged?.call(_currentPin);
  }

  void _onKeyEvent(int index, RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
      }
    }
  }

  Color _getBorderColor(int index) {
    if (widget.errorMessage != null) {
      return Colors.red;
    }
    
    if (_controllers[index].text.isNotEmpty) {
      return _isCompleted ? Colors.green : const Color(0xFFF37021);
    }
    
    if (_focusNodes[index].hasFocus) {
      return const Color(0xFFF37021);
    }
    
    return Colors.grey.shade300;
  }

  Color _getBackgroundColor(int index) {
    if (widget.errorMessage != null) {
      return Colors.red.shade50;
    }
    
    if (_controllers[index].text.isNotEmpty) {
      return _isCompleted 
          ? Colors.green.shade50 
          : const Color(0xFFF37021).withValues(alpha: 0.1);
    }
    
    if (_focusNodes[index].hasFocus) {
      return const Color(0xFFF37021).withValues(alpha: 0.05);
    }
    
    return Colors.grey.shade50;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shakeAnimation, _successAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title and Subtitle
              if (widget.title != null) ...[
                Text(
                  widget.title!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              
              if (widget.subtitle != null) ...[
                Text(
                  widget.subtitle!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],

              // PIN Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(widget.length, (index) {
                  return Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(index),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getBorderColor(index),
                        width: 2,
                      ),
                      boxShadow: [
                        if (_focusNodes[index].hasFocus || _controllers[index].text.isNotEmpty)
                          BoxShadow(
                            color: _getBorderColor(index).withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                      ],
                    ),
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (event) => _onKeyEvent(index, event),
                      child: TextFormField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        obscureText: widget.obscureText,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isCompleted ? Colors.green.shade700 : Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onChanged(index, value),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Toggle Visibility Button
              if (widget.showToggleButton) ...[
                GestureDetector(
                  onTap: widget.onToggleVisibility,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.obscureText ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFFF37021),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.obscureText ? "Show PIN" : "Hide PIN",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFF37021),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Error Message
              if (widget.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Success Animation Indicator
              if (_isCompleted) ...[
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _successAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _successAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    );
                  },
                ),
              ],

              // Clear Button (for development/debugging)
              if (widget.onClear != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    for (var controller in _controllers) {
                      controller.clear();
                    }
                    _currentPin = '';
                    _isCompleted = false;
                    _successController.reverse();
                    _focusNodes.first.requestFocus();
                    widget.onClear!();
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}