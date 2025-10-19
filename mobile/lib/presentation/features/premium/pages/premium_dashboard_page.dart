import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/premium_card.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/feature_benefit_card.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/health_summary_card.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/quick_stats_card.dart';

class PremiumDashboardPage extends StatelessWidget {
  const PremiumDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Premium'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Summary Card
            HealthSummaryCard(
              totalMembers: 4,
              activeWarnings: 3,
              weeklyReports: 2,
              onTap: () => context.go('/premium/family'),
            ),
            const SizedBox(height: AppConfig.defaultPadding + 4),

            // Quick Stats Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConfig.defaultPadding,
              ),
              child: Text(
                'Thống kê nhanh',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: AppConfig.defaultPadding),

            // Quick Stats Grid
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConfig.defaultPadding,
              ),
              child: SizedBox(
                height: 190, // Fixed height to prevent overflow
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConfig.defaultPadding,
                  mainAxisSpacing: AppConfig.defaultPadding,
                  childAspectRatio: 1.6, // Optimized aspect ratio
                  children: [
                    QuickStatsCard(
                      title: 'Cảnh báo tuần này',
                      subtitle: 'Món ăn cần chú ý',
                      icon: Icons.warning_amber,
                      color: AppTheme.warningColor,
                      value: '3',
                      unit: 'món',
                      onTap: () => context.go('/premium/advisory'),
                    ),
                    QuickStatsCard(
                      title: 'Dinh dưỡng trung bình',
                      subtitle: 'Calories/ngày',
                      icon: Icons.local_fire_department,
                      color: AppTheme.errorColor,
                      value: '1,850',
                      unit: 'kcal',
                      onTap: () {},
                    ),
                    QuickStatsCard(
                      title: 'Món đã nấu',
                      subtitle: 'Tuần này',
                      icon: Icons.restaurant,
                      color: AppTheme.successColor,
                      value: '12',
                      unit: 'món',
                      onTap: () {},
                    ),
                    QuickStatsCard(
                      title: 'Tiết kiệm',
                      subtitle: 'So với tuần trước',
                      icon: Icons.savings,
                      color: AppTheme.infoColor,
                      value: '15%',
                      unit: 'chi phí',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConfig.defaultPadding + 4),

            // Premium Features Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConfig.defaultPadding,
              ),
              child: Text(
                'Tính năng Premium',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: AppConfig.defaultPadding),

            // Premium Features Grid
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConfig.defaultPadding,
              ),
              child: SizedBox(
                height: 200, // Fixed height to prevent overflow
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConfig.defaultPadding,
                  mainAxisSpacing: AppConfig.defaultPadding,
                  childAspectRatio: 1.4, // Optimized for fixed height
                  children: [
                    FeatureBenefitCard(
                      icon: Icons.family_restroom,
                      title: 'Hồ sơ gia đình',
                      description: 'Quản lý thành viên & sở thích',
                      onTap: () => context.go('/premium/family'),
                    ),
                    FeatureBenefitCard(
                      icon: Icons.health_and_safety,
                      title: 'Cảnh báo thông minh',
                      description: 'Dị ứng & dinh dưỡng',
                      onTap: () => context.go('/premium/advisory'),
                    ),
                    FeatureBenefitCard(
                      icon: Icons.analytics,
                      title: 'Báo cáo tuần',
                      description: 'Thống kê sức khỏe',
                      onTap: () => context.go('/premium/report'),
                    ),
                    FeatureBenefitCard(
                      icon: Icons.smart_toy,
                      title: 'Chuyên gia ảo',
                      description: 'Tư vấn dinh dưỡng AI',
                      onTap: () => context.go('/premium/ai-advisor'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConfig.defaultPadding + 4),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConfig.defaultPadding,
              ),
              child: Text(
                'Thao tác nhanh',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: AppConfig.defaultPadding),

            // Quick Action Cards
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConfig.defaultPadding,
              ),
              child: Column(
                children: [
                  PremiumCard(
                    title: 'Kiểm tra cảnh báo',
                    subtitle: 'Xem cảnh báo dinh dưỡng mới nhất',
                    icon: Icons.warning_amber,
                    color: AppTheme.warningColor,
                    onTap: () => context.go('/premium/advisory'),
                  ),
                  const SizedBox(height: AppConfig.smallPadding),

                  PremiumCard(
                    title: 'Quản lý gia đình',
                    subtitle: 'Thêm/sửa thông tin thành viên',
                    icon: Icons.people,
                    color: AppTheme.primaryGreen,
                    onTap: () => context.go('/premium/family'),
                  ),
                  const SizedBox(height: AppConfig.smallPadding),

                  PremiumCard(
                    title: 'Báo cáo tuần',
                    subtitle: 'Xem thống kê sức khỏe gia đình',
                    icon: Icons.analytics,
                    color: AppTheme.infoColor,
                    onTap: () => context.go('/premium/report'),
                  ),
                  const SizedBox(height: AppConfig.smallPadding),

                  PremiumCard(
                    title: 'Lịch sử đăng ký',
                    subtitle: 'Xem chi tiết gói đăng ký',
                    icon: Icons.receipt_long,
                    color: AppTheme.secondaryGray,
                    onTap: () => context.go('/premium/subscription'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConfig.defaultPadding + 4),
          ],
        ),
      ),
    );
  }
}
