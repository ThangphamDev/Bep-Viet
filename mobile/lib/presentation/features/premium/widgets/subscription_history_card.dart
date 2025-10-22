import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';

class SubscriptionHistoryCard extends StatelessWidget {
  final String planName;
  final String date;
  final int amount;
  final String status;
  final bool isActive;

  const SubscriptionHistoryCard({
    super.key,
    required this.planName,
    required this.date,
    required this.amount,
    required this.status,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          // Status Indicator
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.successColor : AppTheme.secondaryGray,
              borderRadius: BorderRadius.circular(AppConfig.smallPadding / 2),
            ),
          ),
          const SizedBox(width: AppConfig.defaultPadding),

          // Plan Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConfig.smallPadding / 2),
                Text(date, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),

          // Amount and Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount == 0 ? 'Miễn phí' : '${amount.toStringAsFixed(0)}đ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppTheme.primaryGreen
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppConfig.smallPadding / 2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConfig.smallPadding,
                  vertical: AppConfig.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.secondaryGray.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConfig.smallPadding),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isActive
                        ? AppTheme.successColor
                        : AppTheme.secondaryGray,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
