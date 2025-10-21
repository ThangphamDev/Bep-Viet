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
            final totalMembers = state.familyProfiles.fold(
              0,
              (sum, profile) => sum + profile.members.length,
            );

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health Summary Card
                  HealthSummaryCard(
                    totalMembers: totalMembers,
                    activeWarnings: 3, // Mock data for now
                    weeklyReports: 2, // Mock data for now
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
                      height: 210, // Increased height to prevent text cutoff
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: AppConfig.defaultPadding,
                        mainAxisSpacing: AppConfig.defaultPadding,
                        childAspectRatio:
                            1.5, // Adjusted aspect ratio for better text display
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
                            onTap: () => _showNutritionDetails(),
                          ),
                          QuickStatsCard(
                            title: 'Món đã nấu',
                            subtitle: 'Tuần này',
                            icon: Icons.restaurant,
                            color: AppTheme.successColor,
                            value: '12',
                            unit: 'món',
                            onTap: () => _showCookedDishes(),
                          ),
                          QuickStatsCard(
                            title: 'Tiết kiệm',
                            subtitle: 'So với tuần trước',
                            icon: Icons.savings,
                            color: AppTheme.infoColor,
                            value: '15%',
                            unit: 'chi phí',
                            onTap: () => _showSavingsDetails(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: AppConfig.largePadding + 8,
                  ), // Increased spacing
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
                      height: 220, // Increased height to prevent text cutoff
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: AppConfig.defaultPadding,
                        mainAxisSpacing: AppConfig.defaultPadding,
                        childAspectRatio:
                            1.5, // Increased aspect ratio for more vertical space
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

  // Nutrition Details
  void _showNutritionDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNutritionDetailsSheet(),
    );
  }

  Widget _buildNutritionDetailsSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: AppTheme.errorColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Chi tiết dinh dưỡng',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Nutrition Summary
                    _buildNutritionSummaryCard(),
                    const SizedBox(height: 20),

                    // Nutrition Breakdown
                    Text(
                      'Phân tích dinh dưỡng',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    _buildNutritionItem(
                      'Calories',
                      '1,850',
                      'kcal',
                      '85%',
                      AppTheme.errorColor,
                    ),
                    _buildNutritionItem(
                      'Protein',
                      '85g',
                      'g',
                      '90%',
                      AppTheme.successColor,
                    ),
                    _buildNutritionItem(
                      'Carbs',
                      '220g',
                      'g',
                      '75%',
                      AppTheme.warningColor,
                    ),
                    _buildNutritionItem(
                      'Fat',
                      '65g',
                      'g',
                      '80%',
                      AppTheme.infoColor,
                    ),
                    _buildNutritionItem(
                      'Fiber',
                      '25g',
                      'g',
                      '95%',
                      AppTheme.successColor,
                    ),
                    _buildNutritionItem(
                      'Sodium',
                      '2,100mg',
                      'mg',
                      '70%',
                      AppTheme.warningColor,
                    ),

                    const SizedBox(height: 24),

                    // Weekly Trend
                    Text(
                      'Xu hướng tuần',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    _buildWeeklyTrendChart(),

                    const SizedBox(height: 24),

                    // Recommendations
                    Text(
                      'Khuyến nghị',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    _buildRecommendationCard(
                      'Tăng protein',
                      'Bổ sung thêm thịt, cá, đậu để đạt mục tiêu protein',
                      Icons.trending_up,
                      AppTheme.successColor,
                    ),
                    _buildRecommendationCard(
                      'Giảm sodium',
                      'Hạn chế muối và thực phẩm chế biến sẵn',
                      Icons.trending_down,
                      AppTheme.warningColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.errorColor.withOpacity(0.1),
            AppTheme.errorColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: AppTheme.errorColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Dinh dưỡng trung bình',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Text(
                '1,850 kcal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Mức dinh dưỡng của bạn đang ở mức tốt. Hãy duy trì chế độ ăn cân bằng!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(
    String name,
    String value,
    String unit,
    String percentage,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '$value $unit',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text(
            percentage,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrendChart() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Calories theo ngày',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChartBar(60, 'T2'),
                _buildChartBar(80, 'T3'),
                _buildChartBar(70, 'T4'),
                _buildChartBar(90, 'T5'),
                _buildChartBar(85, 'T6'),
                _buildChartBar(75, 'T7'),
                _buildChartBar(65, 'CN'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(double height, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.errorColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildRecommendationCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Cooked Dishes
  void _showCookedDishes() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCookedDishesSheet(),
    );
  }

  Widget _buildCookedDishesSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    color: AppTheme.successColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Món đã nấu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary
                    _buildCookedDishesSummary(),
                    const SizedBox(height: 20),

                    // Recent dishes
                    Text(
                      'Món gần đây',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    _buildDishItem(
                      'Cơm tấm sườn nướng',
                      'Hôm qua',
                      4.5,
                      'Vietnamese',
                    ),
                    _buildDishItem(
                      'Bún bò Huế',
                      '2 ngày trước',
                      4.8,
                      'Vietnamese',
                    ),
                    _buildDishItem('Phở bò', '3 ngày trước', 4.2, 'Vietnamese'),
                    _buildDishItem(
                      'Gỏi cuốn',
                      '4 ngày trước',
                      4.6,
                      'Vietnamese',
                    ),
                    _buildDishItem(
                      'Bánh xèo',
                      '5 ngày trước',
                      4.3,
                      'Vietnamese',
                    ),

                    const SizedBox(height: 24),

                    // Statistics
                    Text(
                      'Thống kê',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '12',
                            'Món tuần này',
                            AppTheme.successColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            '48',
                            'Món tháng này',
                            AppTheme.infoColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '4.5',
                            'Đánh giá TB',
                            AppTheme.warningColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            '15',
                            'Món yêu thích',
                            AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCookedDishesSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.successColor.withOpacity(0.1),
            AppTheme.successColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.successColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.restaurant, color: AppTheme.successColor, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Món đã nấu tuần này',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Text(
                '12 món',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Bạn đã nấu nhiều món ngon! Hãy tiếp tục khám phá các công thức mới.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDishItem(
    String name,
    String date,
    double rating,
    String category,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.restaurant, color: AppTheme.successColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Savings Details
  void _showSavingsDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSavingsDetailsSheet(),
    );
  }

  Widget _buildSavingsDetailsSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.savings, color: AppTheme.infoColor, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Chi tiết tiết kiệm',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary
                    _buildSavingsSummary(),
                    const SizedBox(height: 20),

                    // Savings breakdown
                    Text(
                      'Phân tích tiết kiệm',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    _buildSavingsItem(
                      'Nấu ăn tại nhà',
                      '850,000đ',
                      '70%',
                      AppTheme.successColor,
                    ),
                    _buildSavingsItem(
                      'Mua nguyên liệu thông minh',
                      '200,000đ',
                      '20%',
                      AppTheme.infoColor,
                    ),
                    _buildSavingsItem(
                      'Tận dụng thực phẩm thừa',
                      '100,000đ',
                      '10%',
                      AppTheme.warningColor,
                    ),

                    const SizedBox(height: 24),

                    // Comparison
                    Text(
                      'So sánh chi phí',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    _buildComparisonCard(
                      'Nấu tại nhà',
                      '1,200,000đ',
                      AppTheme.successColor,
                    ),
                    _buildComparisonCard(
                      'Ăn ngoài',
                      '2,000,000đ',
                      AppTheme.errorColor,
                    ),
                    _buildComparisonCard(
                      'Đặt đồ ăn',
                      '1,800,000đ',
                      AppTheme.warningColor,
                    ),

                    const SizedBox(height: 24),

                    // Tips
                    Text(
                      'Mẹo tiết kiệm',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    _buildTipCard(
                      'Mua nguyên liệu theo mùa',
                      'Thực phẩm theo mùa thường rẻ hơn và tươi ngon hơn',
                      Icons.calendar_month,
                    ),
                    _buildTipCard(
                      'Lập kế hoạch bữa ăn',
                      'Lên kế hoạch trước giúp tránh lãng phí thực phẩm',
                      Icons.calendar_today,
                    ),
                    _buildTipCard(
                      'Tận dụng thực phẩm thừa',
                      'Biến thực phẩm thừa thành món ăn mới',
                      Icons.recycling,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.infoColor.withOpacity(0.1),
            AppTheme.infoColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.infoColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.savings, color: AppTheme.infoColor, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tiết kiệm tuần này',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Text(
                '15%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Bạn đã tiết kiệm được 800,000đ so với tuần trước! Hãy tiếp tục duy trì.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsItem(
    String category,
    String amount,
    String percentage,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  amount,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text(
            percentage,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(String method, String cost, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.compare_arrows, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              method,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            cost,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.infoColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.infoColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
