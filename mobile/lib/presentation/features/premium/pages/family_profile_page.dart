import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/data/models/family_model.dart';
import 'package:bepviet_mobile/data/sources/remote/premium_service.dart';
import 'package:bepviet_mobile/data/repositories/premium_repository.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/family_member_card.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/add_member_dialog.dart';

// Legacy class for compatibility
class FamilyMember {
  final String id;
  final String name;
  final int age;
  final String role;
  final List<String> allergies;
  final List<String> dietaryRestrictions;
  final List<String> healthConditions;
  final String customAllergies;
  final String customDietaryRestrictions;
  final String customHealthConditions;

  FamilyMember({
    required this.id,
    required this.name,
    required this.age,
    required this.role,
    this.allergies = const [],
    this.dietaryRestrictions = const [],
    this.healthConditions = const [],
    this.customAllergies = '',
    this.customDietaryRestrictions = '',
    this.customHealthConditions = '',
  });

  factory FamilyMember.fromFamilyMemberModel(FamilyMemberModel model) {
    // Parse allergies from JSON
    List<String> allergiesList = [];
    if (model.allergiesJson != null) {
      if (model.allergiesJson!['items'] is List) {
        allergiesList = (model.allergiesJson!['items'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    // Parse diet restrictions from JSON
    List<String> dietList = [];
    if (model.dietJson != null) {
      if (model.dietJson!['items'] is List) {
        dietList = (model.dietJson!['items'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    // Convert age_group to age number (approximate)
    int age = 25; // default
    if (model.ageGroup != null) {
      switch (model.ageGroup) {
        case 'CHILD':
          age = 8;
          break;
        case 'TEEN':
          age = 15;
          break;
        case 'ADULT':
          age = 35;
          break;
        case 'SENIOR':
          age = 65;
          break;
      }
    }

    return FamilyMember(
      id: model.id,
      name: model.name,
      age: age,
      role: 'Thành viên',
      allergies: allergiesList,
      dietaryRestrictions: dietList,
      healthConditions: [],
      customAllergies: model.note ?? '',
    );
  }
}

class FamilyProfilePage extends StatefulWidget {
  const FamilyProfilePage({super.key});

  @override
  State<FamilyProfilePage> createState() => _FamilyProfilePageState();
}

class _FamilyProfilePageState extends State<FamilyProfilePage> {
  bool _isLoading = true;
  List<FamilyProfileModel> _familyProfiles = [];
  List<FamilyMemberModel> _familyMembers = [];
  Map<String, dynamic>? _analytics;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFamilyData();
  }

  Future<void> _loadFamilyData() async {
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

      final premiumRepo = PremiumRepository(PremiumService(Dio()));

      // Load family profiles and analytics in parallel
      final results = await Future.wait([
        premiumRepo.getUserFamilyProfiles(token),
        _loadAnalytics(token),
      ]);

      final profiles = results[0] as List<FamilyProfileModel>;

      setState(() {
        _familyProfiles = profiles;
        // Extract all members from all profiles
        _familyMembers = profiles.expand((profile) => profile.members).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _loadAnalytics(String token) async {
    try {
      final dio = Dio();
      dio.options.baseUrl = AppConfig.ngrokBaseUrl;
      dio.options.headers['ngrok-skip-browser-warning'] = 'true';

      final response = await dio.get(
        '/api/analytics/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic> &&
          response.data['success'] == true) {
        final analytics = response.data['data'] as Map<String, dynamic>;
        setState(() {
          _analytics = analytics;
        });
        return analytics;
      }
    } catch (e) {
      // Don't throw, analytics is optional
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Hồ sơ gia đình'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/premium'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMemberDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                      onPressed: _loadFamilyData,
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
          : _familyProfiles.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.family_restroom,
                      size: 80,
                      color: AppTheme.primaryGreen.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Chưa có hồ sơ gia đình',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tạo hồ sơ gia đình để quản lý\nthông tin dinh dưỡng cho cả nhà!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _showCreateFamilyDialog,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Tạo hồ sơ gia đình',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _familyMembers.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 64,
                      color: AppTheme.primaryGreen.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có thành viên nào',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thêm thành viên gia đình để bắt đầu!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Family Overview Card
                Container(
                  margin: const EdgeInsets.all(AppConfig.defaultPadding),
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
                              Icons.family_restroom,
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
                                  'Hồ sơ gia đình thông minh',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(
                                  height: AppConfig.smallPadding / 2,
                                ),
                                Text(
                                  '${_familyMembers.length} thành viên',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConfig.smallPadding,
                              vertical: AppConfig.smallPadding / 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(
                                AppConfig.smallPadding,
                              ),
                            ),
                            child: Text(
                              'Premium',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConfig.largePadding),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFamilyStat(
                              'Thành viên',
                              '${_familyMembers.length}',
                              Colors.white,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            child: _buildFamilyStat(
                              'Kế hoạch',
                              '${_analytics?['meal_plans_count'] ?? 0}',
                              Colors.white,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            child: _buildFamilyStat(
                              'Tủ lạnh',
                              '${_analytics?['pantry_items_count'] ?? 0}',
                              Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Family Members List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConfig.defaultPadding,
                    ),
                    itemCount: _familyMembers.length,
                    itemBuilder: (context, index) {
                      final member = _familyMembers[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppConfig.smallPadding + 4,
                        ),
                        child: FamilyMemberCard(
                          member: FamilyMember.fromFamilyMemberModel(member),
                          onTap: () => _showMemberDetails(
                            FamilyMember.fromFamilyMemberModel(member),
                          ),
                          onEdit: () => _editMember(
                            FamilyMember.fromFamilyMemberModel(member),
                          ),
                          onDelete: () => _deleteMember(
                            FamilyMember.fromFamilyMemberModel(member),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMemberDialog(),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Thêm thành viên',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _showCreateFamilyDialog() async {
    final nameController = TextEditingController(text: 'Gia đình của tôi');
    final noteController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo hồ sơ gia đình'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên hồ sơ',
                hintText: 'VD: Gia đình Nguyễn Văn A',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (tùy chọn)',
                hintText: 'Thêm mô tả về gia đình...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text(
              'Tạo hồ sơ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result != true || !mounted) return;

    // Create family profile
    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthAuthenticated) return;

      final token = context.read<AuthCubit>().authRepository.accessToken;
      if (token == null) return;

      final premiumRepo = PremiumRepository(PremiumService(Dio()));
      await premiumRepo.createFamilyProfile(
        token,
        CreateFamilyProfileRequest(
          name: nameController.text.trim(),
          note: noteController.text.trim().isEmpty
              ? null
              : noteController.text.trim(),
        ),
      );

      // Reload data to get the created profile
      await _loadFamilyData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tạo hồ sơ gia đình thành công!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo hồ sơ: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      nameController.dispose();
      noteController.dispose();
    }
  }

  Future<void> _showAddMemberDialog() async {
    if (_familyProfiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng tạo hồ sơ gia đình trước'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AddMemberDialog(
        onSave: (member) async {
          try {
            final authState = context.read<AuthCubit>().state;
            if (authState is! AuthAuthenticated) return;

            final token = context.read<AuthCubit>().authRepository.accessToken;
            if (token == null) return;

            // Convert age to age_group
            String ageGroup = 'ADULT';
            if (member.age < 12) {
              ageGroup = 'CHILD';
            } else if (member.age < 18) {
              ageGroup = 'TEEN';
            } else if (member.age >= 60) {
              ageGroup = 'SENIOR';
            }

            // Create JSON for allergies and diet
            Map<String, dynamic>? allergiesJson;
            if (member.allergies.isNotEmpty) {
              allergiesJson = {'items': member.allergies};
            }

            Map<String, dynamic>? dietJson;
            if (member.dietaryRestrictions.isNotEmpty) {
              dietJson = {'items': member.dietaryRestrictions};
            }

            final request = AddFamilyMemberRequest(
              name: member.name,
              ageGroup: ageGroup,
              spiceTolerance: 1,
              dietJson: dietJson,
              allergiesJson: allergiesJson,
              note: member.customAllergies.isNotEmpty
                  ? member.customAllergies
                  : null,
            );

            final premiumRepo = PremiumRepository(PremiumService(Dio()));
            await premiumRepo.addFamilyMember(
              token,
              _familyProfiles.first.id,
              request,
            );

            // Reload data
            await _loadFamilyData();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã thêm thành viên thành công'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi thêm thành viên: $e'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showMemberDetails(FamilyMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMemberDetailsSheet(member),
    );
  }

  Widget _buildMemberDetailsSheet(FamilyMember member) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                  // Member Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                        child: Text(
                          member.name.split(' ').last[0],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              '${member.age} tuổi • ${member.role}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editMember(member),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Allergies Section
                  if (member.allergies.isNotEmpty ||
                      member.customAllergies.isNotEmpty) ...[
                    _buildInfoSection(
                      title: 'Dị ứng',
                      icon: Icons.warning_amber,
                      color: AppTheme.warningColor,
                      items: member.allergies,
                      customText: member.customAllergies,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Dietary Restrictions
                  if (member.dietaryRestrictions.isNotEmpty ||
                      member.customDietaryRestrictions.isNotEmpty) ...[
                    _buildInfoSection(
                      title: 'Hạn chế ăn uống',
                      icon: Icons.restaurant,
                      color: AppTheme.infoColor,
                      items: member.dietaryRestrictions,
                      customText: member.customDietaryRestrictions,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Health Conditions
                  if (member.healthConditions.isNotEmpty ||
                      member.customHealthConditions.isNotEmpty) ...[
                    _buildInfoSection(
                      title: 'Tình trạng sức khỏe',
                      icon: Icons.health_and_safety,
                      color: AppTheme.errorColor,
                      items: member.healthConditions,
                      customText: member.customHealthConditions,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
    String? customText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...items
                .map(
                  (item) => Chip(
                    label: Text(item),
                    backgroundColor: color.withOpacity(0.1),
                    labelStyle: TextStyle(color: color),
                    side: BorderSide(color: color.withOpacity(0.3)),
                  ),
                )
                .toList(),
            if (customText != null && customText.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 16, color: color),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        customText,
                        style: TextStyle(color: color, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _editMember(FamilyMember member) {
    // TODO: Implement edit member
  }

  void _deleteMember(FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thành viên'),
        content: const Text('Chức năng xóa thành viên đang được phát triển.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyStat(String label, String value, Color color) {
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
          label,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }
}
