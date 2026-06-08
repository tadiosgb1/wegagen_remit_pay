import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'providers/kyc_provider.dart';
import 'providers/exchange_rate_provider.dart';
import 'services/api_service.dart';
import 'config/environment.dart';
import 'config/url_container.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🚀 Starting app initialization...');
    print('🌐 API URL: ${Environment.apiUrl}');
    
    await ApiService().initialize();
    print('✅ API service initialized successfully');
    
    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    print('❌ App initialization failed: $e');
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
      ],
      child: MaterialApp(
        title: 'Wegagen Remit',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF37021)),
          useMaterial3: true,
          fontFamily: 'Poppins', // Add this if you have Poppins font
        ),
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
      final token = prefs.getString('auth_token');

      if (!hasSeenOnboarding) {
        setState(() => _status = AuthStatus.onboarding);
        return;
      }

      if (token == null) {
        setState(() => _status = AuthStatus.login);
        return;
      }

      try {
        await ApiService().get(UrlContainer.profile);
        setState(() => _status = AuthStatus.home);
      } catch (e) {
        await prefs.remove('auth_token');
        setState(() => _status = AuthStatus.login);
      }
    } catch (e) {
      print('❌ Error in _initializeApp: $e');
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

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF37021),
              Color(0xFFFF8A4D),
              Color(0xFFFFB07A),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
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
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              blurRadius: 80,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 130,
                          height: 130,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.account_balance,
                              size: 110,
                              color: Color(0xFFF37021),
                            );
                          },
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