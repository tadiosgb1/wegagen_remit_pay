import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final String? redirectMessage;

  const AuthGuard({
    super.key,
    required this.child,
    this.redirectMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => LoginScreen(
                  message: redirectMessage ?? 'Please login to continue',
                ),
              ),
            );
          });
          
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF37021),
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}