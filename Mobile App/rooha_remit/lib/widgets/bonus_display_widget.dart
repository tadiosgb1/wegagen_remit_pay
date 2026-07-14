import 'package:flutter/material.dart';
import '../services/bonus_service.dart';

/// Widget to display bonus information - Always shows bonus in ETB only
/// Shows sender amount in their currency, but bonus calculations only in ETB
class BonusDisplayWidget extends StatelessWidget {
  final BonusCalculation? bonusCalculation;
  final bool showDetailed;
  final bool showAsCard;
  
  const BonusDisplayWidget({
    super.key,
    required this.bonusCalculation,
    this.showDetailed = true,
    this.showAsCard = true,
  });

  @override
  Widget build(BuildContext context) {
    // Only show if bonus applies (sender not using ETB)
    if (bonusCalculation == null || !bonusCalculation!.hasBonusApplicable) {
      return const SizedBox.shrink();
    }

    if (showAsCard) {
      return _buildBonusCard(context);
    } else {
      return _buildSimpleBonus(context);
    }
  }
  
Widget _buildBonusCard(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.green.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with bonus icon
        Row(
          children: [
            const Icon(
              Icons.card_giftcard,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              '🎁 10% Bonus in Ethiopian Birr!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        if (showDetailed) ...[
          const SizedBox(height: 12),
          const Divider(color: Colors.white70, thickness: 1),
          const SizedBox(height: 12),

          _buildAmountRow(
            'You Send:',
            bonusCalculation!.formattedSenderAmount,
            Colors.white70,
          ),
          const SizedBox(height: 8),

          _buildAmountRow(
            'Recipient Gets (Base):',
            bonusCalculation!.formattedBaseETB,
            Colors.white70,
          ),
          const SizedBox(height: 8),

          _buildAmountRow(
            'Bonus (10% in ETB):',
            bonusCalculation!.formattedBonusETB,
            Colors.yellow.shade300,
            isBonus: true,
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildAmountRow(
              'Total Recipient Gets:',
              bonusCalculation!.formattedTotalETB,
              Colors.white,
              isTotal: true,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            bonusCalculation!.formattedExchangeRate,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            'Bonus: ${bonusCalculation!.formattedBonusETB}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    ),
  );
}
  
  Widget _buildSimpleBonus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.card_giftcard,
            color: Colors.green.shade600,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${bonusCalculation!.formattedBonusETB} Bonus',
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAmountRow(
    String label,
    String amount,
    Color textColor, {
    bool isBonus = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            if (isBonus) ...[
              Icon(
                Icons.add_circle,
                color: Colors.yellow.shade300,
                size: 16,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              amount,
              style: TextStyle(
                color: textColor,
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compact bonus display for smaller spaces (like in lists)
class CompactBonusDisplay extends StatelessWidget {
  final BonusCalculation? bonusCalculation;
  
  const CompactBonusDisplay({
    super.key,
    required this.bonusCalculation,
  });

  @override
  Widget build(BuildContext context) {
    if (bonusCalculation == null || !bonusCalculation!.hasBonusApplicable) {
      return const SizedBox.shrink();
    }

    return BonusDisplayWidget(
      bonusCalculation: bonusCalculation,
      showDetailed: false,
      showAsCard: false,
    );
  }
}

/// Summary row for showing bonus amounts in payment summaries
class BonusSummaryRows extends StatelessWidget {
  final BonusCalculation? bonusCalculation;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  
  const BonusSummaryRows({
    super.key,
    required this.bonusCalculation,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (bonusCalculation == null || !bonusCalculation!.hasBonusApplicable) {
      return const SizedBox.shrink();
    }

    final defaultLabelStyle = labelStyle ?? const TextStyle(
      fontSize: 14,
      color: Colors.grey,
    );
    
    final defaultValueStyle = valueStyle ?? const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    return Column(
      children: [
        _buildSummaryRow(
          'Base Amount (ETB):',
          bonusCalculation!.formattedBaseETB,
          defaultLabelStyle,
          defaultValueStyle,
        ),
        const SizedBox(height: 4),
        _buildSummaryRow(
          'Bonus (10% ETB):',
          bonusCalculation!.formattedBonusETB,
          defaultLabelStyle,
          defaultValueStyle.copyWith(color: Colors.green.shade600),
        ),
        const SizedBox(height: 4),
        _buildSummaryRow(
          'Total (ETB):',
          bonusCalculation!.formattedTotalETB,
          defaultLabelStyle.copyWith(fontWeight: FontWeight.w600),
          defaultValueStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  
  Widget _buildSummaryRow(
    String label,
    String value,
    TextStyle labelStyle,
    TextStyle valueStyle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}