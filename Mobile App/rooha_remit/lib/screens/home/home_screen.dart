import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kyc_provider.dart';
import '../../providers/exchange_rate_provider.dart';
import '../../widgets/activity_tracker.dart';
import '../../widgets/kyc_status_card.dart';
import '../../models/kyc_data.dart';
import '../transfer/transfer_type_screen.dart';
import '../transfer/bank_selection_screen.dart';
import '../auth/login_screen.dart';
import '../transactions/transactions_screen.dart';
import '../exchange_rates_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/kyc_screen.dart';
import '../kyc/kyc_status_screen.dart';
import '../bonus_demo_screen.dart';
import '../../constants/colors.dart';

class HomeScreen extends StatefulWidget {
  final bool showAppBar;

  const HomeScreen({super.key, this.showAppBar = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExchangeRateProvider>(
        context,
        listen: false,
      ).loadExchangeRates();

      // Load fresh KYC status when home screen opens
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<KycProvider>(
        context,
        listen: false,
      ).loadKycStatus(authProvider: authProvider);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh KYC status if it's stale when screen becomes active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        Provider.of<KycProvider>(
          context,
          listen: false,
        ).refreshIfNeeded(authProvider: authProvider);
      }
    });
  }

  Future<void> _refreshHomeData() async {
    final kycProvider = Provider.of<KycProvider>(context, listen: false);
    final exchangeRateProvider =
        Provider.of<ExchangeRateProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await Future.wait([
      kycProvider.refreshKycStatus(authProvider: authProvider),
      exchangeRateProvider.loadExchangeRates(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text(
                'Rooha Remit',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'profile') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    } else if (value == 'logout') {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      await authProvider.logout();
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Text('Profile'),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Text('Settings'),
                    ),
                    const PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ],
                ),
              ],
            )
          : null,
      body: ActivityTracker(
        interactionType: 'home_screen',
        child: RefreshIndicator(
          onRefresh: _refreshHomeData,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 50, 24, 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          final user = authProvider.user;
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white.withOpacity(0.25),
                                child: Text(
                                  user != null && user.firstName.isNotEmpty
                                      ? user.firstName[0].toUpperCase()
                                      : 'W',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Good morning,',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      user?.firstName ?? 'User',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // KYC Status Card - Using KycProvider for real-time updates
                Consumer<KycProvider>(
                  builder: (context, kycProvider, child) {
                    final kycStatus = kycProvider.kycStatus;
                    final isKycVerified = kycStatus == KycStatus.approved;
                    final isLoading = kycProvider.isLoading;
                    final isPeriodicChecking =
                        kycProvider.isPeriodicCheckingActive;

                    // DEBUG: Print the current KYC status
                    print(
                        '🏠 HOME SCREEN - KYC Status: $kycStatus, Verified: $isKycVerified');
                    print(
                        '🏠 HOME SCREEN - Debug: Status enum value: ${kycStatus.toString()}');

                    return GestureDetector(
                      onTap: isLoading
                          ? null
                          : () {
                              // Navigate based on KYC verification status
                              if (kycStatus == KycStatus.approved) {
                                // Verified - show KYC status screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const KycStatusScreen(),
                                  ),
                                );
                              } else if (kycStatus == KycStatus.underReview ||
                                  kycStatus == KycStatus.inProgress) {
                                // Under review or in progress - show status screen (NOT form)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const KycStatusScreen(),
                                  ),
                                );
                              } else {
                                // Not started - go to KYC submission form
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const KycScreen(),
                                  ),
                                );
                              }
                            },
                      child: Stack(
                        children: [
                          KycStatusCard(
                            kycStatus: kycStatus,
                            isKycVerified: isKycVerified,
                          ),
                          // Show loading overlay when refreshing
                          if (isLoading)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFF37021),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Show active monitoring indicator for pending KYC
                          if (isPeriodicChecking &&
                              (kycStatus == KycStatus.underReview ||
                                  kycStatus == KycStatus.inProgress))
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50)
                                      .withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Auto-checking',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // Services Grid - Fixed Overflow
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.15, // Increased to prevent overflow
                    children: [
                      _buildServiceCard(
                        'Wegagen Bank',
                        'Transfer to Wegagen Account',
                        Icons.account_balance,
                        const Color(0xFF2E7D7D),
                        () => _navigateToTransfer('wegagen_bank'),
                      ),
                      _buildServiceCard(
                        'Other Banks',
                        'All Ethiopian Banks',
                        Icons.account_balance_outlined,
                        const Color(0xFFF37021),
                        () => _navigateToTransfer('other_banks'),
                      ),
                      _buildServiceCard(
                        'Cash Pickup',
                        'Agent Locations',
                        Icons.money,
                        const Color(0xFF1976D2),
                        () => _navigateToTransfer('cash_pickup'),
                      ),
                      _buildServiceCard(
                        'Mobile Wallet',
                        'eBirr & TeleBirr',
                        Icons.phone_android,
                        const Color(0xFF8E24AA),
                        () => _navigateToTransfer('mobile_wallet'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Quick Access
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Access',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildQuickAccessItem(
                              Icons.history,
                              'Transaction History',
                              'View all transfers',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TransactionsScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1, indent: 20, endIndent: 20),
                            _buildQuickAccessItem(
                              Icons.swap_horiz,
                              'Exchange Rates',
                              'Live currency rates',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ExchangeRatesScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1, indent: 20, endIndent: 20),
                            _buildQuickAccessItem(
                              Icons.card_giftcard,
                              'Bonus Calculator',
                              'See 10% ETB bonus demo',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const BonusDemoScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 12),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF37021).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFFF37021)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  void _navigateToTransfer(String type) {
    if (type == 'other_banks') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BankSelectionScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransferTypeScreen(transferType: type),
        ),
      );
    }
  }
}
