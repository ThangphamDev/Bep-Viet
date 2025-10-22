import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/advisory_card.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/health_check_card.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';

class AdvisoryPage extends StatefulWidget {
  const AdvisoryPage({super.key});

  @override
  State<AdvisoryPage> createState() => _AdvisoryPageState();
}

class _AdvisoryPageState extends State<AdvisoryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  bool _isLoading = true;
  String? _errorMessage;
  List<AdvisoryItem> _advisories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWarnings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWarnings() async {
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
        final data = response.data['data'] as Map<String, dynamic>;
        final warnings = (data['warnings'] as List?) ?? [];

        setState(() {
          _advisories = warnings.map((warning) {
            final type = warning['type'] == 'allergy'
                ? AdvisoryType.allergy
                : warning['type'] == 'diet'
                ? AdvisoryType.health
                : AdvisoryType.spice;

            final priority = warning['severity'] == 'high'
                ? AdvisoryPriority.high
                : warning['severity'] == 'medium'
                ? AdvisoryPriority.medium
                : AdvisoryPriority.low;

            return AdvisoryItem(
              id: warning['member_name'] ?? 'unknown',
              title: _getWarningTitle(type),
              description: warning['description'] ?? 'Không có mô tả',
              type: type,
              priority: priority,
              memberName: warning['member_name'] ?? 'Thành viên',
              recipeName: warning['recipe_name'] ?? 'Món ăn',
              createdAt: DateTime.now(),
              isRead: false,
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getWarningTitle(AdvisoryType type) {
    switch (type) {
      case AdvisoryType.allergy:
        return 'Cảnh báo dị ứng';
      case AdvisoryType.health:
        return 'Cảnh báo sức khỏe';
      case AdvisoryType.spice:
        return 'Cảnh báo khác';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Cảnh báo dinh dưỡng'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/premium'),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Tất cả')),
              const PopupMenuItem(value: 'unread', child: Text('Chưa đọc')),
              const PopupMenuItem(value: 'high', child: Text('Ưu tiên cao')),
            ],
            child: const Icon(Icons.filter_list),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cảnh báo', icon: Icon(Icons.warning_amber)),
            Tab(text: 'Kiểm tra sức khỏe', icon: Icon(Icons.health_and_safety)),
            Tab(text: 'Lịch sử', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAdvisoriesTab(),
          _buildHealthCheckTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildAdvisoriesTab() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải cảnh báo...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
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
                'Không thể tải dữ liệu',
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
                onPressed: _loadWarnings,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredAdvisories = _getFilteredAdvisories();

    return Column(
      children: [
        // Health Check Summary
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cardDecoration,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: AppTheme.warningColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tình trạng sức khỏe gia đình',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${filteredAdvisories.where((a) => !a.isRead).length} cảnh báo chưa đọc',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _loadWarnings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kiểm tra'),
              ),
            ],
          ),
        ),

        // Advisories List
        Expanded(
          child: filteredAdvisories.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredAdvisories.length,
                  itemBuilder: (context, index) {
                    final advisory = filteredAdvisories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AdvisoryCard(
                        advisory: advisory,
                        onTap: () => _showAdvisoryDetails(advisory),
                        onMarkAsRead: () => _markAsRead(advisory),
                        onDismiss: () => _dismissAdvisory(advisory),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHealthCheckTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Health Check
          HealthCheckCard(
            title: 'Kiểm tra nhanh',
            description: 'Kiểm tra tình trạng sức khỏe của tất cả thành viên',
            icon: Icons.speed,
            color: AppTheme.primaryGreen,
            onTap: () => _runQuickHealthCheck(),
          ),
          const SizedBox(height: 16),

          // Detailed Health Check
          HealthCheckCard(
            title: 'Kiểm tra chi tiết',
            description: 'Phân tích sâu về dinh dưỡng và sức khỏe',
            icon: Icons.analytics,
            color: AppTheme.infoColor,
            onTap: () => _runDetailedHealthCheck(),
          ),
          const SizedBox(height: 16),

          // Recipe Safety Check
          HealthCheckCard(
            title: 'Kiểm tra an toàn món ăn',
            description: 'Kiểm tra món ăn có phù hợp với gia đình không',
            icon: Icons.restaurant,
            color: AppTheme.warningColor,
            onTap: () => _runRecipeSafetyCheck(),
          ),
          const SizedBox(height: 24),

          // Recent Health Reports
          Text(
            'Báo cáo gần đây',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Health Reports List (from real data)
          if (_advisories.isNotEmpty) ...[
            _buildHealthReportCard(
              title: 'Cảnh báo tuần này',
              date: _formatDate(DateTime.now()),
              status: _getHealthStatus(),
              color: _getHealthStatusColor(),
            ),
          ] else ...[
            _buildHealthReportCard(
              title: 'Không có cảnh báo',
              date: _formatDate(DateTime.now()),
              status: 'Tốt',
              color: AppTheme.successColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _advisories.length,
      itemBuilder: (context, index) {
        final advisory = _advisories[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AdvisoryCard(
            advisory: advisory,
            onTap: () => _showAdvisoryDetails(advisory),
            showActions: false,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppTheme.successColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Không có cảnh báo nào',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Gia đình bạn đang có sức khỏe tốt!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  List<AdvisoryItem> _getFilteredAdvisories() {
    switch (_selectedFilter) {
      case 'unread':
        return _advisories.where((a) => !a.isRead).toList();
      case 'high':
        return _advisories
            .where((a) => a.priority == AdvisoryPriority.high)
            .toList();
      default:
        return _advisories;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getHealthStatus() {
    final highPriorityCount = _advisories
        .where((a) => a.priority == AdvisoryPriority.high)
        .length;
    if (highPriorityCount > 0) return 'Cần chú ý';
    if (_advisories.length > 2) return 'Bình thường';
    return 'Tốt';
  }

  Color _getHealthStatusColor() {
    final highPriorityCount = _advisories
        .where((a) => a.priority == AdvisoryPriority.high)
        .length;
    if (highPriorityCount > 0) return AppTheme.errorColor;
    if (_advisories.length > 2) return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  Widget _buildHealthReportCard({
    required String title,
    required String date,
    required String status,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(date, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _runQuickHealthCheck() {
    _showHealthCheckDialog(
      title: 'Kiểm tra nhanh',
      description: 'Đang kiểm tra tình trạng sức khỏe cơ bản...',
    );
  }

  void _runDetailedHealthCheck() {
    _showHealthCheckDialog(
      title: 'Kiểm tra chi tiết',
      description: 'Đang phân tích sâu về dinh dưỡng và sức khỏe...',
    );
  }

  void _runRecipeSafetyCheck() {
    _showHealthCheckDialog(
      title: 'Kiểm tra an toàn món ăn',
      description: 'Đang kiểm tra món ăn có phù hợp với gia đình...',
    );
  }

  void _showHealthCheckDialog({
    required String title,
    required String description,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.defaultPadding + 4),
        ),
        title: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryGreen,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: Text(description),
      ),
    );

    // Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Close dialog if still mounted
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();

      // Wait a bit before showing bottom sheet
      await Future.delayed(const Duration(milliseconds: 500));

      // Show results if still mounted
      if (mounted) {
        _showHealthCheckResults(title);
      }
    }
  }

  void _showHealthCheckResults(String checkType) {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      useRootNavigator: false,
      builder: (sheetContext) => _buildHealthCheckResultsSheet(checkType),
    );
  }

  Widget _buildHealthCheckResultsSheet(String checkType) {
    final totalWarnings = _advisories.length;
    final highPriorityCount = _advisories
        .where((a) => a.priority == AdvisoryPriority.high)
        .length;
    final unreadCount = _advisories.where((a) => !a.isRead).length;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      color: AppTheme.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kết quả $checkType',
                        style: const TextStyle(
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResultCard(
                        'Tình trạng tổng thể',
                        _getHealthStatus(),
                        _getHealthStatusColor(),
                        totalWarnings == 0
                            ? 'Sức khỏe gia đình đang ở mức tốt'
                            : 'Có $totalWarnings cảnh báo cần lưu ý',
                      ),
                      const SizedBox(height: 16),
                      _buildResultCard(
                        'Cảnh báo ưu tiên cao',
                        '$highPriorityCount',
                        highPriorityCount > 0
                            ? AppTheme.errorColor
                            : AppTheme.successColor,
                        highPriorityCount > 0
                            ? 'Cần xử lý ngay'
                            : 'Không có cảnh báo nghiêm trọng',
                      ),
                      const SizedBox(height: 16),
                      _buildResultCard(
                        'Cảnh báo chưa đọc',
                        '$unreadCount',
                        unreadCount > 0
                            ? AppTheme.warningColor
                            : AppTheme.infoColor,
                        unreadCount > 0
                            ? 'Cần xem và xử lý'
                            : 'Đã xem tất cả cảnh báo',
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Chi tiết cảnh báo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (_advisories.isEmpty)
                        _buildDetailItem(
                          'Tuyệt vời!',
                          'Không có cảnh báo nào',
                          AppTheme.successColor,
                        )
                      else
                        ..._advisories
                            .take(5)
                            .map(
                              (advisory) => _buildDetailItem(
                                'Thành viên: ${advisory.memberName}',
                                advisory.description,
                                _getPriorityColor(advisory.priority),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen,
                          side: BorderSide(
                            color: AppTheme.primaryGreen,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Đóng',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/premium/report');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Xem chi tiết',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(
    String title,
    String value,
    Color color,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.check_circle, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAdvisoryDetails(AdvisoryItem advisory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAdvisoryDetailsSheet(advisory),
    );
  }

  Widget _buildAdvisoryDetailsSheet(AdvisoryItem advisory) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Advisory Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getAdvisoryColor(
                            advisory.type,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getAdvisoryIcon(advisory.type),
                          color: _getAdvisoryColor(advisory.type),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              advisory.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              '${advisory.memberName} • ${advisory.recipeName}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(
                            advisory.priority,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getPriorityText(advisory.priority),
                          style: TextStyle(
                            color: _getPriorityColor(advisory.priority),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Advisory Description
                  Text('Mô tả', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    advisory.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _markAsRead(advisory),
                          icon: const Icon(Icons.check),
                          label: const Text('Đã đọc'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _dismissAdvisory(advisory),
                          icon: const Icon(Icons.close),
                          label: const Text('Bỏ qua'),
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
    );
  }

  Color _getAdvisoryColor(AdvisoryType type) {
    switch (type) {
      case AdvisoryType.allergy:
        return AppTheme.errorColor;
      case AdvisoryType.health:
        return AppTheme.warningColor;
      case AdvisoryType.spice:
        return AppTheme.infoColor;
    }
  }

  IconData _getAdvisoryIcon(AdvisoryType type) {
    switch (type) {
      case AdvisoryType.allergy:
        return Icons.warning_amber;
      case AdvisoryType.health:
        return Icons.health_and_safety;
      case AdvisoryType.spice:
        return Icons.local_fire_department;
    }
  }

  Color _getPriorityColor(AdvisoryPriority priority) {
    switch (priority) {
      case AdvisoryPriority.high:
        return AppTheme.errorColor;
      case AdvisoryPriority.medium:
        return AppTheme.warningColor;
      case AdvisoryPriority.low:
        return AppTheme.infoColor;
    }
  }

  String _getPriorityText(AdvisoryPriority priority) {
    switch (priority) {
      case AdvisoryPriority.high:
        return 'Cao';
      case AdvisoryPriority.medium:
        return 'Trung bình';
      case AdvisoryPriority.low:
        return 'Thấp';
    }
  }

  void _markAsRead(AdvisoryItem advisory) {
    setState(() {
      advisory.isRead = true;
    });
    // Show success message instead of navigating away
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đánh dấu đã đọc'),
        backgroundColor: AppTheme.successColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _dismissAdvisory(AdvisoryItem advisory) {
    setState(() {
      _advisories.remove(advisory);
    });
    // Show success message instead of navigating away
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã bỏ qua cảnh báo'),
        backgroundColor: AppTheme.infoColor,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

enum AdvisoryType { allergy, health, spice }

enum AdvisoryPriority { high, medium, low }

class AdvisoryItem {
  final String id;
  final String title;
  final String description;
  final AdvisoryType type;
  final AdvisoryPriority priority;
  final String memberName;
  final String recipeName;
  final DateTime createdAt;
  bool isRead;

  AdvisoryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.memberName,
    required this.recipeName,
    required this.createdAt,
    this.isRead = false,
  });
}
