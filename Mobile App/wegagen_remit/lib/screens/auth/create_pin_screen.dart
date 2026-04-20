import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/pin_input_field.dart';
import 'login_screen.dart';

class CreatePinScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? referralCode;

  const CreatePinScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.referralCode,
  });

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final _pinController = PinInputController();
  final _confirmPinController = PinInputController();
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  Future<void> _createAccount() async {
    // Validate PINs
    if (!_validatePins()) {
      setState(() {}); // Trigger rebuild to show PIN errors
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    print('DEBUG: Starting registration process...');
    
    final success = await authProvider.register(
      firstName: widget.firstName,
      lastName: widget.lastName,
      email: widget.email,
      phoneNumber: widget.phoneNumber,
      pin: _pinController.pin,
      confirmPin: _confirmPinController.pin,
      referralCode: widget.referralCode,
    );

    print('DEBUG: Registration success: $success');
    print('DEBUG: Auth provider authenticated: ${authProvider.isAuthenticated}');
    print('DEBUG: Auth provider user: ${authProvider.user}');
    print('DEBUG: Auth provider error: ${authProvider.error}');

    if (success && mounted) {
      // Clear the authentication state after successful registration
      await authProvider.logout();
      
      print('DEBUG: Navigating to LoginScreen after successful registration...');
      
      // Show success message and navigate to login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(
            message: 'Account created successfully! Please login to continue.',
          ),
        ),
        (route) => false, // Remove all previous routes
      );
    } else if (mounted && authProvider.error != null) {
      print('DEBUG: Registration failed with error: ${authProvider.error}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${authProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validatePins() {
    bool isValid = true;
    
    // Validate PIN
    if (!_pinController.validate()) {
      isValid = false;
    }
    
    // Validate confirm PIN
    if (_confirmPinController.pin.isEmpty) {
      _confirmPinController.setError('Please confirm your PIN');
      isValid = false;
    } else if (_confirmPinController.pin != _pinController.pin) {
      _confirmPinController.setError('PINs do not match');
      isValid = false;
    } else {
      _confirmPinController.setError(null);
    }
    
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF37021),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.account_balance,
                            color: Colors.white,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Header
              const Text(
                'Create Your PIN',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Create a secure 4-digit PIN to protect your account',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // PIN Input Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create your 4-digit PIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PinInputField(
                    key: _pinController.key,
                    length: 4,
                    obscureText: _obscurePin,
                    errorText: _pinController.errorText,
                    onChanged: (pin) {
                      _pinController.updatePin(pin);
                    },
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Confirm your 4-digit PIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PinInputField(
                    key: _confirmPinController.key,
                    length: 4,
                    obscureText: _obscureConfirmPin,
                    errorText: _confirmPinController.errorText,
                    onChanged: (pin) {
                      _confirmPinController.updatePin(pin);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _obscurePin ? 'Show PIN' : 'Hide PIN',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePin = !_obscurePin;
                            _obscureConfirmPin = !_obscureConfirmPin;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF37021).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _obscurePin ? Icons.visibility : Icons.visibility_off,
                            size: 18,
                            color: const Color(0xFFF37021),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Create Account Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.error != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(authProvider.error!),
                          backgroundColor: Colors.red,
                        ),
                      );
                      authProvider.clearError();
                    });
                  }

                  return ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF37021),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}