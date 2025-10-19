import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';

class WeeklyReportPage extends StatelessWidget {
  const WeeklyReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Báo cáo tuần'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/premium'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(context),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportToPDF(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(AppConfig.largePadding),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(
                  AppConfig.defaultPadding + 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(
                          AppConfig.smallPadding + 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppConfig.smallPadding + 4,
                          ),
                        ),
                        child: const Icon(
                          Icons.analytics,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppConfig.defaultPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Báo cáo sức khỏe gia đình',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: AppConfig.smallPadding / 2),
                            Text(
                              'Tuần từ 15/01 - 21/01/2024',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConfig.largePadding),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHeaderStat(
                          'Tổng bữa ăn',
                          '28',
                          'bữa',
                          Colors.white,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      Expanded(
                        child: _buildHeaderStat(
                          'Cảnh báo',
                          '5',
                          'món',
                          Colors.white,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      Expanded(
                        child: _buildHeaderStat(
                          'Điểm sức khỏe',
                          '8.2',
                          '/10',
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConfig.largePadding),

            // Nutrition Overview
            Text(
              'Tổng quan dinh dưỡng',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConfig.defaultPadding),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppConfig.smallPadding + 4,
              mainAxisSpacing: AppConfig.smallPadding + 4,
              childAspectRatio: 1.3,
              children: [
                _buildNutritionCard(
                  'Calories',
                  '1,850',
                  'kcal/ngày',
                  Icons.local_fire_department,
                  AppTheme.errorColor,
                  'Trung bình',
                ),
                _buildNutritionCard(
                  'Protein',
                  '85g',
                  'g/ngày',
                  Icons.fitness_center,
                  AppTheme.successColor,
                  'Tốt',
                ),
                _buildNutritionCard(
                  'Carbs',
                  '220g',
                  'g/ngày',
                  Icons.grain,
                  AppTheme.warningColor,
                  'Cao',
                ),
                _buildNutritionCard(
                  'Sodium',
                  '2,100mg',
                  'mg/ngày',
                  Icons.water_drop,
                  AppTheme.infoColor,
                  'Cần giảm',
                ),
              ],
            ),
            const SizedBox(height: AppConfig.largePadding),

            // Health Warnings
            Text(
              'Cảnh báo sức khỏe',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConfig.defaultPadding),

            _buildWarningCard(
              'Dị ứng hải sản',
              'Nguyễn Văn A',
              'Cá kho tộ',
              'Món chứa tôm có thể gây dị ứng',
              AppTheme.errorColor,
              'Nghiêm trọng',
            ),
            const SizedBox(height: AppConfig.smallPadding),

            _buildWarningCard(
              'Đường huyết cao',
              'Trần Thị B',
              'Chè đậu đỏ',
              'Lượng đường cao, không phù hợp',
              AppTheme.warningColor,
              'Trung bình',
            ),
            const SizedBox(height: AppConfig.smallPadding),

            _buildWarningCard(
              'Cay quá mức',
              'Gia đình',
              'Bún bò Huế',
              'Độ cay 4/5, không phù hợp trẻ em',
              AppTheme.infoColor,
              'Nhẹ',
            ),
            const SizedBox(height: AppConfig.largePadding),

            // Recommendations
            Text(
              'Khuyến nghị tuần tới',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConfig.defaultPadding),

            Container(
              padding: const EdgeInsets.all(AppConfig.defaultPadding),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(
                  AppConfig.defaultPadding + 4,
                ),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildRecommendationItem(
                    Icons.eco,
                    'Thêm rau xanh',
                    'Tăng cường rau củ trong bữa ăn',
                    AppTheme.successColor,
                  ),
                  const SizedBox(height: AppConfig.smallPadding),
                  _buildRecommendationItem(
                    Icons.warning_amber,
                    'Giảm món chiên',
                    'Hạn chế đồ chiên rán',
                    AppTheme.warningColor,
                  ),
                  const SizedBox(height: AppConfig.smallPadding),
                  _buildRecommendationItem(
                    Icons.water_drop,
                    'Giảm muối',
                    'Sử dụng ít muối trong nấu ăn',
                    AppTheme.infoColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConfig.largePadding),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
        ),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildNutritionCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
    String status,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppConfig.defaultPadding + 4),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConfig.smallPadding,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConfig.smallPadding),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConfig.smallPadding),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(unit, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: AppConfig.smallPadding / 2),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(
    String title,
    String member,
    String dish,
    String description,
    Color color,
    String severity,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppConfig.defaultPadding + 4),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.warning_amber, color: color, size: 16),
              ),
              const SizedBox(width: AppConfig.smallPadding),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConfig.smallPadding,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConfig.smallPadding),
                ),
                child: Text(
                  severity,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConfig.smallPadding),
          Text(
            '$member - $dish',
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppConfig.smallPadding / 2),
          Text(description, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: AppConfig.smallPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _shareReport(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng chia sẻ đang được phát triển')),
    );
  }

  void _exportToPDF(BuildContext context) {
    // TODO: Implement PDF export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng xuất PDF đang được phát triển')),
    );
  }
}
