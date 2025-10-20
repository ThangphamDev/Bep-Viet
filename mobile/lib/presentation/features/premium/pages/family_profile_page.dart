import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/core/services/api_service.dart';
import 'package:bepviet_mobile/core/models/family_model.dart';
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
    return FamilyMember(
      id: model.id,
      name: model.name,
      age: model.age,
      role: 'Thành viên', // Default role
      allergies: model.allergies,
      dietaryRestrictions: model.dietFlags.map((flag) => flag.value).toList(),
      healthConditions: model.healthConditions,
    );
  }
}

class FamilyProfilePage extends StatefulWidget {
  const FamilyProfilePage({super.key});

  @override
  State<FamilyProfilePage> createState() => _FamilyProfilePageState();
}

class _FamilyProfilePageState extends State<FamilyProfilePage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<FamilyProfileModel> _familyProfiles = [];
  List<FamilyMemberModel> _familyMembers = [];

  @override
  void initState() {
    super.initState();
    _loadFamilyData();
  }

  Future<void> _loadFamilyData() async {
    try {
      setState(() => _isLoading = true);

      // Mock user ID - in real app, get from auth service
      const userId = 'user_123';

      // Load family profiles
      final familyData = await _apiService.getFamilyProfiles(userId);
      _familyProfiles = familyData
          .map((json) => FamilyProfileModel.fromJson(json))
          .toList();

      // Load family members from first profile
      if (_familyProfiles.isNotEmpty) {
        final membersData = await _apiService.getFamilyMembers(
          _familyProfiles.first.id,
          userId,
        );
        _familyMembers = membersData
            .map((json) => FamilyMemberModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error loading family data: $e');
      // Fallback to mock data
      _familyMembers = [
        FamilyMemberModel(
          id: '1',
          familyId: 'family_1',
          name: 'Nguyễn Văn A',
          age: 35,
          allergies: ['Hải sản', 'Đậu phộng'],
          spiceLevel: SpiceLevel.medium,
          dietFlags: [DietFlag.vegetarian],
          healthConditions: ['Huyết áp cao'],
          notes: 'Không thích cay',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    } finally {
      setState(() => _isLoading = false);
    }
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
                                  '${_familyMembers.length} thành viên • 3 cảnh báo hoạt động • 2 báo cáo tuần',
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
                              'Cảnh báo',
                              '3',
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
                              'Điểm sức khỏe',
                              '8.2',
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

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMemberDialog(
        onSave: (member) {
          // Convert FamilyMember to FamilyMemberModel
          final familyMemberModel = FamilyMemberModel(
            id: member.id,
            familyId: _familyProfiles.isNotEmpty
                ? _familyProfiles.first.id
                : '',
            name: member.name,
            age: member.age,
            allergies: member.allergies,
            spiceLevel: SpiceLevel.medium, // Default
            dietFlags: member.dietaryRestrictions.map((restriction) {
              switch (restriction) {
                case 'VEGETARIAN':
                  return DietFlag.vegetarian;
                case 'VEGAN':
                  return DietFlag.vegan;
                case 'GLUTEN_FREE':
                  return DietFlag.glutenFree;
                case 'DAIRY_FREE':
                  return DietFlag.dairyFree;
                case 'KETO':
                  return DietFlag.keto;
                default:
                  return DietFlag.vegetarian;
              }
            }).toList(),
            healthConditions: member.healthConditions,
            notes: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          setState(() {
            _familyMembers.add(familyMemberModel);
          });
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
        content: Text('Bạn có chắc muốn xóa ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _familyMembers.remove(member);
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: AppTheme.errorColor),
            ),
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
