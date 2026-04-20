import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/kyc_screen.dart';
import '../widgets/session_timeout_wrapper.dart';
import 'home/home_screen.dart';
import 'transactions/transactions_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(showAppBar: false),
    const TransactionsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print('DEBUG: MainNavigationScreen - isAuthenticated: ${authProvider.isAuthenticated}');
        print('DEBUG: MainNavigationScreen - isLoading: ${authProvider.isLoading}');
        print('DEBUG: MainNavigationScreen - user: ${authProvider.user}');
        print('DEBUG: MainNavigationScreen - needsKycVerification: ${authProvider.user?.needsKycVerification ?? 'null user'}');
        
        // If not authenticated and not loading, redirect to login
        if (!authProvider.isAuthenticated && !authProvider.isLoading) {
          print('DEBUG: MainNavigationScreen - Redirecting to login (not authenticated and not loading)');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show loading while authentication is in progress
        if (authProvider.isLoading) {
          print('DEBUG: MainNavigationScreen - Showing loading screen');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if user needs KYC verification
        if (authProvider.user != null && authProvider.user!.needsKycVerification) {
          print('DEBUG: MainNavigationScreen - Redirecting to KYC screen');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const KycScreen()),
            );
          });
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Checking KYC status...'),
                ],
              ),
            ),
          );
        }

        print('DEBUG: MainNavigationScreen - Showing main navigation');
        return SessionTimeoutWrapper(
          onTimeout: () => _handleSessionTimeout(authProvider),
          onWarning: () => _showSessionWarning(),
          child: Scaffold(
            body: _screens[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFFF37021),
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long),
                  label: 'Transactions',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outlined),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSessionTimeout(AuthProvider authProvider) async {
    // Log out the user
    await authProvider.logout();
    
    if (mounted) {
      // Show timeout message and redirect to login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(
            message: 'Your session has expired. Please log in again.',
          ),
        ),
        (route) => false,
      );
    }
  }

  void _showSessionWarning() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('Session Warning'),
          ],
        ),
        content: const Text(
          'Your session will expire in 30 seconds due to inactivity. '
          'Tap anywhere to continue your session.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Timer is automatically reset by user interaction
            },
            child: const Text('Continue Session'),
          ),
        ],
      ),
    );
  }
}