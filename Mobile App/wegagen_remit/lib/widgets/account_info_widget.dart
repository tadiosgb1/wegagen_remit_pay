import 'package:flutter/material.dart';
import '../models/account_info_response.dart';
import '../services/account_service.dart';

/// Reusable widget to display account information
/// Compatible with the new mobile-optimized backend response
class AccountInfoWidget extends StatefulWidget {
  final String accountNumber;
  final bool showBalance;
  final VoidCallback? onTap;

  const AccountInfoWidget({
    Key? key,
    required this.accountNumber,
    this.showBalance = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<AccountInfoWidget> createState() => _AccountInfoWidgetState();
}

class _AccountInfoWidgetState extends State<AccountInfoWidget> {
  final AccountService _accountService = AccountService();
  AccountInfoResponse? _accountInfo;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAccountInfo();
  }

  Future<void> _loadAccountInfo() async {
    if (widget.accountNumber.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _accountService.getAccountInfo(widget.accountNumber);
      
      setState(() {
        _accountInfo = response;
        _error = response.success ? null : response.message ?? response.error;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load account info';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_accountInfo?.success != true || _accountInfo?.account == null) {
      return _buildNotFoundState();
    }

    return _buildAccountDetails();
  }

  Widget _buildLoadingState() {
    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 16),
        Text(
          'Loading account ${widget.accountNumber}...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'Account ${widget.accountNumber}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _error ?? 'Unknown error',
          style: TextStyle(
            color: Colors.red[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _loadAccountInfo,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Retry', style: TextStyle(fontSize: 12)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildNotFoundState() {
    return Row(
      children: [
        Icon(Icons.account_circle_outlined, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.accountNumber,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'Account not found',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDetails() {
    final account = _accountInfo!.account!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Account holder and status
        Row(
          children: [
            _buildStatusIcon(account),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.accountHolderName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    account.accountNumber,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (account.isActive)
              Icon(
                Icons.verified,
                color: Colors.green[600],
                size: 20,
              ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Account type and status
        Row(
          children: [
            _buildInfoChip(account.accountTypeDescription),
            const SizedBox(width: 8),
            _buildStatusChip(account.statusDisplay, account.isActive),
          ],
        ),

        if (widget.showBalance && account.isActive) ...[
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          
          // Balance information
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    account.balance.formattedAvailable,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (account.balance.hasBlocked)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Blocked',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      account.balance.formattedBlocked,
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],

        // Show restrictions if any
        if (account.restrictions.hasRestrictions) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            children: account.restrictions.restrictionsList
                .map((restriction) => _buildWarningChip(restriction))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusIcon(AccountInfo account) {
    if (account.frozen) {
      return Icon(Icons.ac_unit, color: Colors.blue[600]);
    } else if (account.isActive) {
      return Icon(Icons.account_circle, color: Colors.green[600]);
    } else {
      return Icon(Icons.account_circle_outlined, color: Colors.grey[600]);
    }
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.blue[700],
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isActive) {
    final color = isActive ? Colors.green : Colors.orange;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[200]!),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color[700],
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildWarningChip(String warning) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Text(
        warning,
        style: TextStyle(
          color: Colors.red[700],
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Simple recipient selector widget
class RecipientSelectorWidget extends StatefulWidget {
  final Function(RecipientInfo) onRecipientSelected;
  final String? initialAccountNumber;

  const RecipientSelectorWidget({
    Key? key,
    required this.onRecipientSelected,
    this.initialAccountNumber,
  }) : super(key: key);

  @override
  State<RecipientSelectorWidget> createState() => _RecipientSelectorWidgetState();
}

class _RecipientSelectorWidgetState extends State<RecipientSelectorWidget> {
  final TextEditingController _accountController = TextEditingController();
  final AccountService _accountService = AccountService();
  bool _isValidating = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    if (widget.initialAccountNumber != null) {
      _accountController.text = widget.initialAccountNumber!;
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _validateRecipient() async {
    final accountNumber = _accountController.text.trim();
    
    if (accountNumber.isEmpty) {
      setState(() => _validationError = 'Please enter account number');
      return;
    }

    setState(() {
      _isValidating = true;
      _validationError = null;
    });

    try {
      final response = await _accountService.validateRecipient(accountNumber);
      
      if (response.success && response.valid && response.recipient != null) {
        widget.onRecipientSelected(response.recipient!);
        setState(() => _validationError = null);
      } else {
        setState(() => _validationError = response.message ?? 'Invalid account');
      }
    } catch (e) {
      setState(() => _validationError = 'Validation failed');
    } finally {
      setState(() => _isValidating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _accountController,
          decoration: InputDecoration(
            labelText: 'Recipient Account Number',
            hintText: 'Enter account number',
            prefixIcon: const Icon(Icons.account_balance),
            border: const OutlineInputBorder(),
            errorText: _validationError,
            suffixIcon: _isValidating
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    onPressed: _validateRecipient,
                    icon: const Icon(Icons.search),
                  ),
          ),
          keyboardType: TextInputType.number,
          onFieldSubmitted: (_) => _validateRecipient(),
        ),
      ],
    );
  }
}