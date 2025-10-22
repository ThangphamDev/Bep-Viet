import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';

class WeeklyReportPage extends StatefulWidget {
  const WeeklyReportPage({super.key});

  @override
  State<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends State<WeeklyReportPage> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    _loadWeeklyReport();
  }

  Future<void> _loadWeeklyReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthAuthenticated) {
        throw Exception('Vui lòng đăng nhập');
      }

      final token = context.read<AuthCubit>().authRepository.accessToken;
      if (token == null) {
        throw Exception('Token không hợp lệ');
      }

      final dio = Dio();
      dio.options.baseUrl = AppConfig.ngrokBaseUrl;
      dio.options.headers['ngrok-skip-browser-warning'] = 'true';

      final response = await dio.get(
        '/api/analytics/weekly-report',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic> &&
          response.data['success'] == true) {
        setState(() {
          _reportData = response.data['data'] as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error loading weekly report: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDateRange() {
    if (_reportData == null) return 'Tuần này';
    final weekStart = _reportData!['week_start'] as String?;
    final weekEnd = _reportData!['week_end'] as String?;
    if (weekStart == null || weekEnd == null) return 'Tuần này';

    try {
      final start = DateTime.parse(weekStart);
      final end = DateTime.parse(weekEnd);
      final formatter = DateFormat('dd/MM/yyyy');
      return 'Tuần từ ${formatter.format(start)} - ${formatter.format(end)}';
    } catch (e) {
      return 'Tuần này';
    }
  }

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
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Đang phân tích, chờ chút nhé... 🔍',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.errorColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không thể tải báo cáo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadWeeklyReport,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(
                                    height: AppConfig.smallPadding / 2,
                                  ),
                                  Text(
                                    _formatDateRange(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
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
                                '${_reportData?['total_meals'] ?? 0}',
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
                                '${_reportData?['warning_count'] ?? 0}',
                                'mục',
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
                                '${_reportData?['health_score'] ?? 0}',
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
                    childAspectRatio: 1.4, // Increased to prevent overflow
                    children: [
                      _buildNutritionCard(
                        'Calories',
                        '${_reportData?['nutrition']?['calories'] ?? 0}',
                        'kcal/ngày',
                        Icons.local_fire_department,
                        AppTheme.errorColor,
                        'Trung bình',
                      ),
                      _buildNutritionCard(
                        'Protein',
                        '${_reportData?['nutrition']?['protein'] ?? 0}g',
                        'g/ngày',
                        Icons.fitness_center,
                        AppTheme.successColor,
                        'Tốt',
                      ),
                      _buildNutritionCard(
                        'Carbs',
                        '${_reportData?['nutrition']?['carbs'] ?? 0}g',
                        'g/ngày',
                        Icons.grain,
                        AppTheme.warningColor,
                        'Trung bình',
                      ),
                      _buildNutritionCard(
                        'Sodium',
                        '${_reportData?['nutrition']?['sodium'] ?? 0}mg',
                        'mg/ngày',
                        Icons.water_drop,
                        AppTheme.infoColor,
                        'Bình thường',
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

                  ..._buildWarningsList(),
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
                    child: Column(children: _buildRecommendationsList()),
                  ),
                  const SizedBox(height: AppConfig.largePadding),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildWarningsList() {
    final warnings = _reportData?['warnings'] as List?;
    if (warnings == null || warnings.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(AppConfig.largePadding),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppConfig.defaultPadding + 4),
            border: Border.all(
              color: AppTheme.successColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successColor, size: 32),
              const SizedBox(width: AppConfig.defaultPadding),
              Expanded(
                child: Text(
                  'Tuyệt vời! Không có cảnh báo sức khỏe nào.',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return warnings.map<Widget>((warning) {
      final memberName = warning['member_name'] as String? ?? 'Thành viên';
      final recipeName = warning['recipe_name'] as String? ?? 'Món ăn';
      final type = warning['type'] as String? ?? 'warning';
      final severity = warning['severity'] as String? ?? 'medium';
      final description = warning['description'] as String? ?? 'Cần lưu ý';

      // Map severity to color
      Color warningColor;
      String severityLabel;
      if (severity == 'high') {
        warningColor = AppTheme.errorColor;
        severityLabel = 'Nghiêm trọng';
      } else if (severity == 'medium') {
        warningColor = AppTheme.warningColor;
        severityLabel = 'Trung bình';
      } else {
        warningColor = AppTheme.infoColor;
        severityLabel = 'Nhẹ';
      }

      // Map type to title
      String warningTitle;
      if (type == 'allergy') {
        warningTitle = 'Dị ứng thực phẩm';
      } else if (type == 'diet') {
        warningTitle = 'Hạn chế ăn uống';
      } else {
        warningTitle = 'Lưu ý sức khỏe';
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: AppConfig.smallPadding),
        child: _buildWarningCard(
          warningTitle,
          memberName,
          recipeName,
          description,
          warningColor,
          severityLabel,
        ),
      );
    }).toList();
  }

  List<Widget> _buildRecommendationsList() {
    final recommendations = _reportData?['recommendations'] as List? ?? [];

    if (recommendations.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Text(
            'Không có khuyến nghị nào',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ),
      ];
    }

    final widgets = <Widget>[];
    for (int i = 0; i < recommendations.length; i++) {
      final rec = recommendations[i];
      final iconStr = rec['icon'] as String? ?? 'info';
      final title = rec['title'] as String? ?? 'Khuyến nghị';
      final description = rec['description'] as String? ?? '';

      // Map icon string to IconData and Color
      IconData icon;
      Color color;
      switch (iconStr) {
        case 'eco':
          icon = Icons.eco;
          color = AppTheme.successColor;
          break;
        case 'warning_amber':
          icon = Icons.warning_amber;
          color = AppTheme.warningColor;
          break;
        case 'water_drop':
          icon = Icons.water_drop;
          color = AppTheme.infoColor;
          break;
        case 'local_fire_department':
          icon = Icons.local_fire_department;
          color = AppTheme.errorColor;
          break;
        case 'fitness_center':
          icon = Icons.fitness_center;
          color = AppTheme.successColor;
          break;
        default:
          icon = Icons.info;
          color = AppTheme.primaryGreen;
      }

      widgets.add(_buildRecommendationItem(icon, title, description, color));

      if (i < recommendations.length - 1) {
        widgets.add(const SizedBox(height: AppConfig.smallPadding));
      }
    }

    return widgets;
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
      padding: const EdgeInsets.all(
        AppConfig.smallPadding + 4,
      ), // Reduced padding
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppConfig.defaultPadding + 4),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Prevent overflow
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18), // Reduced icon size
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6, // Reduced padding
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8), // Reduced radius
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 9, // Reduced font size
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6), // Reduced spacing
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ), // Reduced font size
          ),
          Text(
            unit,
            style: const TextStyle(fontSize: 11), // Reduced font size
          ),
          const Spacer(), // Add spacer to push title to bottom
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ), // Reduced font size
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
      margin: const EdgeInsets.only(bottom: AppConfig.defaultPadding),
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppConfig.defaultPadding + 4),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.warning_amber, color: color, size: 18),
              ),
              const SizedBox(width: AppConfig.smallPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      'Thành viên: $member',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
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
