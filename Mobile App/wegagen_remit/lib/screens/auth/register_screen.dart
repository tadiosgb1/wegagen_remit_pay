import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/pin_input_field.dart';
import 'kyc_screen.dart';
import '../../constants/colors.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = PinInputController();
  final _confirmPinController = PinInputController();

  bool _obscurePin = true;
  bool _obscureConfirmPin = true;
  bool _acceptTerms = false;
  String? _pinError;
  String? _confirmPinError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // ... (your existing validation logic remains unchanged)
    bool isValid = true;

    if (!_pinController.validate()) {
      setState(() => _pinError = _pinController.errorText);
      _pinController.shake();
      isValid = false;
    } else {
      setState(() => _pinError = null);
    }

    if (!_confirmPinController.validate()) {
      setState(() => _confirmPinError = _confirmPinController.errorText);
      _confirmPinController.shake();
      isValid = false;
    } else if (_pinController.pin != _confirmPinController.pin) {
      setState(() => _confirmPinError = 'PINs do not match');
      _confirmPinController.shake();
      isValid = false;
    } else {
      setState(() => _confirmPinError = null);
    }

    if (isValid && _formKey.currentState!.validate() && _acceptTerms) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        pin: _pinController.pin,
        confirmPin: _confirmPinController.pin,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const KycScreen()),
        );
      }
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
                AppColors.primary,
                AppColors.primaryLight,
                Colors.white,
              ],
            stops: [0.0, 0.25, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Decorative Logo with Glow
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.35),
                        blurRadius: 35,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 95,
                    height: 95,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.account_balance,
                      size: 85,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // Title
                const Text(
                  "Create Your Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Join thousands of happy customers",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 45),

                // Main Form Card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name Fields
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernTextField(
                                controller: _firstNameController,
                                label: "First Name",
                                icon: Icons.person_outline,
                                validator: (value) =>
                                    value?.isEmpty ?? true ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildModernTextField(
                                controller: _lastNameController,
                                label: "Last Name",
                                icon: Icons.person_outline,
                                validator: (value) =>
                                    value?.isEmpty ?? true ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _buildModernTextField(
                          controller: _emailController,
                          label: "Email Address",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Please enter email';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Invalid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        _buildModernTextField(
                          controller: _phoneController,
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),

                        const SizedBox(height: 32),

                        // PIN Section
                        const Text(
                          "Create 4-Digit PIN",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 14),
                        PinInputField(
                          key: _pinController.key,
                          length: 4,
                          obscureText: _obscurePin,
                          errorText: _pinError,
                          onChanged: (pin) {
                            _pinController.updatePin(pin);
                            if (_pinError != null)
                              setState(() => _pinError = null);
                          },
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          "Confirm PIN",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 14),
                        PinInputField(
                          key: _confirmPinController.key,
                          length: 4,
                          obscureText: _obscureConfirmPin,
                          errorText: _confirmPinError,
                          onChanged: (pin) {
                            _confirmPinController.updatePin(pin);
                            if (_confirmPinError != null)
                              setState(() => _confirmPinError = null);
                          },
                        ),

                        const SizedBox(height: 12),

                        // Toggle Visibility
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscurePin = !_obscurePin;
                                _obscureConfirmPin = !_obscureConfirmPin;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _obscurePin
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _obscurePin ? "Show" : "Hide",
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Terms
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) =>
                                  setState(() => _acceptTerms = value ?? false),
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            const Expanded(
                              child: Text(
                                "I agree to the Terms & Conditions and Privacy Policy",
                                style: TextStyle(fontSize: 14.5, height: 1.4),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Create Account Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return ElevatedButton(
                              onPressed:
                                  authProvider.isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textOnPrimary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 0,
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5),
                                    )
                                  : const Text(
                                      "Create Account",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable modern text field
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
      validator: validator,
    );
  }
}
