import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';

// Generic interface for subscription plan display
abstract class ISubscriptionPlan {
  String get id;
  String get name;
  int get price;
  String get duration;
  List<String> get features;
  bool get isPopular;
}

class SubscriptionPlanCard extends StatelessWidget {
  final ISubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback? onSelect;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(AppConfig.largePadding - 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppConfig.defaultPadding + 4),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryGreen.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppTheme.primaryGreen
                                      : AppTheme.textPrimary,
                                ),
                          ),
                          if (plan.isPopular) ...[
                            const SizedBox(width: AppConfig.smallPadding),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConfig.smallPadding,
                                vertical: AppConfig.smallPadding / 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(
                                  AppConfig.smallPadding,
                                ),
                              ),
                              child: const Text(
                                'Phổ biến',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppConfig.smallPadding / 2),
                      Text(
                        plan.duration,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.price == 0
                          ? 'Miễn phí'
                          : '${plan.price.toStringAsFixed(0)}đ',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (plan.price > 0)
                      Text(
                        '/${plan.duration.toLowerCase()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConfig.defaultPadding),

            // Features
            Text(
              'Tính năng bao gồm:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppConfig.smallPadding),
            ...plan.features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppConfig.smallPadding / 2,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : AppTheme.secondaryGray,
                      size: 16,
                    ),
                    const SizedBox(width: AppConfig.smallPadding),
                    Expanded(
                      child: Text(
                        feature,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Select Button
            if (isSelected) ...[
              const SizedBox(height: AppConfig.defaultPadding),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConfig.smallPadding + 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(AppConfig.smallPadding),
                ),
                child: const Text(
                  'Đã chọn',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
