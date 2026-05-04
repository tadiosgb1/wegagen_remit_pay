import 'environment.dart';

class UrlContainer {
  static String get baseUrl => Environment.apiUrl;

  // Authentication endpoints
  static String get login => '$baseUrl/users/login';
  static String get register => '$baseUrl/users';
  static String get logout => '$baseUrl/users/logout';
  static String get refreshToken => '$baseUrl/auth/refresh';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get resetPassword => '$baseUrl/auth/reset-password';
  static String get verifyEmail => '$baseUrl/auth/verify-email';
  static String get resendVerification => '$baseUrl/auth/resend-verification';
  static String get forgotPin => '$baseUrl/users/forgot-pin';
  static String get verifyOtp => '$baseUrl/users/verify-otp';
  static String get resetPin => '$baseUrl/users/reset-pin';

  // User endpoints
  static String get profile => '$baseUrl/user/profile';
  static String get updateProfile => '$baseUrl/user/profile';
  static String get changePassword => '$baseUrl/user/change-password';
  static String get uploadDocument => '$baseUrl/user/documents';
  static String get getDocuments => '$baseUrl/user/documents';

  // Transfer endpoints
  static String get createTransfer => '$baseUrl/transfers';
  static String get getTransfers => '$baseUrl/transfers';
  static String get getUserTransactions => '$baseUrl/transactions/me';
  static String getTransferById(String id) => '$baseUrl/transfers/$id';
  static String get cancelTransfer => '$baseUrl/transfers/cancel';
  static String get transferStatus => '$baseUrl/transfers/status';
  static String get accountInfo => '$baseUrl/internal-transfer/account-info';

  // Exchange rate endpoints
  static String get getExchangeRate => '$baseUrl/internal-transfer/rate';

  // Recipients endpoints
  static String get recipients => '$baseUrl/recipients';
  static String getRecipientById(String id) => '$baseUrl/recipients/$id';
  static String get deleteRecipient => '$baseUrl/recipients';

  // Payment endpoints
  static String get generateCaptureContext => '$baseUrl/payments/generate-capture-context';
  static String get processPayment => '$baseUrl/payments/process-payment';
  static String get paymentMethods => '$baseUrl/payments/methods';
  static String get paymentHistory => '$baseUrl/payments/history';

  // KYC endpoints
  static String get kycStatus => '$baseUrl/kyc/status';
  static String get submitKyc => '$baseUrl/kyc';
  static String get kycDocuments => '$baseUrl/kyc/documents';

  // Notifications endpoints
  static String get notifications => '$baseUrl/notifications';
  static String get markNotificationRead => '$baseUrl/notifications/read';

  // Support endpoints
  static String get supportTickets => '$baseUrl/support/tickets';
  static String get createSupportTicket => '$baseUrl/support/tickets';

  // Bank endpoints
  static String get banks => '$baseUrl/banks';
  static String get bankBranches => '$baseUrl/banks/branches';
  static String validateBankAccount(String bankCode) =>
      '$baseUrl/banks/$bankCode/validate';
}
