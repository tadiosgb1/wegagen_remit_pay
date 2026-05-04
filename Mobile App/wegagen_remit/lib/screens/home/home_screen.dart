import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exchange_rate_provider.dart';
import '../../widgets/activity_tracker.dart';
import '../../models/user.dart';
import '../transfer/transfer_type_screen.dart';
import '../transfer/bank_selection_screen.dart';
import '../auth/login_screen.dart';
import '../transactions/transactions_screen.dart';
import '../exchange_rates_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/kyc_screen.dart';
import '../kyc/kyc_status_screen.dart';
import '../payment/payment_screen.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Wegagen Remit'),
              backgroundColor: const Color(0xFFF37021),
              foregroundColor: Colors.white,
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'profile') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    } else if (value == 'logout') {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      await authProvider.logout();
                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'profile',
                      child: Text('Profile'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'settings',
                      child: Text('Settings'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ],
            )
          : null,
      body: ActivityTracker(
        interactionType: 'home_screen',
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Wegagen Brand Colors
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF37021), Color(0xFFE55A00)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info Row
                    Row(
                      children: [
                        // User Avatar
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              final user = authProvider.user;
                              final initials =
                                  user != null &&
                                      user.firstName.isNotEmpty &&
                                      user.lastName.isNotEmpty
                                  ? '${user.firstName[0].toUpperCase()}${user.lastName[0].toUpperCase()}'
                                  : 'TG';
                              return Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Welcome Text
                        Expanded(
                          child: Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              final user = authProvider.user;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'WELCOME BACK',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user != null
                                        ? '${user.firstName} ${user.lastName}'
                                        : 'TESFAY G.',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        // Notification Bell
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Stack(
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Promotional Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          // Percentage Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.percent,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Banner Text
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '10% Bonus on All Transfers',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Send money and get 10% cashback',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Arrow Icon
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // KYC Information Banner
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.user;
                  if (user != null) {
                    return _buildKycBanner(user);
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Services Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildModernServiceCard(
                      'Transfer',
                      'Wegagen Bank Account',
                      Icons.account_balance,
                      const Color(0xFF2E7D7D),
                      () => _navigateToTransfer('wegagen_bank'),
                    ),
                    _buildModernServiceCard(
                      'Other Banks',
                      'Ethiopian Banks',
                      Icons.account_balance_outlined,
                      const Color(0xFFF37021),
                      () => _navigateToTransfer('other_banks'),
                    ),
                    _buildModernServiceCard(
                      'Cash Pickup',
                      'Pickup Points',
                      Icons.send,
                      const Color(0xFF2E7D7D),
                      () => _navigateToTransfer('cash_pickup'),
                    ),
                    _buildModernServiceCard(
                      'Wegagen E-birr',
                      'Mobile Wallet',
                      Icons.phone_android,
                      const Color(0xFF999999),
                      () => _navigateToTransfer('wegagen_ebirr'),
                    ),
                  ],
                ),
              ),

              // Quick Access Section
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
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildQuickAccessItem(
                            Icons.history,
                            'Transaction History',
                            'View all your transfers',
                            () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TransactionsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 24),
                          _buildQuickAccessItem(
                            Icons.payment,
                            'Test Payment (CyberSource)',
                            'Test secure card payment',
                            () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const PaymentScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 24),
                          _buildQuickAccessItem(
                            Icons.receipt_long,
                            'Track Transfer',
                            'Check transfer status',
                            () {},
                          ),
                          const Divider(height: 24),
                          _buildQuickAccessItem(
                            Icons.support_agent,
                            'Customer Support',
                            'Get help and support',
                            () {},
                          ),
                          const Divider(height: 24),
                          _buildQuickAccessItem(
                            Icons.settings,
                            'Settings',
                            'Manage your account',
                            () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
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

              const SizedBox(height: 24),

              // Exchange Rates Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Today\'s Exchange Rates',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ExchangeRatesScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Color(0xFFF37021),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Consumer<ExchangeRateProvider>(
                      builder: (context, exchangeProvider, child) {
                        if (exchangeProvider.isLoading) {
                          return Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFF37021),
                              ),
                            ),
                          );
                        }

                        if (exchangeProvider.error != null) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade400,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Failed to load exchange rates',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: exchangeProvider.exchangeRates.entries
                                .take(4)
                                .map((entry) {
                                  final rate = entry.value;
                                  final isLast =
                                      exchangeProvider.exchangeRates.entries
                                          .toList()
                                          .indexOf(entry) ==
                                      (exchangeProvider
                                                  .exchangeRates
                                                  .entries
                                                  .length >
                                              4
                                          ? 3
                                          : exchangeProvider
                                                    .exchangeRates
                                                    .entries
                                                    .length -
                                                1);

                                  return Column(
                                    children: [
                                      _buildExchangeRateItem(
                                        rate.fromCurrency,
                                        rate.rate,
                                      ),
                                      if (!isLast) const Divider(height: 24),
                                    ],
                                  );
                                })
                                .toList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernServiceCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),

            const SizedBox(height: 16),

            // Title and Subtitle
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF37021).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFFF37021)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildExchangeRateItem(String currency, double rate) {
    return Consumer<ExchangeRateProvider>(
      builder: (context, exchangeProvider, child) {
        final exchangeRate = exchangeProvider.getExchangeRate(currency);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D7D).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currency,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D7D),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '1 $currency',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (exchangeRate != null)
                  Text(
                    '${exchangeRate.buyingRate.toStringAsFixed(2)} ETB',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF37021),
                    ),
                  )
                else
                  Text(
                    '${rate.toStringAsFixed(2)} ETB',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF37021),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildKycBanner(User user) {
    Color bannerColor;
    IconData bannerIcon;
    String title;
    String description;
    String actionText;
    VoidCallback? onTap;

    // Determine KYC status from user data
    if (user.kyc == null) {
      // No KYC data - not started
      bannerColor = Colors.blue;
      bannerIcon = Icons.info_outline;
      title = 'Complete Your KYC Verification';
      description =
          'KYC (Know Your Customer) verification is required for secure money transfers. It helps us verify your identity and comply with financial regulations.';
      actionText = 'Start KYC';
      onTap = () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const KycScreen()));
      };
    } else if (user.kyc!.verified) {
      // KYC verified - show status screen
      bannerColor = Colors.green;
      bannerIcon = Icons.check_circle_outline;
      title = 'KYC Verification Complete';
      description =
          'Your identity has been successfully verified. You can now enjoy full access to all transfer services with higher limits.';
      actionText = 'View Details';
      onTap = () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const KycStatusScreen()),
        );
      };
    } else {
      // KYC submitted but not verified - show status screen
      bannerColor = Colors.amber;
      bannerIcon = Icons.hourglass_empty;
      title = 'KYC Under Review';
      description =
          'Your KYC documents are being reviewed by our team. This usually takes 1-2 business days. You\'ll be notified once verification is complete.';
      actionText = 'View Status';
      onTap = () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const KycStatusScreen()),
        );
      };
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bannerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(bannerIcon, color: bannerColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: bannerColor.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bannerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToTransfer(String type) {
    if (type == 'other_banks') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const BankSelectionScreen()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TransferTypeScreen(transferType: type),
        ),
      );
    }
  }
}
