import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'providers/kyc_provider.dart';
import 'providers/exchange_rate_provider.dart';
import 'providers/bonus_provider.dart';
import 'services/api_service.dart';
import 'config/environment.dart';
import 'config/url_container.dart';
import 'constants/theme.dart';
import 'constants/colors.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kDebugMode) print('🚀 Starting app initialization...');
    if (kDebugMode) print('🌐 API URL: ${Environment.apiUrl}');

    await ApiService().initialize();
    if (kDebugMode) print('✅ API service initialized successfully');

    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    if (kDebugMode) print('❌ App initialization failed: $e');
    runApp(const ProviderScope(child: MyApp()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
        provider.ChangeNotifierProvider(create: (_) => KycProvider()),
        provider.ChangeNotifierProvider(create: (_) => ExchangeRateProvider()),
        provider.ChangeNotifierProvider(create: (_) => BonusProvider()),
      ],
      child: MaterialApp(
        title: 'Wegagen Remit',
        theme: AppTheme.theme,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

enum AuthStatus { checking, onboarding, login, home }

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  AuthStatus _status = AuthStatus.checking;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('onboarding_completed') ?? false;

      if (!hasSeenOnboarding) {
        setState(() => _status = AuthStatus.onboarding);
        return;
      }

      // Check authentication differently for web vs mobile
      // Important: Use direct API calls here, NOT AuthProvider to avoid triggering error states
      bool isAuthenticated = false;

      if (kIsWeb) {
        // For web, check if we're logged in via HTTP-only cookie
        // by attempting to access a protected endpoint
        try {
          await ApiService().get(UrlContainer.profile);
          isAuthenticated = true;
          if (kDebugMode) print('✅ User authenticated via HTTP-only cookie');
        } catch (e) {
          // Expected behavior when user is not logged in - don't show error
          isAuthenticated = false;
          await prefs.setBool('is_logged_in', false);
          if (kDebugMode)
            print('ℹ️ User not authenticated (expected during startup)');
        }
      } else {
        // For mobile, check both token and login state
        final token = prefs.getString('auth_token');
        final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

        if (token != null || isLoggedIn) {
          try {
            await ApiService().get(UrlContainer.profile);
            isAuthenticated = true;
            if (kDebugMode) print('✅ User authenticated via stored token');
          } catch (e) {
            // Expected behavior when token is invalid - clear and continue silently
            await prefs.remove('auth_token');
            await prefs.setBool('is_logged_in', false);
            await ApiService().clearCookies();
            isAuthenticated = false;
            if (kDebugMode)
              print('ℹ️ Invalid token cleared (expected during startup)');
          }
        } else {
          if (kDebugMode) print('ℹ️ No stored authentication found');
        }
      }

      setState(
          () => _status = isAuthenticated ? AuthStatus.home : AuthStatus.login);
    } catch (e) {
      if (kDebugMode) print('❌ Error in _initializeApp: $e');
      setState(() => _status = AuthStatus.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case AuthStatus.checking:
        return const SplashScreen();
      case AuthStatus.onboarding:
        return const OnboardingScreen();
      case AuthStatus.login:
        return const LoginScreen();
      case AuthStatus.home:
        return const MainNavigationScreen();
    }
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glowing Logo Container
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.6),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 80,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.account_balance,
                                size: 110,
                                color: AppColors.primary,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 50),

              // App Name with Animation
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: const Text(
                      'Wegagen Remit',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: const Text(
                      'Send Money Worldwide',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 80),

              // Loading Indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
