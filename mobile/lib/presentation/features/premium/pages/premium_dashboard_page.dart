import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/premium_card.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/feature_benefit_card.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/health_summary_card.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/quick_stats_card.dart';
import 'package:bepviet_mobile/presentation/features/premium/cubit/premium_cubit.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';

class PremiumDashboardPage extends StatefulWidget {
  const PremiumDashboardPage({super.key});

  @override
  State<PremiumDashboardPage> createState() => _PremiumDashboardPageState();
}

class _PremiumDashboardPageState extends State<PremiumDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      // Get token from AuthRepository
      final token = context.read<AuthCubit>().authRepository.accessToken;
      if (token != null) {
        print(
          '🔑 Premium Dashboard - Token available: ${token.substring(0, 20)}...',
        );
        print('👤 Premium Dashboard - User: ${authState.user.name}');
        context.read<PremiumCubit>().add(LoadPremiumData(token));
      } else {
        print('❌ Premium Dashboard - No token available');
      }
    } else {
      print('❌ Premium Dashboard - User not authenticated');
    }
  }

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
      body: BlocBuilder<PremiumCubit, PremiumState>(
        builder: (context, state) {
          if (state is PremiumLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PremiumError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi tải dữ liệu',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is PremiumLoaded) {
            // Check if user has active subscription (not FREE)
            final hasActiveSubscription =
                state.subscription != null &&
                state.subscription!.status == 'ACTIVE' &&
                state.subscription!.plan != 'FREE';

            // If no active subscription or using FREE plan, redirect to subscription page
            if (!hasActiveSubscription) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.go('/premium/subscription');
                }
              });
              return const Center(child: CircularProgressIndicator());
            }

            final totalMembers = state.familyProfiles.fold(
              0,
              (sum, profile) => sum + profile.members.length,
            );

            final analytics = state.userAnalytics;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health Summary Card
                  HealthSummaryCard(
                    totalMembers: totalMembers,
                    activeWarnings: 0, // TODO: Implement warnings API
                    weeklyReports: 0, // TODO: Implement reports API
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
                      height: 210,
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: AppConfig.defaultPadding,
                        mainAxisSpacing: AppConfig.defaultPadding,
                        childAspectRatio: 1.5,
                        children: [
                          QuickStatsCard(
                            title: 'Kế hoạch bữa ăn',
                            subtitle: 'Tổng số',
                            icon: Icons.calendar_today,
                            color: AppTheme.primaryGreen,
                            value: analytics.mealPlansCount.toString(),
                            unit: 'kế hoạch',
                            onTap: () => context.go('/planner'),
                          ),
                          QuickStatsCard(
                            title: 'Tủ lạnh',
                            subtitle: 'Nguyên liệu',
                            icon: Icons.kitchen,
                            color: AppTheme.infoColor,
                            value: analytics.pantryItemsCount.toString(),
                            unit: 'món',
                            onTap: () => context.go('/pantry'),
                          ),
                          QuickStatsCard(
                            title: 'Danh sách mua',
                            subtitle: 'Tổng số',
                            icon: Icons.shopping_cart,
                            color: AppTheme.warningColor,
                            value: analytics.shoppingListsCount.toString(),
                            unit: 'danh sách',
                            onTap: () => context.go('/pantry'),
                          ),
                          QuickStatsCard(
                            title: 'Đóng góp cộng đồng',
                            subtitle: 'Công thức & đánh giá',
                            icon: Icons.star,
                            color: AppTheme.successColor,
                            value:
                                (analytics.communityRecipesCount +
                                        analytics.ratingsGivenCount)
                                    .toString(),
                            unit: 'lượt',
                            onTap: () => context.go('/community'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConfig.largePadding + 8),

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
                      height: 220,
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: AppConfig.defaultPadding,
                        mainAxisSpacing: AppConfig.defaultPadding,
                        childAspectRatio: 1.5,
                        children: [
                          FeatureBenefitCard(
                            icon: Icons.family_restroom,
                            title: 'Hồ sơ gia đình',
                            description: 'Quản lý thành viên',
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
                            description: 'Tư vấn AI',
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
            );
          }

          // Fallback for other states
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
