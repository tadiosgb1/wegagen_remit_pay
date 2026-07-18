import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../constants/colors.dart';
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
  String _pin = '';
  String _confirmPin = '';
  bool _isCreatingPin = true; // true for create PIN, false for confirm PIN
  bool _isLoading = false;

  final List<bool> _filledDots = [false, false, false, false];

  void _onNumberPressed(String number) {
    if (_isCreatingPin && _pin.length < 4) {
      setState(() {
        _pin += number;
        _filledDots[_pin.length - 1] = true;
      });

      if (_pin.length == 4) {
        // Move to confirm PIN step
        setState(() {
          _isCreatingPin = false;
          _filledDots.fillRange(0, 4, false);
        });
      }
    } else if (!_isCreatingPin && _confirmPin.length < 4) {
      setState(() {
        _confirmPin += number;
        _filledDots[_confirmPin.length - 1] = true;
      });

      if (_confirmPin.length == 4) {
        _validateAndCreateAccount();
      }
    }
  }

  void _onDeletePressed() {
    if (_isCreatingPin && _pin.isNotEmpty) {
      setState(() {
        _filledDots[_pin.length - 1] = false;
        _pin = _pin.substring(0, _pin.length - 1);
      });
    } else if (!_isCreatingPin && _confirmPin.isNotEmpty) {
      setState(() {
        _filledDots[_confirmPin.length - 1] = false;
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      });
    }
  }

  void _goBackToCreatePin() {
    setState(() {
      _isCreatingPin = true;
      _confirmPin = '';
      _filledDots.fillRange(0, 4, false);
      // Show current PIN progress
      for (int i = 0; i < _pin.length; i++) {
        _filledDots[i] = true;
      }
    });
  }

  Future<void> _validateAndCreateAccount() async {
    if (_pin != _confirmPin) {
      // Show error and reset confirm PIN
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINs do not match. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _confirmPin = '';
        _filledDots.fillRange(0, 4, false);
      });
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      firstName: widget.firstName,
      lastName: widget.lastName,
      email: widget.email,
      phoneNumber: widget.phoneNumber,
      pin: _pin,
      confirmPin: _confirmPin,
      referralCode: widget.referralCode,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Clear auth state to ensure a clean session for the next login
      await authProvider.logout();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Registration successful! Please login and complete your KYC.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }

      // Navigate to LoginScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(
            message: 'Account created successfully! Please login to continue.',
          ),
        ),
        (route) => false,
      );
    } else {
      // Show error and reset both PINs
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _pin = '';
        _confirmPin = '';
        _isCreatingPin = true;
        _filledDots.fillRange(0, 4, false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.secondary,
              AppColors.secondary,
              AppColors.secondary,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Back Button (only show when confirming PIN)
                    if (!_isCreatingPin)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: _goBackToCreatePin,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 48), // Same height as back button

                    const SizedBox(height: 10),

                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange,
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.account_balance,
                              size: 100,
                              color: Color(0xFFF37021),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // App Name
                    const Text(
                      "Wegagen  Remit",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      _isCreatingPin ? "Create Your PIN" : "Confirm Your PIN",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      _isCreatingPin
                          ? "Choose a 4-digit PIN for secure access"
                          : "Enter the same PIN again to confirm",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // PIN Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _filledDots[index]
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.3),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 12),

                    // PIN Step Indicator
                    Text(
                      _isCreatingPin
                          ? "Step 1 of 2: Create PIN"
                          : "Step 2 of 2: Confirm PIN",
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Number Pad
                    _buildNumberPad(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Row 1: 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
            ],
          ),

          const SizedBox(height: 20),

          // Row 2: 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
            ],
          ),

          const SizedBox(height: 20),

          // Row 3: 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
            ],
          ),

          const SizedBox(height: 20),

          // Row 4: empty, 0, delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 70), // Empty space
              _buildNumberButton('0'),
              _buildDeleteButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _onNumberPressed(number),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _onDeletePressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
