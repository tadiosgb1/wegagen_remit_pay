import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'enter_pin_screen.dart';
import 'create_account_screen.dart';
import '../../constants/colors.dart';

class LoginScreen extends StatefulWidget {
  final String? message;

  const LoginScreen({super.key, this.message});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isCheckingEmail = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _continueToPin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final authProvider = context.read<AuthProvider>();

    setState(() => _isCheckingEmail = true);

    try {
      final emailExists = await authProvider.checkEmailExists(email);

      if (!mounted) return;

      if (!emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No account found. Please create an account first.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
        setState(() => _isCheckingEmail = false);
        return;
      }

      setState(() => _isCheckingEmail = false);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EnterPinScreen(email: email),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString()}',
            style: const TextStyle(fontSize: 15),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      setState(() => _isCheckingEmail = false);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
                      Colors.white,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Single Unified Master White Card Container
                          Container(
                            padding: const EdgeInsets.all(28.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 35,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Logo Inside Card (Home icon removed)
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.15),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const CircleAvatar(
                                      radius: 44,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: AssetImage('assets/images/logo.png'),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 22),

                                // Welcome Title Inside Card
                                const Text(
                                  "Welcome Back",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Sign in to access your account",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade600,
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // Form Fields
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        style: const TextStyle(fontSize: 16),
                                        decoration: InputDecoration(
                                          labelText: "Email Address",
                                          labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        ),
                                        validator: _validateEmail,
                                      ),

                                      const SizedBox(height: 24),

                                      // Continue Button
                                      ElevatedButton(
                                        onPressed: _isCheckingEmail ? null : _continueToPin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          elevation: 2,
                                          shadowColor: AppColors.primary.withValues(alpha: 0.4),
                                          disabledBackgroundColor: Colors.grey.shade300,
                                        ),
                                        child: _isCheckingEmail
                                            ? const SizedBox(
                                                height: 22,
                                                width: 22,
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : const Text(
                                                "Continue",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                Divider(color: Colors.grey.shade200, thickness: 1),

                                const SizedBox(height: 16),

                                // Sign Up Row Inside Card
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => const CreateAccountScreen()),
                                        );
                                      },
                                      child: const Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}