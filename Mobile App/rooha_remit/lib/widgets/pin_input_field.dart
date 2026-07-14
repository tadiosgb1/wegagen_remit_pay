import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInputField extends StatefulWidget {
  final Function(String) onChanged;
  final Function(String)? onCompleted;
  final int length;
  final bool obscureText;
  final String? errorText;
  final bool enabled;

  const PinInputField({
    Key? key,
    required this.onChanged,
    this.onCompleted,
    this.length = 4,
    this.obscureText = false,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<PinInputField> createState() => PinInputFieldState();
}

class PinInputFieldState extends State<PinInputField>
    with TickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  String _currentPin = '';

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
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    
    _updatePin();
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _updatePin() {
    _currentPin = _controllers.map((controller) => controller.text).join();
    widget.onChanged(_currentPin);
    
    if (_currentPin.length == widget.length) {
      widget.onCompleted?.call(_currentPin);
    }
  }

  void shake() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _currentPin = '';
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  widget.length,
                  (index) => _buildPinBox(index),
                ),
              ),
              if (widget.errorText != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    widget.errorText!,
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 12,
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

  Widget _buildPinBox(int index) {
    final bool isFocused = _focusNodes[index].hasFocus;
    final bool hasValue = _controllers[index].text.isNotEmpty;
    final bool hasError = widget.errorText != null;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError
              ? Colors.red.shade400
              : isFocused
                  ? const Color(0xFFF37021)
                  : hasValue
                      ? const Color(0xFFF37021).withValues(alpha: 0.5)
                      : Colors.grey.shade300,
          width: hasError || isFocused ? 2 : 1.5,
        ),
        color: hasValue
            ? const Color(0xFFF37021).withValues(alpha: 0.05)
            : Colors.grey.shade50,
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFFF37021).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : hasValue
                ? [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
      ),
      child: Center(
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) => _onKeyEvent(event, index),
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            enabled: widget.enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            obscureText: widget.obscureText,
            maxLength: 1,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: hasValue
                  ? const Color(0xFFF37021)
                  : Colors.grey.shade600,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) => _onChanged(value, index),
          ),
        ),
      ),
    );
  }
}

// Extension to easily use the PIN input field
extension PinInputFieldExtension on PinInputField {
  static GlobalKey<PinInputFieldState> createKey() {
    return GlobalKey<PinInputFieldState>();
  }
}

// Helper method to create a PIN input field with validation
class PinInputController {
  final GlobalKey<PinInputFieldState> _key = GlobalKey<PinInputFieldState>();
  String _pin = '';
  String? _errorText;

  GlobalKey<PinInputFieldState> get key => _key;
  String get pin => _pin;
  String? get errorText => _errorText;

  void updatePin(String pin) {
    _pin = pin;
  }

  void setError(String? error) {
    _errorText = error;
  }

  void clear() {
    _pin = '';
    _errorText = null;
    _key.currentState?.clear();
  }

  void shake() {
    _key.currentState?.shake();
  }

  bool validate() {
    if (_pin.isEmpty) {
      _errorText = 'Please enter your PIN';
      return false;
    }
    if (_pin.length < 4) {
      _errorText = 'PIN must be 4 digits';
      return false;
    }
    _errorText = null;
    return true;
  }
}