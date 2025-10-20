import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/advisory_card.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/health_check_card.dart';

class AdvisoryPage extends StatefulWidget {
  const AdvisoryPage({super.key});

  @override
  State<AdvisoryPage> createState() => _AdvisoryPageState();
}

class _AdvisoryPageState extends State<AdvisoryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  final List<AdvisoryItem> _advisories = [
    AdvisoryItem(
      id: '1',
      title: 'Cảnh báo dị ứng hải sản',
      description: 'Món cá kho tộ chứa hải sản có thể gây dị ứng cho bố',
      type: AdvisoryType.allergy,
      priority: AdvisoryPriority.high,
      memberName: 'Nguyễn Văn A',
      recipeName: 'Cá kho tộ',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    AdvisoryItem(
      id: '2',
      title: 'Cảnh báo đường huyết',
      description: 'Món chè đậu đỏ có lượng đường cao, không phù hợp với mẹ',
      type: AdvisoryType.health,
      priority: AdvisoryPriority.medium,
      memberName: 'Trần Thị B',
      recipeName: 'Chè đậu đỏ',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    AdvisoryItem(
      id: '3',
      title: 'Cảnh báo cay',
      description:
          'Món bún bò Huế có độ cay cao, không phù hợp với khẩu vị gia đình',
      type: AdvisoryType.spice,
      priority: AdvisoryPriority.low,
      memberName: 'Gia đình',
      recipeName: 'Bún bò Huế',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                onPressed: () => _runHealthCheck(),
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

          // Health Reports List
          _buildHealthReportCard(
            title: 'Báo cáo tuần này',
            date: '15/01/2024',
            status: 'Tốt',
            color: AppTheme.successColor,
          ),
          const SizedBox(height: 12),
          _buildHealthReportCard(
            title: 'Cảnh báo dinh dưỡng',
            date: '10/01/2024',
            status: 'Cần chú ý',
            color: AppTheme.warningColor,
          ),
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

  void _runHealthCheck() {
    _showHealthCheckDialog(
      title: 'Kiểm tra sức khỏe tổng quát',
      description:
          'Đang phân tích tình trạng sức khỏe của tất cả thành viên...',
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
  }) {
    // Show loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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

    // Simulate health check process and show results
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        // Small delay to ensure dialog is closed
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _showHealthCheckResults(title);
          }
        });
      }
    });
  }

  void _showHealthCheckResults(String checkType) {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => _buildHealthCheckResultsSheet(checkType),
    );
  }

  Widget _buildHealthCheckResultsSheet(String checkType) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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

            // Results content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildResultCard(
                      'Tình trạng tổng thể',
                      'Tốt',
                      AppTheme.successColor,
                      'Sức khỏe gia đình đang ở mức tốt',
                    ),
                    const SizedBox(height: 16),
                    _buildResultCard(
                      'Cảnh báo',
                      '2',
                      AppTheme.warningColor,
                      'Có 2 vấn đề cần chú ý',
                    ),
                    const SizedBox(height: 16),
                    _buildResultCard(
                      'Khuyến nghị',
                      '3',
                      AppTheme.infoColor,
                      '3 gợi ý cải thiện sức khỏe',
                    ),
                    const SizedBox(height: 24),

                    // Detailed results
                    Text(
                      'Chi tiết kết quả',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    _buildDetailItem(
                      'Thành viên: Bố',
                      'Sức khỏe tốt, cần giảm muối',
                      AppTheme.successColor,
                    ),
                    _buildDetailItem(
                      'Thành viên: Mẹ',
                      'Cần bổ sung canxi',
                      AppTheme.warningColor,
                    ),
                    _buildDetailItem(
                      'Thành viên: Con',
                      'Cân bằng dinh dưỡng tốt',
                      AppTheme.successColor,
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to detailed report
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Xem báo cáo chi tiết'),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
